import dotenv from "dotenv";
import {
  CognitoIdentityProviderClient,
  RespondToAuthChallengeCommand,
  RespondToAuthChallengeRequest,
  RespondToAuthChallengeResponse,
} from "@aws-sdk/client-cognito-identity-provider";
dotenv.config();

const { NEXT_PUBLIC_AWS_COGNITO_TEST_EMAIL } = process.env;

const cognitoIdentity = new CognitoIdentityProviderClient({
  region: process.env.NEXT_PUBLIC_AWS_REGION,
});

async function answerCustomChallenge(
  sessionId: string,
  code: string,
  email: string
) {
  const params: RespondToAuthChallengeRequest = {
    ClientId: process.env.NEXT_PUBLIC_AWS_COGNITO_USERPOOL_CLIENT_ID,
    ChallengeName: "CUSTOM_CHALLENGE",
    Session: sessionId,
    ChallengeResponses: { USERNAME: email, ANSWER: code },
  };
  const command = new RespondToAuthChallengeCommand(params);
  const response: RespondToAuthChallengeResponse =
    await cognitoIdentity.send(command);
  console.log(response);
  return response;
}

answerCustomChallenge(
  // session id from login
  "AYABeGRU0hVER8XA8i9qirdocqUAHQABAAdTZXJ2aWNlABBDb2duaXRvVXNlclBvb2xzAAEAB2F3cy1rbXMAS2Fybjphd3M6a21zOmV1LXdlc3QtMjo1MDA3OTI3NjA3NTc6a2V5LzBhNjgxMWMyLThjY2YtNDBkMi04NjU0LTExNzM2Y2YyZmM0NQC4AQIBAHj46-_t327XTraE8SD_shwsH1Yq1Icb9FDnGG0l5sDaWQE51opJW7o554krLy5ymkh5AAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQMbqbHERrLpV-Ul-jBAgEQgDtWBCK5kflJz9et7x0UFmvN7K2VLACk43kz--JvgvaWBvRHJOlvT57xtVhdMvWRMWz79LCmcT_Kke9U9AIAAAAADAAAEAAAAAAAAAAAAAAAAACEk3bYQ_RcyCvmNRvcdfO7_____wAAAAEAAAAAAAAAAAAAAAEAAAE1LljjEoCCRXPMWKy3COtGDZNG3mz_WyfrdD4wXrSafZao7z9lV6qNoYmgwMKEfHrIgpPrgPFN47Z9S-KUcqTjktP8ma0FQ9WwISfdkceDBZ4ZkVamxy3z3bj6pZhZHuT0ACD0-atYQbHp9P5GH_Pzs9FE38HCZCjA68HyL1qOnyGNOLwd9Pra5Cur3LL14ihZXLLbI0z8RoCfTnCQu4cCsWxXLbyKQLCvRz08Xv5h2rJ7fdICJW-iji91I_sxpxNYNHUblHufXUs1WL7LiJw5y2-1Lf4O3dRdh-fXUFdlrEq6csHt8G4Kg9WuTEIaOJB-WYWeUz8c3dv9q4WVNxTF4jWBi9EULf5f2A_Glnr1z4TLE_Icwnl_tH7NnGOeZ9g2R_Anbsx0nIrWcL1sdG-e84RZ_Pb_zGPMglFzEqmm1e8FHKcjQA",
  // code from login link
  "4c97a6e99a194a63863e5137523fb1fc",
  NEXT_PUBLIC_AWS_COGNITO_TEST_EMAIL as string
);
