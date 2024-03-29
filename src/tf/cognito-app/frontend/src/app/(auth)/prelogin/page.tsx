"use client";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function Prelogin() {
  const router = useRouter();

  useEffect(() => {
    const mode = localStorage.getItem("mode") ?? "login";
    if (mode !== "verify") {
      router.push("/login");
    }
  }, []);

  return (
    <section className="text-gray-400 bg-gray-900 body-font h-[83vh] sm:h-[90vh]">
      <div
        className="container px-2 py-24 mx-auto grid justify-items-center
        "
      >
        <div className="sm:w-1/2 flex flex-col mt-8 w-screen p-10">
          <h2 className="text-white text-lg mb-1 font-medium title-font">
            Check your email
          </h2>
          <p className="leading-relaxed mb-5">
            If you are registered by admin, you should manage to get a login
            link in your email to sign in.
          </p>
          <p className="text-xs text-gray-400 text-opacity-90 mt-3">
            Not registered? Submit a Demo Request Form at{" "}
            <Link href="/">Home Page</Link>.
          </p>
        </div>
      </div>
    </section>
  );
}
