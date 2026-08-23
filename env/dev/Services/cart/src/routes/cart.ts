import { Router, Request, Response } from 'express';
import Cart from '../models/cart';
import dbConnect from '../db';
import { verifyToken } from '../middleware/verifyToken';
import { cacheGet, cacheSet } from '../cache';

const router = Router();

const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:5000';

async function getProductById(productId: string): Promise<any | null> {
  const cacheKey = `product:${productId}`;
  const cached = await cacheGet(cacheKey);
  if (cached) return cached;

  try {
    const res = await fetch(`${PRODUCT_SERVICE_URL}/products/${productId}`);
    if (!res.ok) return null;
    const product = await res.json();
    await cacheSet(cacheKey, product, 60);
    return product;
  } catch {
    return null;
  }
}

// GET /cart
router.get('/', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const cart = await Cart.findOne({ user: req.user!.userId });

    if (!cart) {
      res.json({ items: [], total: 0 });
      return;
    }

    const populatedItems = await Promise.all(
      cart.items.map(async (item) => {
        const product = await getProductById(item.product);
        return {
          ...item,
          product: product
            ? { _id: product._id, originalId: product.originalId, title: product.title, price: product.price, image: product.image }
            : null,
        };
      })
    );

    res.json({ ...cart.toObject(), items: populatedItems });
  } catch (error: any) {
    console.error('Cart error:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// POST /cart - add / update item
router.post('/', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const { productId, quantity, price } = req.body;

    const product = await getProductById(productId);
    if (!product) {
      res.status(404).json({ error: 'Product not found' });
      return;
    }

    let cart = await Cart.findOne({ user: req.user!.userId });
    if (!cart) {
      cart = new Cart({ user: req.user!.userId, items: [], total: 0 });
    }

    const existingIndex = cart.items.findIndex((i) => i.product === product.originalId);
    if (existingIndex > -1) {
      cart.items[existingIndex].quantity = quantity;
      cart.items[existingIndex].price = price;
    } else {
      cart.items.push({ product: product.originalId, quantity, price });
    }

    await cart.save();

    const populatedItems = await Promise.all(
      cart.items.map(async (item) => {
        const p = await getProductById(item.product);
        return {
          ...item,
          product: p
            ? { _id: p._id, originalId: p.originalId, title: p.title, price: p.price, image: p.image }
            : null,
        };
      })
    );

    res.json({ ...cart.toObject(), items: populatedItems });
  } catch (error: any) {
    console.error('Cart error:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// DELETE /cart - clear cart
router.delete('/', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    await Cart.findOneAndDelete({ user: req.user!.userId });
    res.json({ success: true });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// PUT /cart/:productId - update quantity
router.put('/:productId', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const { quantity } = req.body;

    const cart = await Cart.findOne({ user: req.user!.userId });
    if (!cart) {
      res.status(404).json({ error: 'Cart not found' });
      return;
    }

    const itemIndex = cart.items.findIndex((i) => i.product === req.params.productId);
    if (itemIndex === -1) {
      res.status(404).json({ error: 'Item not found in cart' });
      return;
    }

    cart.items[itemIndex].quantity = quantity;
    await cart.save();
    res.json(cart);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// DELETE /cart/:productId - remove item
router.delete('/:productId', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const cart = await Cart.findOne({ user: req.user!.userId });
    if (!cart) {
      res.status(404).json({ error: 'Cart not found' });
      return;
    }

    cart.items = cart.items.filter((i) => i.product !== req.params.productId);
    await cart.save();
    res.json(cart);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

export default router;
