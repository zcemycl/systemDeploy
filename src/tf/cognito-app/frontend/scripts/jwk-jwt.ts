interface IOpenIdConf {
  authorization_endpoint: string;
  end_session_endpoint: string;
  id_token_signing_alg_values_supported: string[];
  issuer: string;
  jwks_uri: string;
  response_types_supported: string[];
  revocation_endpoint: string;
  scopes_supported: string[];
  subject_types_supported: string[];
  token_endpoint: string;
  token_endpoint_auth_methods_supported: string[];
  userinfo_endpoint: string;
}

async function fetchOpenIdConfig() {
  const resp = await fetch(
    "https://cognito-idp.eu-west-2.amazonaws.com/eu-west-2_gFjtuKT7J/.well-known/openid-configuration"
  );
  const res: IOpenIdConf = await resp.json();
  console.log(res);
  return res;
}

async function fetchJwk(url: string) {
  const resp = await fetch(url);
  const res = await resp.json();
  return res;
}

async function main() {
  const openIdConfig = await fetchOpenIdConfig();
  const jwkJson = fetchJwk((openIdConfig as IOpenIdConf).jwks_uri);
}

main();
