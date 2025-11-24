import { useState } from 'react'

interface StreamItem {
  id: number;
  category: string;
  value: number;
}

function App() {
  const [items, setItems] = useState<StreamItem[]>([]);
  const [loading, setLoading] = useState(false);

  async function fetchLarge() {
    setLoading(true);

    const response = await fetch(
      "/stream/large?query=test");

    const reader = response.body?.getReader();
    if (!reader) return;

    const decoder = new TextDecoder();

    while (true) {
      const { value, done } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value);
      const lines = chunk.trim().split("\n");
      console.log(chunk)

      for (const line of lines) {
        try {
          const obj: StreamItem = JSON.parse(line);
          setItems(prev => [...prev, obj]);
        } catch (e) {
          console.error("Invalid JSON", line);
        }
      }
    }

    setLoading(false);
  }

  return (
    <div style={{ padding: "20px" }}>
      <button onClick={fetchLarge} disabled={loading}>
        {loading ? "Loading..." : "Load Large Dataset"}
      </button>

      <ul style={{ marginTop: "20px" }}>
        {items.map((item, i) => (
          <li key={i}>
            {item.id} – {item.category} – {item.value}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App
