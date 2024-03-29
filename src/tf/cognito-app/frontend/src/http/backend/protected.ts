import { NextApiRequest } from "next";

export async function fetchProtected(req: NextApiRequest) {
  //   const response = await fetch(
  //     `${process.env.NEXT_PUBLIC_BACKEND_BASE_URL}/protected`,
  //     {
  //       method: "GET",
  //       headers: {
  //         "Content-Type": "application/json",
  //         Authorization: req.headers.authorization || "",
  //       },
  //       body: JSON.stringify(req.body),
  //     }
  //   );
  //   return response;
}

export async function fetchRoot() {}
