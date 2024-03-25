"use client";
import React, {
  Dispatch,
  SetStateAction,
  createContext,
  useContext,
  useState,
  useMemo,
} from "react";
import { Amplify } from "aws-amplify";
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
import { CognitoIdentity } from "@aws-sdk/client-cognito-identity";
import { useSearchParams, redirect } from "next/navigation";

Amplify.configure({
  Auth: {
    Cognito: {
      userPoolClientId: process.env
        .NEXT_PUBLIC_AWS_COGNITO_USERPOOL_CLIENT_ID as string,
      userPoolId: process.env.NEXT_PUBLIC_AWS_COGNITO_USERPOOL_ID as string,
    },
  },
});

interface AuthContextType {
  isAuthenticated: boolean;
  setIsAuthenticated: Dispatch<SetStateAction<boolean>>;
  signIn: (email: string) => Promise<InitiateAuthResponse>;
  cognitoIdentity: CognitoIdentityProviderClient;
  answerCustomChallenge: (
    sessionId: string,
    code: string,
    email: string
  ) => Promise<RespondToAuthChallengeResponse>;
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
});

export const AuthProvider = ({ children }: { children?: React.ReactNode }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const cognitoIdentity = new CognitoIdentityProviderClient({
    region: process.env.NEXT_PUBLIC_AWS_REGION,
  });
  const cognitoidentity = new CognitoIdentity({
    region: process.env.NEXT_PUBLIC_AWS_REGION,
  });

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

  const AuthProviderValue = useMemo<AuthContextType>(() => {
    return {
      isAuthenticated,
      setIsAuthenticated,
      cognitoIdentity,
      signIn,
      answerCustomChallenge,
    };
  }, [
    isAuthenticated,
    setIsAuthenticated,
    cognitoIdentity,
    signIn,
    answerCustomChallenge,
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
