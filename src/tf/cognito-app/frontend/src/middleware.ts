import { NextResponse, type NextRequest } from "next/server";
import { jwtVerify, importSPKI } from "jose";
import jwkToPem from "jwk-to-pem";

const openid_conf_uri = process.env.NEXT_PUBLIC_COGNITO_OPENID_CONF_URI;

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
  const pem = jwkToPem(jwk[0]);
  console.log(pem);
  const publicKey = await importSPKI(pem, jwk[0].alg);
  try {
    const resjwk = await jwtVerify(token, publicKey, {
      issuer: openid_conf.issuer,
    });
    console.log(resjwk);
  } catch (e) {
    console.log(e);
    return Response.json(
      {
        success: false,
        message: `authentication failed -- ${e}.`,
      },
      { status: 401 }
    );
  }
  console.log(authorization);
}

export const config = {
  matcher: "/api/:path*",
};
