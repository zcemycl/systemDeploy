"use client";
import React, { useState } from "react";
import { useTheme } from "next-themes";
import Link from "next/link";
import { navbar_dropdown } from "@/constants/navbar-dropdown";

export default interface NavBarProps {
  isDark: boolean;
}

function Button() {
  const { systemTheme, theme, setTheme } = useTheme();
  const currentTheme = theme === "system" ? systemTheme : theme;

  return (
    <button
      onClick={() => (theme == "dark" ? setTheme("light") : setTheme("dark"))}
      className="
            w-12
            h-6
            rounded-full
            p-1
            mr-2
            bg-blue-700
            dark:bg-gray-600
            relative
            transition-colors
            duration-500
            ease-in
            focus:outline-none
            focus:ring-2
            focus:ring-blue-700
            dark:focus:ring-blue-600
            focus:border-transparent
            flex-end
        "
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="currentColor"
        className="w-4 h-4 absolute left-1"
      >
        <path
          fillRule="evenodd"
          d="M9.528 1.718a.75.75 0 0 1 .162.819A8.97 8.97 0 0 0 9 6a9 9 0 0 0 9 9 8.97 8.97 0 0 0 3.463-.69.75.75 0 0 1 .981.98 10.503 10.503 0 0 1-9.694 6.46c-5.799 0-10.5-4.7-10.5-10.5 0-4.368 2.667-8.112 6.46-9.694a.75.75 0 0 1 .818.162Z"
          clipRule="evenodd"
        />
      </svg>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="orange"
        className="w-4 h-4 absolute dark:hidden right-1 border-black"
      >
        <path d="M12 2.25a.75.75 0 0 1 .75.75v2.25a.75.75 0 0 1-1.5 0V3a.75.75 0 0 1 .75-.75ZM7.5 12a4.5 4.5 0 1 1 9 0 4.5 4.5 0 0 1-9 0ZM18.894 6.166a.75.75 0 0 0-1.06-1.06l-1.591 1.59a.75.75 0 1 0 1.06 1.061l1.591-1.59ZM21.75 12a.75.75 0 0 1-.75.75h-2.25a.75.75 0 0 1 0-1.5H21a.75.75 0 0 1 .75.75ZM17.834 18.894a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 1 0-1.061 1.06l1.59 1.591ZM12 18a.75.75 0 0 1 .75.75V21a.75.75 0 0 1-1.5 0v-2.25A.75.75 0 0 1 12 18ZM7.758 17.303a.75.75 0 0 0-1.061-1.06l-1.591 1.59a.75.75 0 0 0 1.06 1.061l1.591-1.59ZM6 12a.75.75 0 0 1-.75.75H3a.75.75 0 0 1 0-1.5h2.25A.75.75 0 0 1 6 12ZM6.697 7.757a.75.75 0 0 0 1.06-1.06l-1.59-1.591a.75.75 0 0 0-1.061 1.06l1.59 1.591Z" />
      </svg>
      <div
        id="toggle"
        className="
            rounded-full
            w-4
            h-4
            bg-white
            dark:bg-blue-500
            relative
            ml-0
            dark:ml-6
            pointer-events-none
            transition-all
            duration-300
            ease-out
        "
      ></div>
    </button>
  );
}

export default function NavBar() {
  const [isDropdownOpen, setIsDropdownOpen] = useState<boolean>(false);
  return (
    <header className="text-gray-400 bg-gray-900 body-font fixed w-full">
      <div className="container justify-between mx-auto flex flex-wrap p-5 flex-row items-center">
        <div className="container justify-between flex">
          <Link
            href="/"
            className="flex title-font font-medium items-center text-white mb-0"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              stroke="currentColor"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              className="w-10 h-10 text-white p-2 bg-indigo-500 rounded-full"
              viewBox="0 0 24 24"
            >
              <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path>
            </svg>
            <span className="ml-3 text-xl">Drugig</span>
          </Link>
          <nav className="hidden md:mr-auto md:ml-4 md:py-1 md:pl-4 md:border-l md:border-gray-700	md:flex md:flex-wrap items-center text-base justify-center">
            {navbar_dropdown.map((keyValue) => {
              return (
                <Link
                  href={keyValue.path}
                  key={keyValue.name}
                  className="mr-5 hover:text-white"
                  aria-current="page"
                >
                  {keyValue.name}
                </Link>
              );
            })}
          </nav>
          <div className="ml-4 py-1 pl-4 border-l border-gray-700	flex items-center text-base justify-center">
            <Button />
            <button
              data-collapse-toggle="navbar-dropdown"
              type="button"
              className="inline-flex items-center p-2 w-10 h-10 justify-center text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
              aria-controls="navbar-dropdown"
              aria-expanded="false"
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
            >
              <span className="sr-only">Open main menu</span>
              <svg
                className="w-5 h-5"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 17 14"
              >
                <path
                  stroke="currentColor"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M1 1h15M1 7h15M1 13h15"
                />
              </svg>
            </button>
          </div>
        </div>
        {isDropdownOpen && (
          <div className="flex w-full justify-end">
            <div
              className="items-center justify-between w-1/4 md:hidden"
              id="navbar-dropdown"
            >
              <ul className="flex flex-col p-2 md:p-0 mt-1 font-medium border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse md:flex-row md:mt-0 md:border-0 md:bg-white dark:bg-gray-800 md:dark:bg-gray-900 dark:border-gray-700">
                <li>
                  {navbar_dropdown.map((keyValue) => {
                    return (
                      <Link
                        href={keyValue.path}
                        key={keyValue.name}
                        className="block py-1 px-3 text-right text-gray-900 rounded hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 md:p-0 md:dark:hover:text-blue-500 dark:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent dark:border-gray-700"
                        aria-current="page"
                      >
                        {keyValue.name}
                      </Link>
                    );
                  })}
                </li>
              </ul>
            </div>
          </div>
        )}
      </div>
    </header>
  );
}
