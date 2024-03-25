import dotenv from "dotenv";
import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  InitiateAuthRequest,
  InitiateAuthResponse,
} from "@aws-sdk/client-cognito-identity-provider";
dotenv.config();

const cognitoIdentity = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

async function signIn(email: string) {
  const params: InitiateAuthRequest = {
    AuthFlow: "CUSTOM_AUTH",
    ClientId: process.env.AWS_COGNITO_USERPOOL_CLIENT_ID,
    AuthParameters: {
      USERNAME: email,
    },
  };
  const command = new InitiateAuthCommand(params);
  const response: InitiateAuthResponse = await cognitoIdentity.send(command);
  console.log(response);
  return response;
}
