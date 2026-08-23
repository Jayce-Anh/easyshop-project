"use client";

import fetchData from "@/lib/fetchDataFromApi";
import layoutSettings from "@/lib/layoutSettings";
import type { AllProduct } from "@/types/product";
import { useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import NoProductFound from "./NoProductFound";
import Paginations from "./Paginations";
import ProductLoader from "./loader/ProductLoader";
import ProductCard from "./cards/ProductCard";

type ProductGridProps = {
  params: {
    shop: string;
    category?: string;
  };
};

const ProductGrid = ({ params }: ProductGridProps) => {
  const searchParams = useSearchParams();
  const { shop, category } = params;
  const page = searchParams.get("page") || "1";
  const q = searchParams.get("q") || "";
  const sort = searchParams.get("sort") || "";
  const order = searchParams.get("order") || "";
  const color = searchParams.get("color") || "";
  const minPrice = searchParams.get("minPrice") || "";
  const maxPrice = searchParams.get("maxPrice") || "";

  const [products, setProducts] = useState<AllProduct[]>([]);
  const [totalCount, setTotalCount] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    const load = async () => {
      setLoading(true);
      try {
        const res = await fetchData.get("/products", {
          page,
          q,
          sort,
          order,
          color,
          minPrice,
          maxPrice,
          shop_category: shop,
          ...(category && { categories: category }),
        });
        if (cancelled) return;
        setProducts((res.data?.products || []) as AllProduct[]);
        setTotalCount(res.data?.pagination?.total ?? res.data?.total ?? 0);
      } catch (error) {
        console.error("Error fetching products:", error);
        if (!cancelled) {
          setProducts([]);
          setTotalCount(0);
        }
      } finally {
        if (!cancelled) setLoading(false);
      }
    };

    load();
    return () => {
      cancelled = true;
    };
  }, [shop, category, page, q, sort, order, color, minPrice, maxPrice]);

  const settings = layoutSettings?.[shop] || { productCardVariants: "style-1" };

  if (loading) {
    return <ProductLoader />;
  }

  if (products.length === 0) {
    return <NoProductFound />;
  }

  return (
    <>
      <div className="grid-layout pt-6">
        {products.map((product) => (
          <ProductCard
            product={product}
            variants={settings.productCardVariants}
            key={product._id}
          />
        ))}
      </div>
      <Paginations
        totalCount={totalCount}
        currentPage={Number(page)}
        totalPages={Math.ceil(totalCount / 10) || 1}
      />
    </>
  );
};

export default ProductGrid;
