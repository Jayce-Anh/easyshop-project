const baseURL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080";

export async function fetchServer<T>(path: string): Promise<T | null> {
  try {
    const res = await fetch(`${baseURL}${path}`, { cache: "no-store" });
    if (!res.ok) return null;
    return (await res.json()) as T;
  } catch {
    return null;
  }
}

export async function listProductSlugs(): Promise<string[]> {
  const slugs = new Set<string>();
  let page = 1;
  const limit = 100;

  for (;;) {
    const payload = await fetchServer<{
      products?: { _id?: string; originalId?: string }[];
      data?: { products?: { _id?: string; originalId?: string }[] };
      pagination?: { pages?: number };
    }>(`/products?page=${page}&limit=${limit}`);

    const products = Array.isArray(payload)
      ? payload
      : payload?.products ?? payload?.data?.products ?? [];

    for (const product of products) {
      if (product._id) slugs.add(String(product._id));
      if (product.originalId) slugs.add(String(product.originalId));
    }

    const pages = Array.isArray(payload) ? 1 : payload?.pagination?.pages ?? 1;
    if (page >= pages || products.length === 0) break;
    page += 1;
  }

  return [...slugs];
}
