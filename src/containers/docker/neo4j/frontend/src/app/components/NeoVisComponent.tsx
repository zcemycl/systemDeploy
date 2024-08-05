"use client";
import React, { useState, useEffect } from "react";
import dynamic from "next/dynamic";
// import { NeovisConfig, NeoVisEvents } from "neovis.js";

// Dynamically import Neovis so that it only runs in the browser
const NeoVis = dynamic(() => import("neovis.js").then((mod) => mod.default), {
  ssr: false,
});
const loadNeovis = () =>
  import("neovis.js").then((module) => ({
    NeovisConfig: module.NeovisConfig,
    NeoVisEvents: module.NeoVisEvents,
  }));

const NeoVisComponent: React.FC = () => {
  const [vis, setVis] = useState<any>(null);
  const [visNetwork, setVisNetwork] = useState<any>(null);
  const [x, setX] = useState(0);
  const [y, setY] = useState(0);
  const [showMenu, setShowMenu] = useState(false);
  const [selectedNodes, setSelectedNodes] = useState<any>({});
  const [neo4jquery, setNeo4jquery] = useState("");
  const [shiftEnterPressed, setShiftEnterPressed] = useState(false);
  const [NeovisConfig, setNeovisConfig] = useState(null);
  const [NeoVisEvents, setNeoVisEvents] = useState(null);

  //   useEffect(() => {
  //     if (vis !== null) {
  //       vis.network?.on("click", () => {
  //         console.log("hello");
  //       });
  //       vis.registerOnEvent(NeoVisEvents.CompletionEvent, (e) => {
  //       });
  //     }
  //   }, [vis]);

  useEffect(() => {
    const initializeNeovis = async () => {
      // Import Neovis dynamically
      const {
        default: NeoVis,
        NeovisConfig,
        NeoVisEvents,
      } = await import("neovis.js");
      setNeovisConfig(NeovisConfig);
      setNeoVisEvents(NeoVisEvents);

      // Configuration for Neovis
      const config = {
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
      // Initialize Neovis
      const viz = new NeoVis(config);
      viz.render();
      setVis(viz);
      //   viz.registerOnEvent(NeoVisEvents.CompletionEvent, (e) => {
      //     console.log(e.recordCount);
      // viz.network?.on("click", (event) => {
      //   // console.log(event)
      //   console.log("click");
      //   setShowMenu(false);
      //   // console.log(event);
      //   // console.log(event.event.target.getBoundingClientRect());
      //   // console.log(event.event.center);
      //   // const rect = event.event.target.getBoundingClientRect();
      //   // let correctedX = event.event.center.x - rect.x;
      //   // let correctedY = event.event.center.y - rect.y;
      // });

      // viz.network?.on("oncontext", (event) => {
      //   event.event.preventDefault();
      //   console.log("oncontext");
      //   console.log(event);
      //   const rect = event.event.target.getBoundingClientRect();
      //   let correctedX = event.event.x;
      //   let correctedY = event.event.y;
      //   const nodeId = viz.network?.getNodeAt({
      //     x: correctedX - rect.x,
      //     y: correctedY - rect.y,
      //   });
      //   console.log(nodeId);
      //   setX(correctedX);
      //   setY(correctedY);
      //   setShowMenu(true);
      // });

      // viz.network?.on("select", (event) => {
      //   console.log("select");
      //   console.log(event);
      //   setShowMenu(false);
      //   // const selection = vis?.network?.getSelectedNodes();
      //   // console.log(selection);
      //   // const labels = viz?.nodes
      //   //   .get()
      //   //   .filter((node: any) => event.nodes?.includes(node.id))
      //   //   .map((node: any) => {
      //   //     return node.label;
      //   //   });
      //   // console.log(labels);
      //   // if (labels.length !== 0) {
      //   //   const cmd = `MATCH (p:Product) WHERE p.name="${labels[0]}" RETURN p;`;
      //   //   console.log(cmd);
      //   //   viz.renderWithCypher(cmd);
      //   // }
      // });
      //   });
    };

    if (typeof window !== "undefined") {
      initializeNeovis();
    }
  }, []);

  useEffect(() => {
    if (vis !== null && NeoVisEvents !== null) {
      vis.render();
      vis.registerOnEvent(NeoVisEvents.CompletionEvent, (e) => {
        // if (vis === null || vis.network === null) {
        //   console.log("error");
        // }
        vis.network?.on("click", (event) => {
          // console.log(event)
          console.log("click");
          setShowMenu(false);
          // console.log(event);
          // console.log(event.event.target.getBoundingClientRect());
          // console.log(event.event.center);
          // const rect = event.event.target.getBoundingClientRect();
          // let correctedX = event.event.center.x - rect.x;
          // let correctedY = event.event.center.y - rect.y;
        });

        vis.network?.on("oncontext", (event) => {
          event.event.preventDefault();
          console.log("oncontext");
          console.log(event);
          const rect = event.event.target.getBoundingClientRect();
          let correctedX = event.event.x;
          let correctedY = event.event.y;
          const nodeId = vis.network?.getNodeAt({
            x: correctedX - rect.x,
            y: correctedY - rect.y,
          });
          console.log(nodeId);
          setX(correctedX);
          setY(correctedY);
          setShowMenu(true);
        });

        vis.network?.on("select", (event) => {
          console.log("select");
          console.log(event);
          setShowMenu(false);
          // const selection = vis?.network?.getSelectedNodes();
          // console.log(selection);
          // const labels = vis?.nodes
          //   .get()
          //   .filter((node: any) => event.nodes?.includes(node.id))
          //   .map((node: any) => {
          //     return node.label;
          //   });
          // console.log(labels);
          // if (labels.length !== 0) {
          //   const cmd = `MATCH (p:Product) WHERE p.name="${labels[0]}" RETURN p;`;
          //   console.log(cmd);
          //   vis.renderWithCypher(cmd);
          // }
        });
      });
    }
  }, [vis]);

  useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Enter" && event.shiftKey) {
        setShiftEnterPressed(true);
      }
    };

    const handleKeyUp = (event: KeyboardEvent) => {
      if (event.key === "Enter" && event.shiftKey) {
        setShiftEnterPressed(false);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      window.removeEventListener("keyup", handleKeyUp);
    };
  }, []);

  return (
    <div className="flex items-center content-center align-middle flex-col justify-center space-y-2">
      <div id="viz" className="border border-white bg-white"></div>
      {showMenu && (
        <div
          className={`absolute bg-slate-600 text-white`}
          style={{ left: x, top: y }}
        >
          <h1>Hello</h1>
        </div>
      )}
      <textarea
        cols={40}
        className="bg-sky-800 rounded-md p-3 border border-white w-1/2 break-words"
        value={neo4jquery}
        onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => {
          console.log(e);
          const inputType = (e.nativeEvent as unknown as { inputType: string })
            .inputType;
          console.log(inputType);
          if (shiftEnterPressed && inputType === "insertLineBreak") {
            return;
          }
          setNeo4jquery(e.target.value);
        }}
        onKeyDown={(e: React.KeyboardEvent<HTMLTextAreaElement>) => {
          console.log(e);
          if (e.key === "Enter" && e.shiftKey) {
            console.log("Enter");
            const query = neo4jquery.replace(/(\r\n|\n|\r)/gm, " ");
            console.log(query, vis !== null);
            if (vis !== null) {
              vis.renderWithCypher(query);
            }
          }
        }}
      />
    </div>
  );
};

export default NeoVisComponent;
