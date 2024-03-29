"use client";
import { useAuth } from "@/contexts/Auth";
import { useEffect } from "react";
export default function Logout() {
  const { setIsAuthenticated } = useAuth();
  useEffect(() => {
    localStorage.clear();
    setIsAuthenticated(false);
  }, []);
  return (
    <section className="text-gray-400 bg-gray-900 body-font h-[83vh] sm:h-[90vh]">
      <div
        className="container px-2 py-24 mx-auto grid justify-items-center
    "
      >
        <div className="sm:w-1/2 flex flex-col mt-8 w-screen p-10">
          <h2 className="text-white text-lg mb-1 font-medium title-font">
            Logout
          </h2>
        </div>
      </div>
    </section>
  );
}
