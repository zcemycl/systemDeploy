import { NextResponse } from "next/server";

export async function GET(request: Request) {
  const identity = JSON.parse(request.headers.get("Identity") as string);
  console.log(identity);
  const { searchParams } = new URL(request.url);
  const id = searchParams.get("id");

  return NextResponse.json(
    { id, username: identity.username },
    { status: 200 }
  );
}
