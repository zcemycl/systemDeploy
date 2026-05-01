import {
  ApolloClient,
  ApolloProvider,
  HttpLink,
  InMemoryCache,
  gql,
  split,
  useMutation,
  useQuery,
  useSubscription,
} from '@apollo/client'
import { GraphQLWsLink } from '@apollo/client/link/subscriptions/index.js'
import { getMainDefinition } from '@apollo/client/utilities'
import { useEffect, useMemo, useRef, useState } from 'react'
import { createClient } from 'graphql-ws'

type Props = {
  apiBaseUrl: string
}

const GRAPH_DEFINITION_QUERY = gql`
  query GraphDefinition09 {
    graphDefinition09 {
      nodes {
        id
        label
        order
        isReview
      }
    }
  }
`

const CREATE_RUN_MUTATION = gql`
  mutation CreateRun09 {
    createRun09
  }
`

const SUBMIT_REVIEW_DECISION_MUTATION = gql`
  mutation SubmitReviewDecision09($runId: String!, $decision: ReviewDecisionInput!) {
    submitReviewDecision09(runId: $runId, decision: $decision)
  }
`

const STREAM_SUBSCRIPTION = gql`
  subscription StreamRun09($runId: String!) {
    streamRun09(runId: $runId) {
      type
      runId
      nodeId
      nodeLabel
      isReview
      durationMs
      stateJson
      graphJson
      payloadJson
      decisionJson
      allowedActions
      stoppedReason
      message
    }
  }
`

type StreamEvent = {
  type: string
  runId: string
  nodeId?: string | null
  nodeLabel?: string | null
  durationMs?: number | null
  stateJson?: string | null
  payloadJson?: string | null
  decisionJson?: string | null
  allowedActions?: string[] | null
  stoppedReason?: string | null
  message?: string | null
}

type PendingReview = {
  nodeId: string
  nodeLabel: string
  reviewText: string
  allowedActions: string[]
}

type NodeStatus = 'idle' | 'running' | 'waiting_review' | 'completed' | 'failed'

type NodeUiState = {
  status: NodeStatus
  pulse: boolean
  lastEvent?: string
}

function Route09GraphqlInterruptInner() {
  const { data: definitionData, loading: loadingDefinition, error: definitionError } = useQuery(GRAPH_DEFINITION_QUERY)
  const [createRun] = useMutation(CREATE_RUN_MUTATION)
  const [submitReviewDecision] = useMutation(SUBMIT_REVIEW_DECISION_MUTATION)

  const [runId, setRunId] = useState('')
  const [steps, setSteps] = useState<string[]>([])
  const [eventLog, setEventLog] = useState<string[]>([])
  const [error, setError] = useState('')
  const [running, setRunning] = useState(false)
  const [pendingReview, setPendingReview] = useState<PendingReview | null>(null)
  const [comment, setComment] = useState('')
  const [editedText, setEditedText] = useState('')
  const [submittingDecision, setSubmittingDecision] = useState(false)
  const [nodeStates, setNodeStates] = useState<Record<string, NodeUiState>>({})
  const pulseTimers = useRef<Record<string, ReturnType<typeof setTimeout>>>({})

  const nodes = definitionData?.graphDefinition09?.nodes ?? []
  const orderedNodes = useMemo(
    () => [...nodes].sort((a: { order: number }, b: { order: number }) => a.order - b.order),
    [nodes],
  )
  const nodeOrder = useMemo(() => orderedNodes.map((n: { id: string }) => n.id), [orderedNodes])

  useEffect(() => {
    if (orderedNodes.length === 0) return
    setNodeStates((prev) => {
      const next: Record<string, NodeUiState> = {}
      for (const node of orderedNodes) {
        next[node.id] = prev[node.id] ?? { status: 'idle', pulse: false }
      }
      return next
    })
  }, [orderedNodes])

  useEffect(
    () => () => {
      for (const timerId of Object.values(pulseTimers.current)) {
        clearTimeout(timerId)
      }
    },
    [],
  )

  function pulseNode(nodeId: string, status: NodeStatus, lastEvent: string) {
    setNodeStates((prev) => ({
      ...prev,
      [nodeId]: { status, pulse: true, lastEvent },
    }))
    if (pulseTimers.current[nodeId]) {
      clearTimeout(pulseTimers.current[nodeId])
    }
    pulseTimers.current[nodeId] = setTimeout(() => {
      setNodeStates((prev) => ({
        ...prev,
        [nodeId]: {
          ...(prev[nodeId] ?? { status, lastEvent }),
          pulse: false,
        },
      }))
      delete pulseTimers.current[nodeId]
    }, 800)
  }

  useSubscription(STREAM_SUBSCRIPTION, {
    variables: { runId },
    skip: !runId,
    onData: ({ data }) => {
      const payload = data.data?.streamRun09 as StreamEvent | undefined
      if (!payload) return

      setEventLog((prev) => [
        ...prev,
        `${payload.type}${payload.nodeLabel ? ` - ${payload.nodeLabel}` : ''}${typeof payload.durationMs === 'number' ? ` (${payload.durationMs.toFixed(0)} ms)` : ''}`,
      ])

      if (payload.stateJson) {
        try {
          const state = JSON.parse(payload.stateJson) as { steps?: string[] }
          if (Array.isArray(state.steps)) {
            setSteps(state.steps)
          }
        } catch {
          // Keep example simple when state payload is malformed.
        }
      }

      if (payload.type === 'review_required') {
        let reviewText = ''
        try {
          if (payload.payloadJson) {
            const parsed = JSON.parse(payload.payloadJson) as { review_text?: string }
            reviewText = parsed.review_text ?? ''
          }
        } catch {
          reviewText = ''
        }
        setPendingReview({
          nodeId: payload.nodeId ?? '',
          nodeLabel: payload.nodeLabel ?? 'Review Node',
          reviewText,
          allowedActions: payload.allowedActions ?? ['approve', 'reject', 'edit'],
        })
        setEditedText(reviewText)
        if (payload.nodeId) {
          pulseNode(payload.nodeId, 'waiting_review', payload.type)
        }
      }

      if (payload.type === 'review_submitted') {
        setPendingReview(null)
        if (payload.nodeId) {
          pulseNode(payload.nodeId, 'running', payload.type)
        }
      }

      if (payload.type === 'node_completed' && payload.nodeId) {
        pulseNode(payload.nodeId, 'completed', payload.type)
        const nodeIndex = nodeOrder.indexOf(payload.nodeId)
        if (nodeIndex >= 0 && nodeIndex < nodeOrder.length - 1) {
          const nextNodeId = nodeOrder[nodeIndex + 1]
          pulseNode(nextNodeId, 'running', 'node_started')
        }
      }

      if (payload.type === 'graph_completed' || payload.type === 'stream_error') {
        setRunning(false)
        if (payload.type === 'stream_error' && pendingReview?.nodeId) {
          pulseNode(pendingReview.nodeId, 'failed', payload.type)
        }
      }
    },
    onError: (err) => {
      setError(err.message)
      setRunning(false)
    },
  })

  async function startRun() {
    setError('')
    setEventLog([])
    setSteps([])
    setPendingReview(null)
    setComment('')
    setEditedText('')
    if (orderedNodes.length > 0) {
      setNodeStates(
        Object.fromEntries(orderedNodes.map((node: { id: string }) => [node.id, { status: 'idle', pulse: false }])),
      )
    }
    try {
      const result = await createRun()
      const id = result.data?.createRun09 as string | undefined
      if (!id) {
        throw new Error('Failed to create run id')
      }
      setRunId(id)
      setRunning(true)
      setEventLog((prev) => [...prev, `Run created: ${id}`])
      if (nodeOrder.length > 0) {
        pulseNode(nodeOrder[0], 'running', 'node_started')
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
      setRunning(false)
    }
  }

  async function submitDecision(action: 'approve' | 'reject' | 'edit') {
    if (!pendingReview || !runId) return
    setSubmittingDecision(true)
    setError('')
    try {
      const response = await submitReviewDecision({
        variables: {
          runId,
          decision: {
            nodeId: pendingReview.nodeId,
            action,
            editedText: action === 'edit' ? editedText : null,
            comment: comment || null,
          },
        },
      })
      const ok = response.data?.submitReviewDecision09 as boolean | undefined
      if (!ok) {
        throw new Error('Decision was not accepted by server')
      }
      setEventLog((prev) => [...prev, `Submitted ${action} for ${pendingReview.nodeLabel}`])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setSubmittingDecision(false)
    }
  }
  function nodeClass(status: NodeStatus, pulse: boolean, isReview: boolean): string {
    if (status === 'running') return pulse ? 'border-blue-500 bg-blue-100 text-blue-900 ring-2 ring-blue-300' : 'border-blue-400 bg-blue-50 text-blue-900'
    if (status === 'waiting_review') {
      return pulse
        ? 'border-purple-500 bg-purple-100 text-purple-900 ring-2 ring-purple-300'
        : 'border-purple-400 bg-purple-50 text-purple-900'
    }
    if (status === 'completed') return pulse ? 'border-green-500 bg-green-100 text-green-900 ring-2 ring-green-300' : 'border-green-400 bg-green-50 text-green-900'
    if (status === 'failed') return 'border-red-500 bg-red-100 text-red-900 ring-2 ring-red-300'
    return isReview ? 'border-purple-200 bg-white text-slate-900' : 'border-slate-300 bg-white text-slate-900'
  }

  return (
    <section className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">09 GraphQL + LangGraph Interrupt</h2>
      <p className="text-xs text-slate-600">
        Uses <code>useQuery</code> for graph metadata, <code>useSubscription</code> for stream events, and mutation for review decisions.
      </p>

      <button className="rounded border px-3 py-1" type="button" onClick={startRun} disabled={running}>
        {running ? 'Running...' : 'Create / Start Run'}
      </button>

      {runId && <p className="text-xs text-slate-500">run_id: {runId}</p>}
      {error && <p className="text-red-600">{error}</p>}
      {definitionError && <p className="text-red-600">{definitionError.message}</p>}

      <div className="rounded border p-2 text-sm">
        <p className="font-medium">Graph Definition</p>
        {loadingDefinition ? (
          <p className="text-slate-500">Loading definition...</p>
        ) : (
          <p>{nodes.length > 0 ? nodes.map((node: { label: string }) => node.label).join(' -> ') : 'No nodes loaded.'}</p>
        )}
      </div>

      <div className="overflow-x-auto rounded border p-3">
        <div className="flex min-w-max items-center gap-2">
          {orderedNodes.length === 0 && <p className="text-sm text-slate-500">Load graph definition to see nodes.</p>}
          {orderedNodes.map((node: { id: string; label: string; isReview: boolean }, index: number) => {
            const ui = nodeStates[node.id] ?? { status: 'idle', pulse: false }
            return (
              <div key={node.id} className="flex items-center gap-2">
                <div className={`rounded border px-3 py-2 text-sm font-medium transition-all duration-200 ${nodeClass(ui.status, ui.pulse, node.isReview)}`}>
                  <p>{node.label}</p>
                  <p className="text-xs opacity-75">
                    {node.id} - {ui.status}
                  </p>
                </div>
                {index < orderedNodes.length - 1 && <span className="text-slate-500">→</span>}
              </div>
            )
          })}
        </div>
      </div>

      <div className="rounded border p-2 text-sm">
        <p className="font-medium">Completed Steps</p>
        <p>{steps.length > 0 ? steps.join(' -> ') : '-'}</p>
      </div>

      {pendingReview && (
        <div className="space-y-2 rounded border border-blue-300 bg-blue-50 p-3">
          <p className="text-sm font-semibold">Review Required: {pendingReview.nodeLabel}</p>
          <p className="text-xs text-slate-600">Allowed: {pendingReview.allowedActions.join(', ')}</p>
          <label className="block">
            <span className="mb-1 block text-sm">Editable Content</span>
            <textarea
              className="w-full rounded border p-2"
              rows={3}
              value={editedText}
              onChange={(e) => setEditedText(e.target.value)}
            />
          </label>
          <label className="block">
            <span className="mb-1 block text-sm">Comment</span>
            <input className="w-full rounded border p-2" value={comment} onChange={(e) => setComment(e.target.value)} />
          </label>
          <div className="flex flex-wrap gap-2">
            <button
              className="rounded border px-3 py-1"
              type="button"
              onClick={() => submitDecision('approve')}
              disabled={submittingDecision}
            >
              Approve
            </button>
            <button
              className="rounded border px-3 py-1"
              type="button"
              onClick={() => submitDecision('edit')}
              disabled={submittingDecision}
            >
              Edit + Submit
            </button>
            <button
              className="rounded border px-3 py-1"
              type="button"
              onClick={() => submitDecision('reject')}
              disabled={submittingDecision}
            >
              Reject
            </button>
          </div>
        </div>
      )}

      <div className="space-y-1">
        <p className="text-sm font-medium">Event Log</p>
        <pre className="max-h-56 overflow-auto rounded border p-2 text-xs whitespace-pre-wrap">
          {eventLog.length > 0 ? eventLog.join('\n') : 'No events yet.'}
        </pre>
      </div>
    </section>
  )
}

export default function Route09GraphqlInterrupt({ apiBaseUrl }: Props) {
  const client = useMemo(() => {
    const httpUrl = `${apiBaseUrl}/graphql-09`
    const wsUrl = httpUrl.replace('http://', 'ws://').replace('https://', 'wss://')

    const httpLink = new HttpLink({ uri: httpUrl })
    const wsLink = new GraphQLWsLink(createClient({ url: wsUrl }))

    const splitLink = split(
      ({ query }) => {
        const definition = getMainDefinition(query)
        return definition.kind === 'OperationDefinition' && definition.operation === 'subscription'
      },
      wsLink,
      httpLink,
    )

    return new ApolloClient({
      link: splitLink,
      cache: new InMemoryCache(),
    })
  }, [apiBaseUrl])

  return (
    <ApolloProvider client={client}>
      <Route09GraphqlInterruptInner />
    </ApolloProvider>
  )
}
