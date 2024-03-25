import { ProtectedRoute } from "@/contexts/Auth";

export default function AI() {
  return (
    <ProtectedRoute>
      <h1>AI</h1>
    </ProtectedRoute>
  );
}
