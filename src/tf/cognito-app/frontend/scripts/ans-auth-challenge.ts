import dotenv from "dotenv";
import {
  CognitoIdentityProviderClient,
  RespondToAuthChallengeCommand,
  RespondToAuthChallengeRequest,
  RespondToAuthChallengeResponse,
} from "@aws-sdk/client-cognito-identity-provider";
dotenv.config();

const { AWS_COGNITO_TEST_EMAIL } = process.env;

const cognitoIdentity = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

async function answerCustomChallenge(
  sessionId: string,
  code: string,
  email: string
) {
  const params: RespondToAuthChallengeRequest = {
    ClientId: process.env.AWS_COGNITO_USERPOOL_CLIENT_ID,
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
  "AYABeBEO0wOyeh28yrgf-gBUjikAHQABAAdTZXJ2aWNlABBDb2duaXRvVXNlclBvb2xzAAEAB2F3cy1rbXMAS2Fybjphd3M6a21zOmV1LXdlc3QtMjo1MDA3OTI3NjA3NTc6a2V5LzBhNjgxMWMyLThjY2YtNDBkMi04NjU0LTExNzM2Y2YyZmM0NQC4AQIBAHj46-_t327XTraE8SD_shwsH1Yq1Icb9FDnGG0l5sDaWQE6JUz-KCdbYVxP09VcfOsmAAAAfjB8BgkqhkiG9w0BBwagbzBtAgEAMGgGCSqGSIb3DQEHATAeBglghkgBZQMEAS4wEQQM0y8U3Je0G5rkSNPUAgEQgDsGJ1t06ORj1baaWRljCYADuUl3OOgRH_mwQI2K0dJIhMSljzac35-euyqzPqIxJ3UEHcvIhl5p2eGecAIAAAAADAAAEAAAAAAAAAAAAAAAAACM6bT5eS0ecBS5ZX-oXYZX_____wAAAAEAAAAAAAAAAAAAAAEAAAE13eCXLiZirXuVd2Egr2ukU3lE1OIGVEE-CZuHd6HxiKQ7t74zWC9Bxc1hOo6RvKzsrNUV0oZOlofBk6OM-QkIpSy4RsI9Ska99dgtBxhxO-OQoQPmBKIkyoB0btcllY8BFChznRROg3Q8Vb-iFmMCxhMQHMb_xaYMCKT52KVBVpWhCjTl40X-4QKmJMNLuHMaEX02v5wEERvZWA9NuIMNbdrguBShLvkkF9Pfl2nSQHKziweDtlM-H71X11T4wIrlrHq1W3uVyj1nnge1RYEjFfmROVSsSx3kUm8YDpNN4QcL_3DYGL-I33YF7jtjbIq8H2WEpFH9lLAOk2yNAsBRitZ0hPDXIUHQIsrxLYCeugrvNDLAxEj01JGplFFg7wHJcjsVrHHbHJL11U_KKfL9RyAfJRAwz06rFVRyS_SJ8qsvedc9uw",
  "306c7cc364324aa89664945f7153dca0",
  AWS_COGNITO_TEST_EMAIL as string
);
