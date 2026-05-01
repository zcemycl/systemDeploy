import { useState } from 'react'

type Props = {
  apiBaseUrl: string
}

export default function Route03StreamLlm({ apiBaseUrl }: Props) {
  const [prompt, setPrompt] = useState('Write a short poem about streaming APIs.')
  const [mode, setMode] = useState<'stream' | 'ainvoke'>('stream')
  const [output, setOutput] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function runLlm() {
    setLoading(true)
    setError('')
    setOutput('')

    const url = `${apiBaseUrl}/stream-llm?prompt=${encodeURIComponent(prompt)}&mode=${mode}`

    try {
      if (mode === 'ainvoke') {
        const response = await fetch(url)
        if (!response.ok) {
          const body = await response.text()
          throw new Error(`HTTP ${response.status}: ${body}`)
        }
        const json = (await response.json()) as { content?: string }
        setOutput(json.content ?? '')
        return
      }

      await new Promise<void>((resolve, reject) => {
        const eventSource = new EventSource(url)

        eventSource.onmessage = (event) => {
          if (event.data === '[DONE]') {
            eventSource.close()
            resolve()
            return
          }
          setOutput((prev) => prev + event.data)
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

  return (
    <section className="space-y-2 rounded border p-4">
      <h2 className="text-lg font-semibold">03 Stream LLM Route</h2>
      <label className="block">
        <span className="mb-1 block text-sm">Prompt</span>
        <textarea
          className="w-full rounded border p-2"
          value={prompt}
          onChange={(e) => setPrompt(e.target.value)}
          rows={3}
        />
      </label>

      <label className="block">
        <span className="mb-1 block text-sm">Mode</span>
        <select
          className="rounded border p-1"
          value={mode}
          onChange={(e) => setMode(e.target.value as 'stream' | 'ainvoke')}
        >
          <option value="stream">stream</option>
          <option value="ainvoke">ainvoke</option>
        </select>
      </label>

      <button className="rounded border px-3 py-1" onClick={runLlm} type="button">
        {loading ? 'Running...' : 'Run /stream-llm'}
      </button>

      {error && <p className="text-red-600">{error}</p>}
      <pre className="max-h-56 overflow-auto text-sm whitespace-pre-wrap">{output}</pre>
    </section>
  )
}
