import { ProtectedRoute } from "@/contexts/Auth";

export default function APIs() {
  return (
    <ProtectedRoute>
      <h1>APIs</h1>
    </ProtectedRoute>
  );
}
