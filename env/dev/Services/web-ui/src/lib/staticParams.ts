import categoriesJson from "@/data/categories.json";
import layoutSettings from "@/lib/layoutSettings";

type CategoryItem = {
  search_link?: string;
  subcategories?: { search_link?: string }[];
};

export function shopStaticParams() {
  return Object.keys(layoutSettings).map((shop) => ({ shop }));
}

export function shopCategoryStaticParams() {
  const params: { shop: string; category: string }[] = [];
  const shops = categoriesJson.categories as Record<string, CategoryItem[]>;

  const addLink = (link?: string) => {
    if (!link) return;
    const parts = link.split("/").filter(Boolean);
    if (parts[0] === "shops" && parts[1] && parts[2]) {
      params.push({ shop: parts[1], category: parts[2] });
    }
  };

  for (const items of Object.values(shops)) {
    for (const item of items) {
      addLink(item.search_link);
      for (const sub of item.subcategories ?? []) {
        addLink(sub.search_link);
      }
    }
  }

  return params;
}
