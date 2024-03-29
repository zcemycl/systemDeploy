"use client";
import { useState, useEffect } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/contexts";

type IMode = "login" | "verify";

export default function Login() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const {
    isAuthenticated,
    setIsAuthenticated,
    signIn,
    answerCustomChallenge,
    setCredentials,
  } = useAuth();
  const [email, setEmail] = useState<string>("");
  const urlCode = searchParams.get("code") ?? "";
  const urlEmail = decodeURIComponent(searchParams.get("email") ?? "");
  const [mode, setMode] = useState<string>("");

  const submitCallback = async function (email: string) {
    const resp = await signIn(email);
    localStorage.setItem("cognito_user", JSON.stringify(resp));
    localStorage.setItem("mode", "verify");
    localStorage.setItem("email", email);
    router.push("/prelogin");
  };

  useEffect(() => {
    const curMode = localStorage.getItem("mode") ?? "login";
    setMode(curMode);
    const curEmail = localStorage.getItem("email") ?? "";
    setEmail(curEmail);
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      router.push("/");
    }
  }, [isAuthenticated]);

  useEffect(() => {
    async function respondAuthChallege(
      urlCode: string,
      urlEmail: string,
      isAuthenticated: boolean
    ) {
      const cognito_user = JSON.parse(
        localStorage.getItem("cognito_user") as string
      );
      if (
        urlCode &&
        urlEmail &&
        "Session" in cognito_user &&
        mode === "verify" &&
        !isAuthenticated
      ) {
        const sessionLoginId = cognito_user.Session;
        console.log(urlCode);
        const resp = await answerCustomChallenge(
          sessionLoginId,
          urlCode,
          urlEmail
        );
        setMode("login");
        localStorage.setItem("mode", "login");
        const expiresAt =
          new Date().getTime() / 1000 + resp.AuthenticationResult?.ExpiresIn!;
        const credentials = JSON.stringify(resp.AuthenticationResult);
        localStorage.setItem("credentials", credentials);
        setCredentials(credentials);
        localStorage.setItem("expireAt", expiresAt.toString());
        if (
          resp &&
          Object.keys(resp).length === 0 &&
          resp.constructor === Object
        ) {
          return;
        }

        setIsAuthenticated(true);
      }
    }
    respondAuthChallege(urlCode, urlEmail, isAuthenticated);
  }, [urlCode, urlEmail, isAuthenticated, mode]);

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
              data-testid="login-email-input"
              value={email}
              onChange={(e) => setEmail(e.currentTarget.value)}
              className="w-full bg-gray-800 rounded border border-gray-700 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-900 text-base outline-none text-gray-100 py-1 px-3 leading-8 transition-colors duration-200 ease-in-out"
            />
          </div>
          <button
            data-testid="login-email-submit-btn"
            onClick={async (e) => {
              e.preventDefault();
              console.log("submit email??");
              await submitCallback(email);
            }}
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
