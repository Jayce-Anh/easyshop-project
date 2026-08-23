"use client";

import fetchData from "@/lib/fetchDataFromApi";
import Link from "next/link";
import { useEffect, useState } from "react";
import BooksSlider from "./sliders/BooksSlider";

const BooksCategory = () => {
  const [books, setBooks] = useState<BooksProduct[]>([]);

  useEffect(() => {
    const load = async () => {
      try {
        const res = await fetchData.get("/products/books");
        setBooks((res.data?.products as BooksProduct[]) || []);
      } catch (error) {
        console.error("Error:", error);
        setBooks([]);
      }
    };
    load();
  }, []);

  if (books.length === 0) {
    return null;
  }

  return (
    <section className="books-category pt-20">
      <div className="container">
        <div className="flex justify-between items-center gap-4 flex-wrap mb-6">
          <h1 className="text-2xl md:text-4xl font-semibold">
            Best Sellers in Books
          </h1>
          <Link href={"/shops/books"} className="hover:underline text-primary">
            View Shop
          </Link>
        </div>

        <BooksSlider books={books} />
      </div>
    </section>
  );
};

export default BooksCategory;
