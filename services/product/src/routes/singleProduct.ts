import { Router, Request, Response } from 'express';
import Product from '../models/product';
import dbConnect from '../db';
import { cacheGet, cacheSet } from '../cache';

const router = Router();

// GET /singleProduct/:slug
router.get('/:slug', async (req: Request, res: Response) => {
  try {
    const { slug } = req.params;
    const cacheKey = `products:single:${slug}`;
    const cached = await cacheGet(cacheKey);
    if (cached) {
      res.json(cached);
      return;
    }

    await dbConnect();

    let product = await Product.findOne({ originalId: slug });

    if (!product && /^[0-9a-fA-F]{24}$/.test(slug)) {
      product = await Product.findById(slug);
    }

    if (!product) {
      res.status(404).json({ error: 'Product not found' });
      return;
    }

    await cacheSet(cacheKey, product);
    res.json(product);
  } catch (error) {
    console.error('Error fetching single product:', error);
    res.status(500).json({ error: 'Failed to fetch product' });
  }
});

export default router;
