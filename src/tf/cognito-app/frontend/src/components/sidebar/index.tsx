"use client";
import { useAuth } from "@/contexts/Auth";
import React from "react";
import { sidebar_constant } from "@/constants/sidebar";

export default function SideBar({ children }: { children?: React.ReactNode }) {
  return (
    <>
      {children}

      <div className="fixed top-0 left-0 w-full mt-[4.5rem]">
        <div className="container relative items-center mx-auto">
          <div
            id="default-sidebar"
            className="flex absolute z-0 w-64 right-0"
            aria-label="Sidebar"
          >
            <div className="min-h-screen z-0 px-3 py-4 w-64 bg-gray-50 dark:bg-gray-800">
              <ul className="space-y-2 font-medium">
                {sidebar_constant.map((keyValue) => {
                  return (
                    <li>
                      <a
                        href={keyValue.path}
                        key={keyValue.name}
                        className="flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group"
                      >
                        {keyValue.icon}
                        <span className="ms-3">{keyValue.name}</span>
                      </a>
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
