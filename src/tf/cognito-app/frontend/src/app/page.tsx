"use client";
import { useAuth } from "@/contexts";
import Image from "next/image";
import { useEffect, useState } from "react";
import { redirect } from "next/navigation";
import {
  SESClient,
  SendEmailCommand,
  SendEmailCommandInput,
  SESClientConfig,
} from "@aws-sdk/client-ses";
import { useRouter } from "next/navigation";

import { fetchProtected } from "@/http/backend/protected";
import { fetchApiRoot } from "@/http/internal";

interface IData {
  success?: boolean;
  message?: string;
  id?: number;
  username?: string;
}

interface IData2 {
  Hello?: string;
}

interface IRequestForm {
  name: string;
  email: string;
  message: string;
}

export default function Home() {
  const router = useRouter();
  const { isAuthenticated, setIsAuthenticated, credentials } = useAuth();
  const [data, setData] = useState<IData>({});
  const [data2, setData2] = useState<IData2>({});
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const defaultRequestForm = {
    name: "",
    email: "",
    message: "",
  };
  const [requestForm, setRequestForm] =
    useState<IRequestForm>(defaultRequestForm);

  async function handleSubmitRequestForm() {
    let config: SESClientConfig = {
      region: process.env.NEXT_PUBLIC_AWS_REGION as string,
    };
    if (process.env.NEXT_PUBLIC_ENV_NAME === "local") {
      config = {
        ...config,
        credentials: {
          accessKeyId: process.env.NEXT_PUBLIC_AWS_ACCESS_KEY_ID as string,
          secretAccessKey: process.env
            .NEXT_PUBLIC_AWS_SECRET_ACCESS_KEY as string,
        },
      };
    }
    const ses_client = new SESClient(config);
    const input: SendEmailCommandInput = {
      Source: `no-reply@${process.env.NEXT_PUBLIC_DOMAIN_NAME as string}`,
      Destination: {
        ToAddresses: [process.env.NEXT_PUBLIC_ADMIN_EMAIL as string],
      },
      Message: {
        Subject: {
          Data: "Drugig Website Login Request",
          Charset: "UTF-8",
        },
        Body: {
          Html: {
            Data: `<body><p>${requestForm.name} (${requestForm.email}): ${requestForm.message}</p></body>`,
            Charset: "UTF-8",
          },
        },
      },
    };
    const command = new SendEmailCommand(input);
    const response = await ses_client.send(command);
    console.log(response);
    const tmpRequestForm = {
      ...requestForm,
      message: "",
    };
    setRequestForm(tmpRequestForm);
    localStorage.setItem("requestForm", JSON.stringify(tmpRequestForm));
    router.push("/requestaccount");
  }

  useEffect(() => {
    const requestFormJson =
      JSON.parse(localStorage.getItem("requestForm") as string) ??
      defaultRequestForm;
    setRequestForm(requestFormJson);
  }, []);

  useEffect(() => {
    if (credentials.length === 0) return;
    async function getData(credentials: string) {
      const credJson = JSON.parse(credentials);
      const resp = await fetchApiRoot(1, credJson.AccessToken);
      if (isAuthenticated && resp.status === 401) {
        setIsAuthenticated(false);
        redirect("/logout");
      }
      const res = await resp.json();
      const resp2 = await fetchProtected(credJson.AccessToken);
      const res2 = await resp2.json();
      setData(res);
      setData2(res2);
      setIsLoading(false);
    }
    getData(credentials);
  }, [credentials]);
  return (
    <>
      <section className="text-gray-400 bg-gray-900 body-font">
        <div className="container px-5 py-24 mx-auto flex flex-wrap">
          <div className="flex flex-wrap -mx-4 mt-auto mb-auto lg:w-1/2 sm:w-2/3 content-start sm:pr-10">
            <div className="w-full sm:p-4 px-4 mb-6">
              <h1 className="title-font font-medium text-xl mb-2 text-white">
                Hello{" "}
                {isAuthenticated
                  ? isLoading
                    ? "is Loading"
                    : `${data!.id}-${data!.username}-${data2!.Hello}`
                  : ""}
              </h1>
              <div className="leading-relaxed">
                Pour-over craft beer pug drinking vinegar live-edge gastropub,
                keytar neutra sustainable fingerstache kickstarter.
              </div>
            </div>
            <div className="p-4 sm:w-1/2 lg:w-1/4 w-1/2">
              <h2 className="title-font font-medium text-3xl text-white">
                2.7K
              </h2>
              <p className="leading-relaxed">Drugs</p>
            </div>
            <div className="p-4 sm:w-1/2 lg:w-1/4 w-1/2">
              <h2 className="title-font font-medium text-3xl text-white">
                1.8K
              </h2>
              <p className="leading-relaxed">Users</p>
            </div>
            <div className="p-4 sm:w-1/2 lg:w-1/4 w-1/2">
              <h2 className="title-font font-medium text-3xl text-white">35</h2>
              <p className="leading-relaxed">Data Sources</p>
            </div>
            <div className="p-4 sm:w-1/2 lg:w-1/4 w-1/2">
              <h2 className="title-font font-medium text-3xl text-white">4</h2>
              <p className="leading-relaxed">Products</p>
            </div>
          </div>
          <div className="lg:w-1/2 sm:w-1/3 w-full rounded-lg overflow-hidden mt-6 sm:mt-0">
            <Image
              className="object-cover object-center w-full h-full"
              src="https://dummyimage.com/600x300"
              alt="stats"
              width={600}
              height={300}
            />
          </div>
        </div>
      </section>
      <section className="text-gray-400 bg-gray-900 body-font relative">
        <div className="container px-5 py-24 mx-auto flex sm:flex-nowrap flex-wrap">
          <div className="lg:w-2/3 md:w-1/2 bg-gray-900 rounded-lg overflow-hidden sm:mr-10 p-10 flex items-end justify-start relative">
            <iframe
              width="100%"
              height="100%"
              title="map"
              className="absolute inset-0"
              src="https://maps.google.com/maps?width=100%&height=600&hl=en&q=%C4%B0zmir+(My%20Business%20Name)&ie=UTF8&t=&z=14&iwloc=B&output=embed"
              style={{
                filter: "grayscale(1) contrast(1.2) opacity(0.16)",
                border: 0,
                overflow: "hidden",
                margin: 0,
              }}
            ></iframe>
            <div className="bg-gray-900 relative flex flex-wrap py-6 rounded shadow-md">
              <div className="lg:w-1/2 px-6">
                <h2 className="title-font font-semibold text-white tracking-widest text-xs">
                  ADDRESS
                </h2>
                <p className="mt-1">
                  Photo booth tattooed prism, portland taiyaki hoodie neutra
                  typewriter
                </p>
              </div>
              <div className="lg:w-1/2 px-6 mt-4 lg:mt-0">
                <h2 className="title-font font-semibold text-white tracking-widest text-xs">
                  EMAIL
                </h2>
                <a className="text-indigo-400 leading-relaxed">
                  example@email.com
                </a>
                <h2 className="title-font font-semibold text-white tracking-widest text-xs mt-4">
                  PHONE
                </h2>
                <p className="leading-relaxed">123-456-7890</p>
              </div>
            </div>
          </div>
          <div className="lg:w-1/3 md:w-1/2 flex flex-col md:ml-auto w-full md:py-8 mt-8 md:mt-0">
            <h2 className="text-white text-lg mb-1 font-medium title-font">
              Demo Request Form
            </h2>
            <p className="leading-relaxed mb-5">
              Please fill in and submit the request form. We would contact you
              if you are eligible for demo.
            </p>
            <div className="relative mb-4">
              <label htmlFor="name" className="leading-7 text-sm text-gray-400">
                Name
              </label>
              <input
                type="text"
                id="name"
                name="name"
                value={requestForm.name}
                onChange={(e) => {
                  const tmpRequestForm = {
                    ...requestForm,
                    name: e.currentTarget.value,
                  };
                  setRequestForm(tmpRequestForm);
                  localStorage.setItem(
                    "requestForm",
                    JSON.stringify(tmpRequestForm)
                  );
                }}
                className="w-full bg-gray-800 rounded border border-gray-700 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-900 text-base outline-none text-gray-100 py-1 px-3 leading-8 transition-colors duration-200 ease-in-out"
              />
            </div>
            <div className="relative mb-4">
              <label
                htmlFor="email"
                className="leading-7 text-sm text-gray-400"
              >
                Email
              </label>
              <input
                type="email"
                id="email"
                name="email"
                value={requestForm.email}
                onChange={(e) => {
                  const tmpRequestForm = {
                    ...requestForm,
                    email: e.currentTarget.value,
                  };
                  setRequestForm(tmpRequestForm);
                  localStorage.setItem(
                    "requestForm",
                    JSON.stringify(tmpRequestForm)
                  );
                }}
                className="w-full bg-gray-800 rounded border border-gray-700 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-900 text-base outline-none text-gray-100 py-1 px-3 leading-8 transition-colors duration-200 ease-in-out"
              />
            </div>
            <div className="relative mb-4">
              <label
                htmlFor="message"
                className="leading-7 text-sm text-gray-400"
              >
                Message
              </label>
              <textarea
                id="message"
                name="message"
                value={requestForm.message}
                onChange={(e) => {
                  const tmpRequestForm = {
                    ...requestForm,
                    message: e.currentTarget.value,
                  };
                  setRequestForm(tmpRequestForm);
                  localStorage.setItem(
                    "requestForm",
                    JSON.stringify(tmpRequestForm)
                  );
                }}
                className="w-full bg-gray-800 rounded border border-gray-700 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-900 h-32 text-base outline-none text-gray-100 py-1 px-3 resize-none leading-6 transition-colors duration-200 ease-in-out"
              ></textarea>
            </div>
            <button
              onClick={async () => await handleSubmitRequestForm()}
              className="text-white bg-indigo-500 border-0 py-2 px-6 focus:outline-none hover:bg-indigo-600 rounded text-lg"
            >
              Submit
            </button>
            <p className="text-xs text-gray-400 text-opacity-90 mt-3">
              Chicharrones blog helvetica normcore iceland tousled brook viral
              artisan.
            </p>
          </div>
        </div>
      </section>
    </>
  );
}
