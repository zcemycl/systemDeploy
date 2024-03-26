import { NextResponse, type NextRequest } from "next/server";

const openid_conf_uri = process.env.NEXT_PUBLIC_COGNITO_OPENID_CONF_URI;

export function get_jwk() {}

export async function middleware(request: NextRequest) {
  console.log(openid_conf_uri);
  const authorization = request.headers.get("Authorization") as string;
  // validate bearer
  const [token_type, token] = authorization.split(" ");
  if (token_type !== "Bearer") {
    return Response.json(
      {
        success: false,
        message: "authentication failed -- unsupported token type",
      },
      { status: 401 }
    );
  }
  // validate jwk
  const [headerEncoded] = token.split(".");
  const buff = Buffer.from(headerEncoded, "base64");
  const text = buff.toString("ascii");
  const kid = JSON.parse(text);
  const openid_conf = await (await fetch(openid_conf_uri as string)).json();
  const jwks = await (await fetch(openid_conf.jwks_uri as string)).json();
  const jwk = jwks.keys.filter((data: any) => data.kid === kid.kid);
  if (jwk.length === 0) {
    return Response.json(
      {
        success: false,
        message: "authentication failed -- unsupported jwk.",
      },
      { status: 401 }
    );
  }
  console.log(jwk);

  // validate userinfo
  const user_info = await (
    await fetch(openid_conf.userinfo_endpoint as string, {
      method: "GET",
      headers: {
        Authorization: authorization,
        // "Content-Type": "application/json",
      },
    })
  ).json();
  console.log(user_info);
  console.log(authorization);
  // return NextResponse.redirect(new URL("/", request.url));
}

export const config = {
  matcher: "/api/:path*",
};
