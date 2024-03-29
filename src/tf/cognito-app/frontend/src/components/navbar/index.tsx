"use client";
import React, { useRef, useEffect } from "react";
import { useTheme } from "next-themes";
import { useOpenBar, useAuth } from "@/contexts";
import Link from "next/link";
import { navbar_dropdown } from "@/constants/navbar-dropdown";
import { useRouter } from "next/navigation";
import { ProfileIcon, MoonIcon, SunIcon, LayerIcon, MenuIcon } from "@/icons";

export default interface NavBarProps {
  isDark: boolean;
}

function Button() {
  const { theme, setTheme } = useTheme();
  useEffect(() => {
    const currentTheme = localStorage.getItem("theme") ?? "dark";
    setTheme(currentTheme);
  }, []);
  return (
    <button
      onClick={() => {
        if (theme == "dark") {
          localStorage.setItem("theme", "light");
          setTheme("light");
        } else {
          localStorage.setItem("theme", "dark");
          setTheme("dark");
        }
      }}
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
      <div className="w-4 h-4 absolute left-1">
        <MoonIcon />
      </div>
      <div className="w-4 h-4 absolute dark:hidden right-1 border-black">
        <SunIcon />
      </div>
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
  const { isAuthenticated } = useAuth();
  const { isDropDownOpen, setIsDropDownOpen, isSideBarOpen, setIsSideBarOpen } =
    useOpenBar();
  const refDropDown = useRef(null);
  const refMenuBtn = useRef(null);
  const router = useRouter();

  useEffect(() => {
    const handleOutSideDropDownClick = ({ target }: Event) => {
      const isInsideDropDown = (
        refDropDown.current as unknown as HTMLDivElement
      ).contains(target as Node);
      const isInsideMenuBtn = (
        refMenuBtn.current as unknown as HTMLDivElement
      ).contains(target as Node);
      if (!isInsideDropDown) {
        if (isInsideMenuBtn) {
          return;
        }
        setIsDropDownOpen(false);
      }
    };

    window.addEventListener("mousedown", (e: Event) =>
      handleOutSideDropDownClick(e)
    );

    return () => {
      window.removeEventListener("mousedown", (e: Event) =>
        handleOutSideDropDownClick(e)
      );
    };
  }, [refDropDown, refMenuBtn]);
  return (
    <header className="text-gray-400 bg-gray-900 body-font fixed w-full">
      <div className="container justify-between mx-auto flex flex-wrap p-5 flex-row items-center">
        <div className="container justify-between flex">
          <Link
            href="/"
            className="flex title-font font-medium items-center text-white mb-0"
          >
            <LayerIcon />
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
              ref={refMenuBtn}
              data-collapse-toggle="navbar-dropdown"
              type="button"
              className="inline-flex items-center p-2 w-10 h-10 mr-1 justify-center text-sm text-gray-500 rounded-lg md:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
              aria-controls="navbar-dropdown"
              aria-expanded="false"
              onClick={() => setIsDropDownOpen(!isDropDownOpen)}
            >
              <span className="sr-only">Open main menu</span>
              <MenuIcon />
            </button>
            <button
              type="button"
              data-testid="icon-login-btn"
              onClick={() => {
                if (isAuthenticated) {
                  setIsSideBarOpen(!isSideBarOpen);
                } else {
                  router.push("/login");
                }
              }}
              className={`inline-flex items-center p-0 w-10 h-10 justify-center text-sm border-white text-gray-500 rounded-full focus:ring-2 hover:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600 ${isSideBarOpen ? "pointer-events-none" : ""} cursor-pointer`}
            >
              <ProfileIcon />
            </button>
          </div>
        </div>
        <div className="flex w-full justify-end h-0" ref={refDropDown}>
          <div
            className={`items-center z-10 justify-between w-1/3 sm:w-1/4 md:hidden transition-transform ${isDropDownOpen ? "scale-y-100" : "scale-y-0"}`}
            id="navbar-dropdown"
          >
            <ul className="flex flex-col p-2 md:p-0 mt-1 font-medium border border-gray-100 rounded-lg bg-gray-50 md:space-x-8 rtl:space-x-reverse dark:bg-gray-800  dark:border-gray-700">
              <li>
                {navbar_dropdown.map((keyValue) => {
                  return (
                    <Link
                      href={keyValue.path}
                      key={keyValue.name}
                      className="block py-1 px-3 text-right text-gray-900 rounded hover:bg-blue-700 dark:text-white dark:hover:bg-gray-700 dark:hover:text-white  dark:border-gray-700"
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
      </div>
    </header>
  );
}
