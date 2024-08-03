"use client";
import { useEffect, useState } from "react";
import NeoVis, { NeovisConfig, NeoVisEvents } from "neovis.js";

export default function Home() {
  const [vis, setVis] = useState<any>(null);
  const [visNetwork, setVisNetwork] = useState<any>(null);
  const [x, setX] = useState(0);
  const [y, setY] = useState(0);
  const [showMenu, setShowMenu] = useState(false);
  const [selectedNodes, setSelectedNodes] = useState<any>({});

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
      viz.network?.on("click", () => {
        console.log("hello");
      });
      viz.registerOnEvent(NeoVisEvents.CompletionEvent, (e) => {
        console.log("hh");
        viz.network?.on("click", (event) => {
          // console.log(event)
          console.log("click");
          setShowMenu(false);
          // console.log(event);
          // console.log(event.event.target.getBoundingClientRect());
          // console.log(event.event.center);
          const rect = event.event.target.getBoundingClientRect();
          // let correctedX = event.event.center.x - rect.x;
          // let correctedY = event.event.center.y - rect.y;
        });

        viz.network?.on("oncontext", (event) => {
          event.event.preventDefault();
          console.log("oncontext");
          console.log(event);
          const rect = event.event.target.getBoundingClientRect();
          let correctedX = event.event.x;
          let correctedY = event.event.y;
          const nodeId = viz.network?.getNodeAt({
            x: correctedX - rect.x,
            y: correctedY - rect.y,
          });
          console.log(nodeId);
          setX(correctedX);
          setY(correctedY);
          setShowMenu(true);
        });

        viz.network?.on("select", (event) => {
          console.log("select");
          console.log(event);
          setShowMenu(false);
          // const selection = vis?.network?.getSelectedNodes();
          // console.log(selection);
          // const labels = viz?.nodes
          //   .get()
          //   .filter((node: any) => event.nodes?.includes(node.id))
          //   .map((node: any) => {
          //     return node.label;
          //   });
          // console.log(labels);
          // if (labels.length !== 0) {
          //   const cmd = `MATCH (p:Product) WHERE p.name="${labels[0]}" RETURN p;`;
          //   console.log(cmd);
          //   viz.renderWithCypher(cmd);
          // }
        });
      });

      console.log(viz.network);
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
        {showMenu && (
          <div
            className={`absolute bg-slate-600 text-white`}
            style={{ left: x, top: y }}
          >
            <h1>Hello</h1>
          </div>
        )}
      </div>
    </section>
  );
}
