import { useState } from 'react'

type RootResponse = {
  message: string
  learning_order: string[]
}

type Props = {
  apiBaseUrl: string
}

export default function Route01Root({ apiBaseUrl }: Props) {
  const [data, setData] = useState<RootResponse | null>(null)
  const [error, setError] = useState<string>('')
  const [loading, setLoading] = useState(false)

  async function loadRoot() {
    setLoading(true)
    setError('')
    try {
      const response = await fetch(`${apiBaseUrl}/`)
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`)
      }
      const json = (await response.json()) as RootResponse
      setData(json)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setLoading(false)
    }
  }

  return (
    <section className="space-y-2 rounded border p-4">
      <h2 className="text-lg font-semibold">01 Root Route</h2>
      <button className="rounded border px-3 py-1" onClick={loadRoot} type="button">
        {loading ? 'Loading...' : 'Fetch /'}
      </button>
      {error && <p className="text-red-600">{error}</p>}
      {data && <pre className="overflow-x-auto text-sm">{JSON.stringify(data, null, 2)}</pre>}
    </section>
  )
}
