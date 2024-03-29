export async function fetchRoot() {
  const response = await fetch(`${process.env.NEXT_PUBLIC_BACKEND_BASE_URL}`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
    },
  });
  return response;
}

export async function fetchProtected(token: string) {
  const response = await fetch(
    `${process.env.NEXT_PUBLIC_BACKEND_BASE_URL}/protected`,
    {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    }
  );
  return response;
}
