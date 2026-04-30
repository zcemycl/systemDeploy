import Route02StreamText from './components/Route02StreamText'
import Route03StreamLlm from './components/Route03StreamLlm'

function App() {
  const apiBaseUrl = 'http://127.0.0.1:53199'

  return (
    <main className="mx-auto max-w-3xl space-y-4 p-6">
      <h1 className="text-2xl font-semibold">Hello World Frontend</h1>
      <p className="text-sm">API Base URL: {apiBaseUrl}</p>
      <Route02StreamText apiBaseUrl={apiBaseUrl} />
      <Route03StreamLlm apiBaseUrl={apiBaseUrl} />
    </main>
  )
}

export default App
