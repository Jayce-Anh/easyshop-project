"use client";

import fetchData from "@/lib/fetchDataFromApi";
import layoutSettings from "@/lib/layoutSettings";
import { useEffect, useState } from "react";
import ProductCard from "./cards/ProductCard";

type RelatedProductsProps = {
  category: string;
  shop_category: string;
};

const RelatedProducts = ({ category, shop_category }: RelatedProductsProps) => {
  const [products, setProducts] = useState<AllProduct[]>([]);
  const settings = layoutSettings?.[shop_category];

  useEffect(() => {
    const load = async () => {
      try {
        const res = await fetchData.get(`/products`, {
          shop_category,
          categories: category,
          limit: "5",
        });
        setProducts(res.data?.products || []);
      } catch {
        setProducts([]);
      }
    };
    load();
  }, [category, shop_category]);

  return (
    <>
      {products.map((product) => (
        <ProductCard
          product={product}
          variants={settings?.productCardVariants}
          key={product._id}
        />
      ))}
    </>
  );
};

export default RelatedProducts;
