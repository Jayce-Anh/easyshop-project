import ProductGrid from "@/components/ProductGrid";
import SelectedFilters from "@/components/filters/SelectedFilters";
import ProductLoader from "@/components/loader/ProductLoader";
import { shopStaticParams } from "@/lib/staticParams";
import { Suspense } from "react";

export function generateStaticParams() {
  return shopStaticParams();
}

const ShopPage = ({ params }: { params: { shop: string } }) => {
  return (
    <section className="shop-page">
      <SelectedFilters />
      <Suspense fallback={<ProductLoader />}>
        <ProductGrid params={{ shop: params.shop }} />
      </Suspense>
    </section>
  );
};

export default ShopPage;
