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
import { GraphQLWsLink } from '@apollo/client/link/subscriptions'
import { getMainDefinition } from '@apollo/client/utilities'
import { useMemo, useState } from 'react'
import { createClient } from 'graphql-ws'

type Props = {
  apiBaseUrl: string
}

const GRAPH_DEFINITION_QUERY = gql`
  query GraphDefinition08 {
    graphDefinition08 {
      nodes {
        id
        label
        order
      }
      edges {
        id
        source
        target
      }
    }
  }
`

const CREATE_RUN_MUTATION = gql`
  mutation CreateRun08 {
    createRun08
  }
`

const START_RUN_MUTATION = gql`
  mutation StartRun08($runId: String!, $prompt: String) {
    startRun08(runId: $runId, prompt: $prompt)
  }
`

const STREAM_SUBSCRIPTION = gql`
  subscription StreamRun08($runId: String!) {
    streamRun08(runId: $runId) {
      type
      runId
      nodeId
      nodeLabel
      durationMs
      stateJson
      graphJson
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
  graphJson?: string | null
  message?: string | null
}

function Route08GraphqlSubscriptionInner() {
  const { data: definitionData, loading: loadingDefinition, error: definitionError } = useQuery(GRAPH_DEFINITION_QUERY)
  const [createRun] = useMutation(CREATE_RUN_MUTATION)
  const [startRun] = useMutation(START_RUN_MUTATION)

  const [runId, setRunId] = useState('')
  const [prompt, setPrompt] = useState('demo prompt')
  const [eventLog, setEventLog] = useState<string[]>([])
  const [steps, setSteps] = useState<string[]>([])
  const [running, setRunning] = useState(false)
  const [runError, setRunError] = useState('')

  useSubscription(STREAM_SUBSCRIPTION, {
    variables: { runId },
    skip: !runId,
    onData: ({ data }) => {
        const payload = data.data?.streamRun08 as StreamEvent | undefined
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
            // Ignore malformed state for this example UI.
          }
        }

        if (payload.type === 'graph_completed' || payload.type === 'stream_error') {
          setRunning(false)
        }
    },
    onError: (err) => {
      setRunError(err.message)
      setRunning(false)
    },
  })

  async function startStreamingRun() {
    setRunError('')
    setEventLog([])
    setSteps([])
    try {
      const createResult = await createRun()
      const newRunId = createResult.data?.createRun08 as string | undefined
      if (!newRunId) {
        throw new Error('Failed to create run id')
      }
      setRunId(newRunId)
      setRunning(true)
      await startRun({ variables: { runId: newRunId, prompt } })
      setEventLog((prev) => [...prev, `Run started (${newRunId})`])
    } catch (err) {
      setRunError(err instanceof Error ? err.message : 'Unknown error')
      setRunning(false)
    }
  }

  const nodes = definitionData?.graphDefinition08?.nodes ?? []

  return (
    <section className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">08 GraphQL Subscription Stream</h2>

      <p className="text-xs text-slate-600">
        Convention: use <code>useQuery</code> for static metadata and <code>useSubscription</code> for live events.
      </p>

      <div className="flex flex-wrap gap-2">
        <input
          className="min-w-64 rounded border px-2 py-1 text-sm"
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          placeholder="Prompt for run"
        />
        <button className="rounded border px-3 py-1" type="button" onClick={startStreamingRun} disabled={running}>
          {running ? 'Running...' : 'Create + Start GraphQL Run'}
        </button>
      </div>

      {runId && <p className="text-xs text-slate-500">run_id: {runId}</p>}
      {runError && <p className="text-red-600">{runError}</p>}
      {definitionError && <p className="text-red-600">{definitionError.message}</p>}

      <div className="rounded border p-2 text-sm">
        <p className="font-medium">Graph Definition (Query)</p>
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

      <div className="space-y-1">
        <p className="text-sm font-medium">Event Log (Subscription)</p>
        <pre className="max-h-56 overflow-auto rounded border p-2 text-xs whitespace-pre-wrap">
          {eventLog.length > 0 ? eventLog.join('\n') : 'No events yet.'}
        </pre>
      </div>
    </section>
  )
}

export default function Route08GraphqlSubscription({ apiBaseUrl }: Props) {
  const client = useMemo(() => {
    const httpUrl = `${apiBaseUrl}/graphql-08`
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
      <Route08GraphqlSubscriptionInner />
    </ApolloProvider>
  )
}
