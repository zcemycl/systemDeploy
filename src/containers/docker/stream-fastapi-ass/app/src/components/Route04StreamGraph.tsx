import { useMemo, useState } from 'react'

type Props = {
  apiBaseUrl: string
}

type GraphNode = {
  id: string
  label: string
  order?: number
}

type GraphEdge = {
  id: string
  source: string
  target: string
}

type GraphDefinition = {
  nodes: GraphNode[]
  edges: GraphEdge[]
}

type AgentState = {
  steps: string[]
}

type StreamEvent =
  | { type: 'graph_init'; graph: GraphDefinition; state: AgentState }
  | { type: 'node_completed'; node: { id: string; label: string }; duration_ms: number; state: AgentState }
  | { type: 'graph_completed'; state: AgentState }

type NodeStatus = 'idle' | 'completed'

export default function Route04StreamGraph({ apiBaseUrl }: Props) {
  const [graph, setGraph] = useState<GraphDefinition>({ nodes: [], edges: [] })
  const [nodeStatuses, setNodeStatuses] = useState<Record<string, NodeStatus>>({})
  const [steps, setSteps] = useState<string[]>([])
  const [eventLog, setEventLog] = useState<string[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const orderedNodes = useMemo(() => {
    return [...graph.nodes].sort((a, b) => (a.order ?? Number.MAX_SAFE_INTEGER) - (b.order ?? Number.MAX_SAFE_INTEGER))
  }, [graph.nodes])

  async function loadDefinition() {
    setError('')
    try {
      const response = await fetch(`${apiBaseUrl}/stream-graph/definition`)
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      const json = (await response.json()) as GraphDefinition
      setGraph(json)
      setNodeStatuses(Object.fromEntries(json.nodes.map((node) => [node.id, 'idle' as const])))
      setEventLog((prev) => [...prev, `Loaded definition: ${json.nodes.length} nodes, ${json.edges.length} edges`])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    }
  }

  async function runStreamGraph() {
    setLoading(true)
    setError('')
    setSteps([])
    setEventLog([])
    setNodeStatuses(Object.fromEntries(graph.nodes.map((node) => [node.id, 'idle' as const])))

    const url = `${apiBaseUrl}/stream-graph`

    try {
      await new Promise<void>((resolve, reject) => {
        const eventSource = new EventSource(url)

        eventSource.onmessage = (event) => {
          if (event.data === '[DONE]') {
            eventSource.close()
            resolve()
            return
          }

          try {
            const payload = JSON.parse(event.data) as StreamEvent

            if (payload.type === 'graph_init') {
              setGraph(payload.graph)
              setSteps(payload.state.steps)
              setNodeStatuses(
                Object.fromEntries(payload.graph.nodes.map((node) => [node.id, 'idle' as const])),
              )
              setEventLog((prev) => [...prev, 'Graph initialized'])
              return
            }

            if (payload.type === 'node_completed') {
              setSteps(payload.state.steps)
              setNodeStatuses((prev) => ({
                ...prev,
                [payload.node.id]: 'completed',
              }))
              setEventLog((prev) => [
                ...prev,
                `${payload.node.label} completed in ${payload.duration_ms.toFixed(0)} ms`,
              ])
              return
            }

            if (payload.type === 'graph_completed') {
              setSteps(payload.state.steps)
              setEventLog((prev) => [...prev, 'Graph completed'])
            }
          } catch {
            setEventLog((prev) => [...prev, `Non-JSON event: ${event.data}`])
          }
        }

        eventSource.onerror = () => {
          eventSource.close()
          reject(new Error('SSE connection closed or failed'))
        }
      })
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  function nodeClass(status: NodeStatus): string {
    if (status === 'completed') {
      return 'border-green-500 bg-green-50 text-green-800'
    }
    return 'border-slate-300 bg-white text-slate-900'
  }

  return (
    <section className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">04 Stream Graph Route</h2>

      <div className="flex flex-wrap gap-2">
        <button className="rounded border px-3 py-1" onClick={loadDefinition} type="button">
          Load /stream-graph/definition
        </button>
        <button className="rounded border px-3 py-1" onClick={runStreamGraph} type="button">
          {loading ? 'Running...' : 'Run /stream-graph'}
        </button>
      </div>

      {error && <p className="text-red-600">{error}</p>}

      <div className="overflow-x-auto rounded border p-3">
        <div className="flex min-w-max items-center gap-2">
          {orderedNodes.length === 0 && <p className="text-sm text-slate-500">No nodes yet. Load definition first.</p>}
          {orderedNodes.map((node, index) => (
            <div key={node.id} className="flex items-center gap-2">
              <div className={`rounded border px-3 py-2 text-sm font-medium ${nodeClass(nodeStatuses[node.id] ?? 'idle')}`}>
                <p>{node.label}</p>
                <p className="text-xs opacity-75">id: {node.id}</p>
              </div>
              {index < orderedNodes.length - 1 && <span className="text-slate-500">→</span>}
            </div>
          ))}
        </div>
      </div>

      <div className="space-y-1">
        <p className="text-sm font-medium">Completed Steps</p>
        <p className="rounded border px-2 py-1 text-sm">{steps.length > 0 ? steps.join(' -> ') : '-'}</p>
      </div>

      <div className="space-y-1">
        <p className="text-sm font-medium">Event Log</p>
        <pre className="max-h-48 overflow-auto rounded border p-2 text-xs whitespace-pre-wrap">
          {eventLog.length > 0 ? eventLog.join('\n') : 'No events yet.'}
        </pre>
      </div>
    </section>
  )
}
