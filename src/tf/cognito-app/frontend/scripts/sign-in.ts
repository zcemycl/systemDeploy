import dotenv from "dotenv";
import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  InitiateAuthRequest,
  InitiateAuthResponse,
} from "@aws-sdk/client-cognito-identity-provider";
dotenv.config();

const cognitoIdentity = new CognitoIdentityProviderClient({
  region: process.env.NEXT_PUBLIC_AWS_REGION,
});

async function signIn() {
  const params: InitiateAuthRequest = {
    AuthFlow: "CUSTOM_AUTH",
    ClientId: process.env.NEXT_PUBLIC_AWS_COGNITO_USERPOOL_CLIENT_ID,
    AuthParameters: {
      USERNAME: process.env.NEXT_PUBLIC_AWS_COGNITO_TEST_EMAIL as string,
    },
    ClientMetadata: {
      ENV_NAME: process.env.NEXT_PUBLIC_ENV_NAME as string,
    },
  };
  const command = new InitiateAuthCommand(params);
  const response: InitiateAuthResponse = await cognitoIdentity.send(command);
  console.log(response);
  return response;
}

console.log("Hello World!");
signIn();
