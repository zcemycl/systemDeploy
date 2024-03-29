"use client";
import React, { useRef, useEffect } from "react";
import { sidebar_constant } from "@/constants/sidebar";
import { useOpenBar } from "@/contexts";
import Link from "next/link";

export default function SideBar({ children }: { children?: React.ReactNode }) {
  const { isSideBarOpen, setIsSideBarOpen } = useOpenBar();
  const refSideBar = useRef(null);

  useEffect(() => {
    const handleOutSideSideBarClick = ({ target }: Event) => {
      const isInsideSideBar = (
        refSideBar.current as unknown as HTMLDivElement
      ).contains(target as Node);
      if (!isInsideSideBar) {
        setIsSideBarOpen(false);
      }
    };
    window.addEventListener("mousedown", (e: Event) =>
      handleOutSideSideBarClick(e)
    );

    return () => {
      window.removeEventListener("mousedown", (e: Event) =>
        handleOutSideSideBarClick(e)
      );
    };
  }, [refSideBar]);

  return (
    <>
      {children}

      <div className="fixed top-0 left-0 w-full mt-[4.5rem]" ref={refSideBar}>
        <div className="container relative items-center mx-auto">
          <div
            id="default-sidebar"
            className={`flex absolute z-0 w-64 right-0 transition-transform ${isSideBarOpen ? "" : "translate-y-full"}`}
            aria-label="Sidebar"
          >
            <div className="min-h-screen z-0 px-3 py-4 w-64 bg-gray-50 dark:bg-gray-800">
              <ul className="space-y-2 font-medium">
                {sidebar_constant.map((keyValue) => {
                  return (
                    <li key={keyValue.name}>
                      <Link
                        href={keyValue.path}
                        key={keyValue.name}
                        data-testid={keyValue.testid}
                        className="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
                      >
                        {keyValue.icon}
                        <span className="ms-3">{keyValue.name}</span>
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
