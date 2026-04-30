import { useState } from 'react'

type Props = {
  apiBaseUrl: string
}

export default function Route02StreamText({ apiBaseUrl }: Props) {
  const [output, setOutput] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  async function streamText() {
    setLoading(true)
    setError('')
    setOutput('')

    try {
      const response = await fetch(`${apiBaseUrl}/stream-text`)
      if (!response.ok || !response.body) {
        throw new Error(`HTTP ${response.status}`)
      }

      const reader = response.body.getReader()
      const decoder = new TextDecoder()

      while (true) {
        const { value, done } = await reader.read()
        if (done) break
        setOutput((prev) => prev + decoder.decode(value, { stream: true }))
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <section className="space-y-2 rounded border p-4">
      <h2 className="text-lg font-semibold">02 Stream Text Route</h2>
      <button className="rounded border px-3 py-1" onClick={streamText} type="button">
        {loading ? 'Streaming...' : 'Stream /stream-text'}
      </button>
      {error && <p className="text-red-600">{error}</p>}
      <pre className="max-h-48 overflow-auto text-sm whitespace-pre-wrap">{output}</pre>
    </section>
  )
}
