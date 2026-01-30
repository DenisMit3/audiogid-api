export async function GET(request: Request) {
  const url = new URL(request.url);
  const apiUrl = process.env.NEXT_PUBLIC_API_URL;
  if (!apiUrl) throw new Error("NEXT_PUBLIC_API_URL is required");

  // General proxy to backend
  const response = await fetch(`${apiUrl}${url.pathname}`, {
    headers: request.headers,
    method: "GET",
  });

  return response;
}

export async function POST(request: Request) {
  const url = new URL(request.url);
  const apiUrl = process.env.NEXT_PUBLIC_API_URL;
  if (!apiUrl) throw new Error("NEXT_PUBLIC_API_URL is required");

  const response = await fetch(`${apiUrl}${url.pathname}`, {
    headers: request.headers,
    method: "POST",
    body: request.body,
  });

  return response;
}
