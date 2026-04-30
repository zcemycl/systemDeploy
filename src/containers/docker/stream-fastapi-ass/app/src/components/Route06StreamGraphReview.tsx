import { useMemo, useState } from 'react'

type Props = {
  apiBaseUrl: string
}

type GraphNode = {
  id: string
  label: string
  order?: number
  is_review?: boolean
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
  b_output?: string
  c_output?: string
  d_output?: string
  review_result?: { action: string; comment?: string | null } | null
}

type ReviewRequiredEvent = {
  type: 'review_required'
  run_id: string
  node: { id: string; label: string; is_review?: boolean }
  payload: { review_text: string }
  allowed_actions: string[]
}

type ReviewSubmittedEvent = {
  type: 'review_submitted'
  run_id: string
  node: { id: string; label: string; is_review?: boolean }
  decision: { action: string; comment?: string | null }
  state: AgentState
}

type StreamEvent =
  | { type: 'graph_init'; run_id: string; graph: GraphDefinition; state: AgentState }
  | {
      type: 'node_completed'
      run_id: string
      node: { id: string; label: string; is_review?: boolean }
      duration_ms: number
      state: AgentState
    }
  | { type: 'graph_completed'; run_id: string; state: AgentState; stopped_reason?: string }
  | { type: 'stream_error'; run_id: string; message: string }
  | ReviewRequiredEvent
  | ReviewSubmittedEvent

type NodeStatus = 'idle' | 'running' | 'completed'

export default function Route06StreamGraphReview({ apiBaseUrl }: Props) {
  const [graph, setGraph] = useState<GraphDefinition>({ nodes: [], edges: [] })
  const [nodeStatuses, setNodeStatuses] = useState<Record<string, NodeStatus>>({})
  const [steps, setSteps] = useState<string[]>([])
  const [eventLog, setEventLog] = useState<string[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [runId, setRunId] = useState('')
  const [pendingReview, setPendingReview] = useState<ReviewRequiredEvent | null>(null)
  const [reviewComment, setReviewComment] = useState('')
  const [editedText, setEditedText] = useState('')
  const [submittingDecision, setSubmittingDecision] = useState(false)

  const orderedNodes = useMemo(() => {
    return [...graph.nodes].sort((a, b) => (a.order ?? Number.MAX_SAFE_INTEGER) - (b.order ?? Number.MAX_SAFE_INTEGER))
  }, [graph.nodes])

  async function loadDefinition() {
    setError('')
    try {
      const response = await fetch(`${apiBaseUrl}/stream-graph-06/definition`)
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const json = (await response.json()) as GraphDefinition
      setGraph(json)
      setNodeStatuses(Object.fromEntries(json.nodes.map((node) => [node.id, 'idle' as const])))
      setEventLog((prev) => [...prev, `Loaded definition: ${json.nodes.length} nodes, ${json.edges.length} edges`])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    }
  }

  async function runGraph() {
    setLoading(true)
    setError('')
    setSteps([])
    setEventLog([])
    setRunId('')
    setPendingReview(null)
    setReviewComment('')
    setEditedText('')
    setNodeStatuses(Object.fromEntries(graph.nodes.map((node) => [node.id, 'idle' as const])))

    try {
      await new Promise<void>((resolve, reject) => {
        const eventSource = new EventSource(`${apiBaseUrl}/stream-graph-06`)

        eventSource.onmessage = (event) => {
          if (event.data === '[DONE]') {
            eventSource.close()
            resolve()
            return
          }

          try {
            const payload = JSON.parse(event.data) as StreamEvent
            if (payload.type === 'graph_init') {
              setRunId(payload.run_id)
              setGraph(payload.graph)
              setSteps(payload.state.steps)
              setNodeStatuses(Object.fromEntries(payload.graph.nodes.map((node) => [node.id, 'idle' as const])))
              setEventLog((prev) => [...prev, `Graph initialized (run_id: ${payload.run_id})`])
              return
            }

            if (payload.type === 'review_required') {
              setPendingReview(payload)
              setEditedText(payload.payload.review_text ?? '')
              setNodeStatuses((prev) => ({ ...prev, [payload.node.id]: 'running' }))
              setEventLog((prev) => [...prev, `${payload.node.label} waiting for your decision`])
              return
            }

            if (payload.type === 'review_submitted') {
              setPendingReview(null)
              setSteps(payload.state.steps)
              setEventLog((prev) => [...prev, `${payload.node.label}: ${payload.decision.action}`])
              return
            }

            if (payload.type === 'node_completed') {
              setSteps(payload.state.steps)
              setNodeStatuses((prev) => ({ ...prev, [payload.node.id]: 'completed' }))
              setEventLog((prev) => [
                ...prev,
                `${payload.node.label}${payload.node.is_review ? ' (review)' : ''} completed in ${payload.duration_ms.toFixed(0)} ms`,
              ])
              return
            }

            if (payload.type === 'graph_completed') {
              setSteps(payload.state.steps)
              if (payload.stopped_reason) {
                setEventLog((prev) => [...prev, `Graph stopped: ${payload.stopped_reason}`])
              } else {
                setEventLog((prev) => [...prev, 'Graph completed'])
              }
              return
            }

            if (payload.type === 'stream_error') {
              setError(payload.message)
              setEventLog((prev) => [...prev, `Stream error: ${payload.message}`])
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

  function nodeClass(status: NodeStatus, isReview?: boolean): string {
    if (status === 'running') return 'border-blue-500 bg-blue-50 text-blue-800'
    if (status === 'completed') return isReview ? 'border-purple-500 bg-purple-50 text-purple-800' : 'border-green-500 bg-green-50 text-green-800'
    return isReview ? 'border-purple-300 bg-purple-25 text-purple-900' : 'border-slate-300 bg-white text-slate-900'
  }

  async function submitDecision(action: 'approve' | 'reject' | 'edit') {
    if (!pendingReview || !runId) return
    setSubmittingDecision(true)
    setError('')
    try {
      const response = await fetch(`${apiBaseUrl}/stream-graph-06/review-decision`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          run_id: runId,
          node_id: pendingReview.node.id,
          action,
          edited_text: action === 'edit' ? editedText : null,
          comment: reviewComment || null,
        }),
      })
      if (!response.ok) {
        const body = await response.text()
        throw new Error(`HTTP ${response.status}: ${body}`)
      }
      setEventLog((prev) => [...prev, `Submitted ${action} for ${pendingReview.node.label}`])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setSubmittingDecision(false)
    }
  }

  return (
    <section className="space-y-3 rounded border p-4">
      <h2 className="text-lg font-semibold">06 Stream Graph Review Route</h2>
      <div className="flex flex-wrap gap-2">
        <button className="rounded border px-3 py-1" onClick={loadDefinition} type="button">
          Load /stream-graph-06/definition
        </button>
        <button className="rounded border px-3 py-1" onClick={runGraph} type="button">
          {loading ? 'Running...' : 'Run /stream-graph-06'}
        </button>
      </div>

      {error && <p className="text-red-600">{error}</p>}
      {runId && <p className="text-xs text-slate-500">run_id: {runId}</p>}

      <div className="overflow-x-auto rounded border p-3">
        <div className="flex min-w-max items-center gap-2">
          {orderedNodes.length === 0 && <p className="text-sm text-slate-500">No nodes yet. Load definition first.</p>}
          {orderedNodes.map((node, index) => (
            <div key={node.id} className="flex items-center gap-2">
              <div className={`rounded border px-3 py-2 text-sm font-medium ${nodeClass(nodeStatuses[node.id] ?? 'idle', node.is_review)}`}>
                <p>{node.label}</p>
                <p className="text-xs opacity-75">
                  id: {node.id}
                  {node.is_review ? ' (review)' : ''}
                </p>
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

      {pendingReview && (
        <div className="space-y-2 rounded border border-blue-300 bg-blue-50 p-3">
          <p className="text-sm font-semibold">Review Required: {pendingReview.node.label}</p>
          <p className="text-xs text-slate-600">Action needed before stream can continue.</p>
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
            <span className="mb-1 block text-sm">Comment (optional)</span>
            <input
              className="w-full rounded border p-2"
              value={reviewComment}
              onChange={(e) => setReviewComment(e.target.value)}
            />
          </label>
          <div className="flex flex-wrap gap-2">
            <button
              className="rounded border px-3 py-1"
              onClick={() => submitDecision('approve')}
              type="button"
              disabled={submittingDecision}
            >
              Approve
            </button>
            <button
              className="rounded border px-3 py-1"
              onClick={() => submitDecision('edit')}
              type="button"
              disabled={submittingDecision}
            >
              Edit + Submit
            </button>
            <button
              className="rounded border px-3 py-1"
              onClick={() => submitDecision('reject')}
              type="button"
              disabled={submittingDecision}
            >
              Reject
            </button>
          </div>
        </div>
      )}

      <div className="space-y-1">
        <p className="text-sm font-medium">Event Log</p>
        <pre className="max-h-48 overflow-auto rounded border p-2 text-xs whitespace-pre-wrap">
          {eventLog.length > 0 ? eventLog.join('\n') : 'No events yet.'}
        </pre>
      </div>
    </section>
  )
}
