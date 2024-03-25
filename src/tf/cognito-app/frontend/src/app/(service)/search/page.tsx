import { ProtectedRoute } from "@/contexts/Auth";

export default function Search() {
  return (
    <ProtectedRoute>
      <h1>Search</h1>
    </ProtectedRoute>
  );
}
