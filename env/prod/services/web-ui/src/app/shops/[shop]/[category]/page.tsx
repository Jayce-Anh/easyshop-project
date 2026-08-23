import ProductGrid from "@/components/ProductGrid";
import SelectedFilters from "@/components/filters/SelectedFilters";
import ProductLoader from "@/components/loader/ProductLoader";
import { shopCategoryStaticParams } from "@/lib/staticParams";
import { Suspense } from "react";

export function generateStaticParams() {
  return shopCategoryStaticParams();
}

const CategoryPage = ({
  params,
}: {
  params: { shop: string; category: string };
}) => {
  return (
    <section className="category-page">
      <SelectedFilters />
      <Suspense fallback={<ProductLoader />}>
        <ProductGrid params={params} />
      </Suspense>
    </section>
  );
};

export default CategoryPage;
