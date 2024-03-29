"use client";
import Link from "next/link";

export default function RequestAccount() {
  return (
    <section className="text-gray-400 bg-gray-900 body-font h-[83vh] sm:h-[90vh]">
      <div
        className="container px-2 py-24 mx-auto grid justify-items-center
        "
      >
        <div className="sm:w-1/2 flex flex-col mt-8 w-screen p-10">
          <h2 className="text-white text-lg mb-1 font-medium title-font">
            Thank you for your interest!
          </h2>
          <p className="leading-relaxed mb-5">
            We will process your request as soon as possible and contact your
            through email.
          </p>
        </div>
      </div>
    </section>
  );
}
