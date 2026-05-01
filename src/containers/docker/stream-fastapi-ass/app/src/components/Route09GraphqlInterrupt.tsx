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
import { useMemo, useState } from 'react'
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
      }

      if (payload.type === 'review_submitted') {
        setPendingReview(null)
      }

      if (payload.type === 'graph_completed' || payload.type === 'stream_error') {
        setRunning(false)
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
    try {
      const result = await createRun()
      const id = result.data?.createRun09 as string | undefined
      if (!id) {
        throw new Error('Failed to create run id')
      }
      setRunId(id)
      setRunning(true)
      setEventLog((prev) => [...prev, `Run created: ${id}`])
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

  const nodes = definitionData?.graphDefinition09?.nodes ?? []

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
