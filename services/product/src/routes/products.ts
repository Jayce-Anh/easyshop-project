import { Router, Request, Response } from 'express';
import Product from '../models/product';
import dbConnect from '../db';
import { verifyToken } from '../middleware/verifyToken';
import { cacheDelByPrefix, cacheGet, cacheSet } from '../cache';

const router = Router();

const categoryMap: Record<string, string> = {
  electronics: 'gadgets',
  gadgets: 'gadgets',
  medicine: 'medicine',
  grocery: 'grocery',
  clothing: 'clothing',
  furniture: 'furniture',
  books: 'books',
  beauty: 'makeup',
  makeup: 'makeup',
  bags: 'bags',
  snacks: 'grocery',
  bakery: 'bakery',
};

// GET /products
router.get('/', async (req: Request, res: Response) => {
  try {
    const cacheKey = `products:list:${JSON.stringify(req.query)}`;
    const cached = await cacheGet(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }

    await dbConnect();
    const query: Record<string, any> = {};

    if (req.query.search) {
      const regex = new RegExp(req.query.search as string, 'i');
      query.$or = [{ title: regex }, { description: regex }];
    }
    if (req.query.shop_category) query.shop_category = req.query.shop_category;
    if (req.query.categories) {
      query.categories = { $in: (req.query.categories as string).split(',') };
    }
    if (req.query.minPrice || req.query.maxPrice) {
      query.price = {};
      if (req.query.minPrice) query.price.$gte = parseFloat(req.query.minPrice as string);
      if (req.query.maxPrice) query.price.$lte = parseFloat(req.query.maxPrice as string);
    }

    const page = parseInt((req.query.page as string) || '1');
    const limit = parseInt((req.query.limit as string) || '10');
    const skip = (page - 1) * limit;

    let sort: Record<string, any> = { createdAt: -1 };
    if (req.query.sort) {
      const [field, order] = (req.query.sort as string).split(':');
      sort = { [field]: order === 'desc' ? -1 : 1 };
    }

    const [products, total] = await Promise.all([
      Product.find(query).sort(sort).skip(skip).limit(limit),
      Product.countDocuments(query),
    ]);

    const payload = { products, pagination: { total, page, limit, pages: Math.ceil(total / limit) } };
    await cacheSet(cacheKey, payload);
    res.json(payload);
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

// GET /products/featured
router.get('/featured', async (req: Request, res: Response) => {
  try {
    const requestedCategory = (req.query.category as string) || 'electronics';
    const cacheKey = `products:featured:${requestedCategory}`;
    const cached = await cacheGet(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }

    await dbConnect();
    const category = categoryMap[requestedCategory] || requestedCategory;
    const matchQuery: Record<string, any> = {};
    if (category !== 'all') matchQuery.shop_category = category;

    const products = await Product.aggregate([
      { $match: matchQuery },
      {
        $addFields: {
          score: {
            $multiply: [
              { $ifNull: ['$rating', 0] },
              { $add: [{ $ifNull: ['$sales', 0] }, 1] },
            ],
          },
        },
      },
      { $sort: { score: -1 } },
      { $limit: 8 },
    ]);

    await cacheSet(cacheKey, products);
    res.json(products);
  } catch (error) {
    console.error('Featured products error:', error);
    res.status(500).json({ error: 'Failed to fetch featured products' });
  }
});

// GET /products/books
router.get('/books', async (_req: Request, res: Response) => {
  try {
    const cacheKey = 'products:books';
    const cached = await cacheGet(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }

    await dbConnect();
    const products = await Product.find({ shop_category: 'books' })
      .sort({ createdAt: -1 })
      .limit(10);
    const payload = { products };
    await cacheSet(cacheKey, payload);
    res.json(payload);
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({ error: 'Failed to fetch books' });
  }
});

// GET /products/:productId
router.get('/:productId', async (req: Request, res: Response) => {
  try {
    const cacheKey = `products:id:${req.params.productId}`;
    const cached = await cacheGet(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }

    await dbConnect();
    const product = await Product.findOne({ originalId: req.params.productId });
    if (!product) {
      res.status(404).json({ error: 'Product not found' });
      return;
    }
    await cacheSet(cacheKey, product);
    res.json(product);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// POST /products (admin)
router.post('/', verifyToken, async (req: Request, res: Response) => {
  try {
    if (req.user?.role !== 'admin') {
      res.status(403).json({ error: 'Unauthorized' });
      return;
    }
    await dbConnect();
    const product = await Product.create(req.body);
    await cacheDelByPrefix('products:');
    res.status(201).json(product);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// PUT /products/:productId (admin)
router.put('/:productId', verifyToken, async (req: Request, res: Response) => {
  try {
    if (req.user?.role !== 'admin') {
      res.status(403).json({ error: 'Unauthorized' });
      return;
    }
    await dbConnect();
    const product = await Product.findOneAndUpdate(
      { originalId: req.params.productId },
      req.body,
      { new: true, runValidators: true }
    );
    if (!product) {
      res.status(404).json({ error: 'Product not found' });
      return;
    }
    await cacheDelByPrefix('products:');
    res.json(product);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// DELETE /products/:productId (admin)
router.delete('/:productId', verifyToken, async (req: Request, res: Response) => {
  try {
    if (req.user?.role !== 'admin') {
      res.status(403).json({ error: 'Unauthorized' });
      return;
    }
    await dbConnect();
    const product = await Product.findOneAndDelete({ originalId: req.params.productId });
    if (!product) {
      res.status(404).json({ error: 'Product not found' });
      return;
    }
    await cacheDelByPrefix('products:');
    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

export default router;
