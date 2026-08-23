import { promises as fs } from 'fs';
import path from 'path';
import Product from './models/product';

interface SeedProduct {
  id: string;
  title: string;
  description?: string;
  price: number;
  oldPrice?: number;
  categories?: string[];
  image?: string[];
  rating?: number;
  amount: number;
  shop_category: string;
  unit_of_measure?: string;
  colors?: string[];
  sizes?: string[];
}

const categoryImageDir: Record<string, string> = {
  electronics: 'gadgetsImages',
  medicine: 'medicineImages',
  grocery: 'groceryImages',
  clothing: 'clothingImages',
  furniture: 'furnitureImages',
  books: 'books',
  beauty: 'makeupImages',
  snacks: 'groceryImages',
  bakery: 'bakeryImages',
  bags: 'bagsImages',
};

function getImagePath(originalPath: string, shopCategory: string): string {
  const fileName = path.basename(originalPath);
  const imageDir = categoryImageDir[shopCategory] || `${shopCategory}Images`;
  return `/${imageDir}/${fileName}`;
}

export async function seedProductsIfEmpty(): Promise<void> {
  const existing = await Product.countDocuments();
  if (existing > 0) {
    console.log(`Products already seeded (${existing}), skipping`);
    return;
  }

  const dataPath = path.join(__dirname, '..', 'data', 'db.json');
  const jsonData = await fs.readFile(dataPath, 'utf-8');
  const data = JSON.parse(jsonData) as { products: SeedProduct[] };

  const usedIds = new Set<string>();
  const products = data.products.map((product) => {
    let paddedId = String(product.id).padStart(10, '0');
    while (usedIds.has(paddedId)) {
      paddedId = (parseInt(paddedId, 10) + 1).toString().padStart(10, '0');
    }
    usedIds.add(paddedId);

    const fixedImages = (product.image || []).map((img) =>
      getImagePath(img, product.shop_category)
    );

    return {
      originalId: paddedId,
      title: product.title,
      description: product.description || '',
      price: product.price,
      oldPrice: product.oldPrice,
      categories: product.categories || [],
      image: fixedImages,
      rating: product.rating || 0,
      amount: product.amount,
      shop_category: product.shop_category,
      unit_of_measure: product.unit_of_measure,
      colors: product.colors || [],
      sizes: product.sizes || [],
    };
  });

  try {
    await Product.insertMany(products);
    console.log(`Seeded ${products.length} products`);
  } catch (error: unknown) {
    const mongoError = error as { code?: number };
    if (mongoError.code === 11000) {
      console.log('Products already seeded by another instance, skipping');
      return;
    }
    throw error;
  }
}
