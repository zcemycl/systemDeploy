"use client";
import { useAuth } from "@/contexts/Auth";
import { useEffect } from "react";
export default function Logout() {
  const { setIsAuthenticated } = useAuth();
  useEffect(() => {
    setIsAuthenticated(false);
  }, []);
  return <h1>Logout</h1>;
}
