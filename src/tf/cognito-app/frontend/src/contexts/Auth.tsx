"use client";
import React, {
  Dispatch,
  SetStateAction,
  createContext,
  useContext,
  useState,
} from "react";
import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  InitiateAuthRequest,
  InitiateAuthResponse,
} from "@aws-sdk/client-cognito-identity-provider";

interface AuthContextType {
  isAuthenticated: boolean;
  setIsAuthenticated: Dispatch<SetStateAction<boolean>>;
  signIn: (email: string) => Promise<InitiateAuthResponse>;
  cognitoIdentity: CognitoIdentityProviderClient;
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
});

export const AuthProvider = ({ children }: { children?: React.ReactNode }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(true);
  const cognitoIdentity = new CognitoIdentityProviderClient({
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
    const response: InitiateAuthResponse = await cognitoIdentity.send(command);
    return response;
  }

  return (
    <AuthContext.Provider
      value={{ isAuthenticated, setIsAuthenticated, cognitoIdentity, signIn }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
