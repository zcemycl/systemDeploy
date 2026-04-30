import { useMemo, useState } from 'react'

type Props = {
  apiBaseUrl: string
}

type GraphNode = {
  id: string
  label: string
  order?: number
  is_spawn?: boolean
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

type SpawnState = {
  input_count: number
  fail_ids: number[]
  summary: {
    total: number
    b_passed: number
    b_failed: number
    d_processed: number
  }
}

type SpawnItemEvent = {
  type: 'spawn_item'
  node_id: 'b' | 'd'
  item: Record<string, unknown>
}

type SpawnEvent =
  | { type: 'graph_init'; graph: GraphDefinition; state: SpawnState }
  | { type: 'node_started'; node: { id: string; label: string }; spawn_total?: number; state: SpawnState }
  | { type: 'node_completed'; node: { id: string; label: string }; duration_ms: number; state: SpawnState }
  | SpawnItemEvent
  | { type: 'graph_completed'; state: SpawnState }

type NodeStatus = 'idle' | 'running' | 'completed'

export default function Route05StreamSpawn({ apiBaseUrl }: Props) {
  const [inputCount, setInputCount] = useState(5)
  const [failIdsText, setFailIdsText] = useState('5')
  const [graph, setGraph] = useState<GraphDefinition>({ nodes: [], edges: [] })
  const [nodeStatuses, setNodeStatuses] = useState<Record<string, NodeStatus>>({})
  const [state, setState] = useState<SpawnState | null>(null)
  const [bItems, setBItems] = useState<Record<string, unknown>[]>([])
  const [dItems, setDItems] = useState<Record<string, unknown>[]>([])
  const [eventLog, setEventLog] = useState<string[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const orderedNodes = useMemo(
    () =>
      [...graph.nodes].sort(
        (a, b) => (a.order ?? Number.MAX_SAFE_INTEGER) - (b.order ?? Number.MAX_SAFE_INTEGER),
      ),
    [graph.nodes],
  )

  function resetRunState() {
    setBItems([])
    setDItems([])
    setEventLog([])
    setState(null)
    setNodeStatuses(Object.fromEntries(graph.nodes.map((node) => [node.id, 'idle' as const])))
  }

  async function runSpawnGraph() {
    setLoading(true)
    setError('')
    resetRunState()

    const url = `${apiBaseUrl}/stream-spawn?input_count=${inputCount}&fail_ids=${encodeURIComponent(failIdsText)}`

    try {
      await new Promise<void>((resolve, reject) => {
        const eventSource = new EventSource(url)

        eventSource.onmessage = (event) => {
          if (event.data === '[DONE]') {
            eventSource.close()
            resolve()
            return
          }

          const payload = JSON.parse(event.data) as SpawnEvent

          if (payload.type === 'graph_init') {
            setGraph(payload.graph)
            setState(payload.state)
            setNodeStatuses(Object.fromEntries(payload.graph.nodes.map((node) => [node.id, 'idle' as const])))
            setEventLog((prev) => [...prev, 'Graph initialized'])
            return
          }

          if (payload.type === 'node_started') {
            setState(payload.state)
            setNodeStatuses((prev) => ({ ...prev, [payload.node.id]: 'running' }))
            setEventLog((prev) => [
              ...prev,
              payload.spawn_total
                ? `${payload.node.label} started with ${payload.spawn_total} spawned items`
                : `${payload.node.label} started`,
            ])
            return
          }

          if (payload.type === 'spawn_item') {
            if (payload.node_id === 'b') {
              setBItems((prev) => [...prev, payload.item])
            } else if (payload.node_id === 'd') {
              setDItems((prev) => [...prev, payload.item])
            }
            return
          }

          if (payload.type === 'node_completed') {
            setState(payload.state)
            setNodeStatuses((prev) => ({ ...prev, [payload.node.id]: 'completed' }))
            setEventLog((prev) => [...prev, `${payload.node.label} completed in ${payload.duration_ms.toFixed(0)} ms`])
            return
          }

          if (payload.type === 'graph_completed') {
            setState(payload.state)
            setEventLog((prev) => [...prev, 'Graph completed'])
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
    if (status === 'running') return 'border-blue-500 bg-blue-50 text-blue-800'
    if (status === 'completed') return 'border-green-500 bg-green-50 text-green-800'
    return 'border-slate-300 bg-white text-slate-900'
  }

  return (
    <section className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">05 Stream Spawn Route</h2>

      <div className="grid gap-2 sm:grid-cols-2">
        <label className="space-y-1">
          <span className="block text-sm">Input Count</span>
          <input
            className="w-full rounded border px-2 py-1"
            type="number"
            min={1}
            max={100}
            value={inputCount}
            onChange={(e) => setInputCount(Number(e.target.value || 1))}
          />
        </label>
        <label className="space-y-1">
          <span className="block text-sm">Fail IDs (comma separated)</span>
          <input
            className="w-full rounded border px-2 py-1"
            value={failIdsText}
            onChange={(e) => setFailIdsText(e.target.value)}
            placeholder="e.g. 5 or 2,5,9"
          />
        </label>
      </div>

      <button className="rounded border px-3 py-1" onClick={runSpawnGraph} type="button">
        {loading ? 'Running...' : 'Run /stream-spawn'}
      </button>

      {error && <p className="text-red-600">{error}</p>}

      <div className="overflow-x-auto rounded border p-3">
        <div className="flex min-w-max items-center gap-2">
          {orderedNodes.length === 0 && <p className="text-sm text-slate-500">Run graph to load dynamic nodes.</p>}
          {orderedNodes.map((node, index) => (
            <div key={node.id} className="flex items-center gap-2">
              <div className={`rounded border px-3 py-2 text-sm font-medium ${nodeClass(nodeStatuses[node.id] ?? 'idle')}`}>
                <p>{node.label}</p>
                <p className="text-xs opacity-75">
                  id: {node.id}
                  {node.is_spawn ? ' (spawn)' : ''}
                </p>
              </div>
              {index < orderedNodes.length - 1 && <span className="text-slate-500">→</span>}
            </div>
          ))}
        </div>
      </div>

      <div className="grid gap-2 sm:grid-cols-3">
        <div className="rounded border p-2 text-sm">
          <p className="font-medium">Summary</p>
          <p>Total: {state?.summary.total ?? 0}</p>
          <p>B Passed: {state?.summary.b_passed ?? 0}</p>
          <p>B Failed: {state?.summary.b_failed ?? 0}</p>
          <p>D Processed: {state?.summary.d_processed ?? 0}</p>
        </div>
        <div className="rounded border p-2 text-sm">
          <p className="font-medium">B Spawn Items ({bItems.length})</p>
          <pre className="max-h-40 overflow-auto text-xs whitespace-pre-wrap">
            {bItems.length > 0 ? JSON.stringify(bItems, null, 2) : 'No items yet.'}
          </pre>
        </div>
        <div className="rounded border p-2 text-sm">
          <p className="font-medium">D Spawn Items ({dItems.length})</p>
          <pre className="max-h-40 overflow-auto text-xs whitespace-pre-wrap">
            {dItems.length > 0 ? JSON.stringify(dItems, null, 2) : 'No items yet.'}
          </pre>
        </div>
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
