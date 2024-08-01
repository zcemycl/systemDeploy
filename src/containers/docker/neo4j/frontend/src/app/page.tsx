"use client";
import { useEffect, useState } from "react";
import NeoVis, { NeovisConfig, NeoVisEvents } from "neovis.js";

export default function Home() {
  const [vis, setVis] = useState<any>(null);

  useEffect(() => {
    const draw = () => {
      const config: NeovisConfig = {
        containerId: "viz",
        neo4j: {
          serverUrl: "bolt://localhost:7687",
          serverPassword: "password",
          serverUser: "neo4j",
        },
        visConfig: {
          nodes: {
            shape: "dot",
            borderWidth: 1.5,
            color: {
              background: "lightgray",
              border: "gray",
              highlight: {
                border: "#a42a04",
                background: "lightgray",
              },
            },
            font: {
              strokeWidth: 7.5,
            },
          },
          edges: {
            arrows: { to: { enabled: true } },
          },
          physics: {
            enabled: true,
            // use the forceAtlas2Based solver to compute node positions
            solver: "forceAtlas2Based",
            forceAtlas2Based: {
              gravitationalConstant: -75,
            },
            repulsion: {
              centralGravity: 0.01,
              springLength: 200,
            },
          },
          interaction: { multiselect: true }, // allows for multi-select using a long press or cmd-click
          layout: { randomSeed: 1337 },
        },
        labels: {
          Product: {
            label: "name",
          },
          Keyword: {
            label: "name",
          },
        },
        relationships: {
          CONTAINS: {
            // label: "CONTAINS",
            [NeoVis.NEOVIS_ADVANCED_CONFIG]: {
              function: {
                label: (edge: { type: any }) => edge.type,
              },
            },
          },
        },
        initialCypher:
          "MATCH (p:Product)-[c:CONTAINS]->(k:Keyword) RETURN p,k,c LIMIT 25",
      };
      const viz = new NeoVis(config);
      viz.render();
      setVis(viz);
    };
    draw();
  }, []);

  return (
    <section
      className="bg-slate-700 min-w-full min-h-screen
      text-white p-5"
    >
      <div className="flex items-center content-center align-middle flex-row justify-center">
        <div id="viz" className="border border-white bg-white"></div>
      </div>
    </section>
  );
}
