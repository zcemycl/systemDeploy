"use client";
import { useState, useEffect } from "react";
import { useSearchParams, redirect } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/contexts/Auth";

export default function login() {
  const searchParams = useSearchParams();
  const { isAuthenticated, setIsAuthenticated, signIn } = useAuth();
  const [email, setEmail] = useState<string>("");
  const [sessionLoginId, setSessionLoginId] = useState<string>("");
  const urlCode = searchParams.get("code") ?? "";
  const urlEmail = searchParams.get("email") ?? "";

  const submitCallback = async function (email: string) {
    console.log(`${email}`);
    const resp = await signIn(email);
    console.log(resp);
  };

  useEffect(() => {
    if (urlCode && urlEmail && sessionLoginId) {
      console.log(urlCode);
      console.log(urlEmail);
    }
  }, [urlCode, urlEmail, sessionLoginId]);

  return (
    <section className="text-gray-400 bg-gray-900 body-font h-[83vh] sm:h-[90vh]">
      <div
        className="container px-2 py-24 mx-auto grid justify-items-center
        "
      >
        <div className="sm:w-1/2 flex flex-col mt-8 w-screen p-10">
          <h2 className="text-white text-lg mb-1 font-medium title-font">
            Login
          </h2>
          <p className="leading-relaxed mb-5">
            Please enter your email to retrieve a login link in your mailbox.
          </p>
          <div className="relative mb-4">
            <label htmlFor="email" className="leading-7 text-sm text-gray-400">
              Email
            </label>
            <input
              type="email"
              id="email"
              name="email"
              value={email}
              onChange={(e) => setEmail(e.currentTarget.value)}
              className="w-full bg-gray-800 rounded border border-gray-700 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-900 text-base outline-none text-gray-100 py-1 px-3 leading-8 transition-colors duration-200 ease-in-out"
            />
          </div>
          <button
            onClick={async () => await submitCallback(email)}
            className="text-white bg-indigo-500 border-0 py-2 px-6 focus:outline-none hover:bg-indigo-600 rounded text-lg"
          >
            Submit
          </button>
          <p className="text-xs text-gray-400 text-opacity-90 mt-3">
            Not registered? Submit a Demo Request Form at{" "}
            <Link href="/">Home Page</Link>.
          </p>
        </div>
      </div>
    </section>
  );
}
