import { useState } from 'react'
import Route02StreamText from './components/Route02StreamText'
import Route03StreamLlm from './components/Route03StreamLlm'
import Route04StreamGraph from './components/Route04StreamGraph'
import Route05StreamSpawn from './components/Route05StreamSpawn'
import Route06StreamGraphReview from './components/Route06StreamGraphReview'
import Route07StreamGraphInterrupt from './components/Route07StreamGraphInterrupt'
import Route08GraphqlSubscription from './components/Route08GraphqlSubscription'

function App() {
  const apiBaseUrl = 'http://127.0.0.1:53199'
  const [activeIndex, setActiveIndex] = useState(0)

  const cards = [
    {
      key: 'route-02',
      label: '02 Stream Text Route',
      content: <Route02StreamText apiBaseUrl={apiBaseUrl} />,
    },
    {
      key: 'route-03',
      label: '03 Stream LLM Route',
      content: <Route03StreamLlm apiBaseUrl={apiBaseUrl} />,
    },
    {
      key: 'route-04',
      label: '04 Stream Graph Route',
      content: <Route04StreamGraph apiBaseUrl={apiBaseUrl} />,
    },
    {
      key: 'route-05',
      label: '05 Stream Spawn Route',
      content: <Route05StreamSpawn apiBaseUrl={apiBaseUrl} />,
    },
    {
      key: 'route-06',
      label: '06 Stream Graph Review Route',
      content: <Route06StreamGraphReview apiBaseUrl={apiBaseUrl} />,
    },
    {
      key: 'route-07',
      label: '07 Stream Graph Interrupt Route',
      content: <Route07StreamGraphInterrupt apiBaseUrl={apiBaseUrl} />,
    },
    {
      key: 'route-08',
      label: '08 GraphQL Subscription Stream',
      content: <Route08GraphqlSubscription apiBaseUrl={apiBaseUrl} />,
    },
  ]

  const totalCards = cards.length

  function goPrev() {
    setActiveIndex((prev) => (prev - 1 + totalCards) % totalCards)
  }

  function goNext() {
    setActiveIndex((prev) => (prev + 1) % totalCards)
  }

  return (
    <main className="mx-auto max-w-6xl space-y-4 p-6">
      <p className="text-sm">API Base URL: {apiBaseUrl}</p>

      <section className="space-y-3 rounded border p-4">
        <div className="flex items-center justify-between gap-2">
          <p className="text-sm">
            Card {activeIndex + 1} / {totalCards}: {cards[activeIndex].label}
          </p>
          <div className="flex gap-2">
            <button className="rounded border px-3 py-1" onClick={goPrev} type="button">
              ← Prev
            </button>
            <button className="rounded border px-3 py-1" onClick={goNext} type="button">
              Next →
            </button>
          </div>
        </div>

        <div className="overflow-hidden">
          <div
            className="flex transition-transform duration-300 ease-out"
            style={{ transform: `translateX(-${activeIndex * 100}%)` }}
          >
            {cards.map((card) => (
              <div key={card.key} className="w-full shrink-0">
                {card.content}
              </div>
            ))}
          </div>
        </div>

        {/* Add more cards into `cards` array as you learn more routes */}
      </section>
    </main>
  )
}

export default App
