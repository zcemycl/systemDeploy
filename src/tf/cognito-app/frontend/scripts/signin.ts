import dotenv from "dotenv";
import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  InitiateAuthRequest,
} from "@aws-sdk/client-cognito-identity-provider";
dotenv.config();

const cognitoIdentity = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

async function signIn() {
  const params: InitiateAuthRequest = {
    AuthFlow: "CUSTOM_AUTH",
    ClientId: process.env.AWS_COGNITO_USERPOOL_CLIENT_ID,
    AuthParameters: {
      USERNAME: "lyc010197@gmail.com",
    },
  };
  const command = new InitiateAuthCommand(params);
  const response = await cognitoIdentity.send(command);
  console.log(response);
}

console.log("Hello World!");
signIn();
