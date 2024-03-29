"use client";
import React, {
  Dispatch,
  SetStateAction,
  createContext,
  useContext,
  useState,
  useEffect,
  useMemo,
} from "react";
import { Amplify } from "aws-amplify";
import { defaultStorage } from "aws-amplify/utils";
import { cognitoUserPoolsTokenProvider } from "aws-amplify/auth/cognito";
// import {} from "aws-amplify/auth";
import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  InitiateAuthRequest,
  InitiateAuthResponse,
  RespondToAuthChallengeCommand,
  RespondToAuthChallengeRequest,
  RespondToAuthChallengeResponse,
} from "@aws-sdk/client-cognito-identity-provider";
// import { CognitoIdentity } from "@aws-sdk/client-cognito-identity";
import { redirect } from "next/navigation";
import { signIn as login, confirmSignIn } from "aws-amplify/auth";
// import CognitoProvider from "next-auth/providers/cognito";

Amplify.configure({
  Auth: {
    Cognito: {
      userPoolClientId: process.env
        .NEXT_PUBLIC_AWS_COGNITO_USERPOOL_CLIENT_ID as string,
      userPoolId: process.env.NEXT_PUBLIC_AWS_COGNITO_USERPOOL_ID as string,
      loginWith: { email: true },
    },
  },
});

cognitoUserPoolsTokenProvider.setKeyValueStorage(defaultStorage);

interface AuthContextType {
  isAuthenticated: boolean;
  setIsAuthenticated: Dispatch<SetStateAction<boolean>>;
  credentials: string;
  setCredentials: Dispatch<SetStateAction<string>>;
  signIn: (email: string) => Promise<InitiateAuthResponse>;
  cognitoIdentity: CognitoIdentityProviderClient;
  answerCustomChallenge: (
    sessionId: string,
    code: string,
    email: string
  ) => Promise<RespondToAuthChallengeResponse>;
  amplifySignIn: (email: string) => {};
  amplifyConfirmSignIn: (email: string, code: string) => {};
}

export const AuthContext = createContext<AuthContextType>({
  isAuthenticated: false,
  setIsAuthenticated: function (value: React.SetStateAction<boolean>): void {
    throw new Error("Function not implemented.");
  },
  signIn: function (email: string): Promise<InitiateAuthResponse> {
    throw new Error("Function not implemented.");
  },
  cognitoIdentity: new CognitoIdentityProviderClient(),
  answerCustomChallenge: function (
    sessionId: string,
    code: string,
    email: string
  ): Promise<RespondToAuthChallengeResponse> {
    throw new Error("Function not implemented.");
  },
  amplifySignIn: function (email: string): {} {
    throw new Error("Function not implemented.");
  },
  amplifyConfirmSignIn: function (email: string, code: string) {
    throw new Error("Function not implemented.");
  },
  credentials: "",
  setCredentials: function (value: React.SetStateAction<string>): void {
    throw new Error("Function not implemented.");
  },
});

export const AuthProvider = ({ children }: { children?: React.ReactNode }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [credentials, setCredentials] = useState<string>("");
  const cognitoIdentity = new CognitoIdentityProviderClient({
    region: process.env.NEXT_PUBLIC_AWS_REGION,
  });
  // const cognitoidentity = new CognitoIdentity({
  //   region: process.env.NEXT_PUBLIC_AWS_REGION,
  // });
  useEffect(() => {
    const credJson = JSON.parse(localStorage.getItem("credentials") as string);
    const expireAt = parseFloat(localStorage.getItem("expireAt") as string);
    if (new Date().getTime() / 1000 < expireAt && "AccessToken" in credJson) {
      setIsAuthenticated(true);
      setCredentials(localStorage.getItem("credentials") ?? "");
    }
  }, []);

  async function signIn(email: string) {
    const params: InitiateAuthRequest = {
      AuthFlow: "CUSTOM_AUTH",
      ClientId: process.env.NEXT_PUBLIC_AWS_COGNITO_USERPOOL_CLIENT_ID,
      AuthParameters: {
        USERNAME: email,
      },
    };
    const command = new InitiateAuthCommand(params);
    try {
      const response: InitiateAuthResponse =
        await cognitoIdentity.send(command);
      return response;
    } catch (err) {
      console.log(err);
      return {};
    }
  }

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
    try {
      const response: RespondToAuthChallengeResponse =
        await cognitoIdentity.send(command);
      return response;
    } catch (err) {
      console.log(err);
      return {};
    }
  }

  async function amplifySignIn(email: string) {
    const resp = await login({
      username: email,
      options: { authFlowType: "CUSTOM_WITHOUT_SRP" },
    });
    return resp;
  }

  async function amplifyConfirmSignIn(code: string) {
    const resp = await confirmSignIn({
      challengeResponse: code,
    });
    return resp;
  }

  const AuthProviderValue = useMemo<AuthContextType>(() => {
    return {
      isAuthenticated,
      setIsAuthenticated,
      credentials,
      setCredentials,
      cognitoIdentity,
      signIn,
      answerCustomChallenge,
      amplifySignIn,
      amplifyConfirmSignIn,
    };
  }, [
    isAuthenticated,
    setIsAuthenticated,
    credentials,
    setCredentials,
    cognitoIdentity,
    signIn,
    answerCustomChallenge,
    amplifySignIn,
    amplifyConfirmSignIn,
  ]);

  return (
    <AuthContext.Provider value={AuthProviderValue}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);

export const ProtectedRoute = ({
  children,
}: {
  children?: React.ReactNode;
}) => {
  const { isAuthenticated } = useAuth();
  if (!isAuthenticated) {
    redirect("/login");
  }
  return children;
};
