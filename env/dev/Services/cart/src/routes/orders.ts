import { Router, Request, Response } from 'express';
import Order from '../models/order';
import Cart from '../models/cart';
import dbConnect from '../db';
import { verifyToken } from '../middleware/verifyToken';

const router = Router();

const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:5000';

async function getProductById(productId: string): Promise<any | null> {
  try {
    const res = await fetch(`${PRODUCT_SERVICE_URL}/products/${productId}`);
    if (!res.ok) return null;
    return res.json();
  } catch {
    return null;
  }
}

// GET /orders
router.get('/', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const page = parseInt((req.query.page as string) || '1');
    const limit = parseInt((req.query.limit as string) || '5');
    const skip = (page - 1) * limit;

    const orders = await Order.find({ user: req.user!.userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const populatedOrders = await Promise.all(
      orders.map(async (order) => {
        const populatedItems = await Promise.all(
          order.items.map(async (item) => {
            const product = await getProductById(item.product);
            return {
              ...item,
              product: product
                ? { _id: product._id, title: product.title, price: product.price, image: product.image }
                : null,
            };
          })
        );
        return { ...order.toObject(), items: populatedItems };
      })
    );

    res.json({ orders: populatedOrders, page, limit });
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// POST /orders - create order from cart
router.post('/', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const { shippingAddress, billingAddress, paymentMethod, items, total } = req.body;

    if (!items || !Array.isArray(items) || items.length === 0) {
      res.status(400).json({ error: 'Invalid order items' });
      return;
    }
    if (!shippingAddress || !billingAddress) {
      res.status(400).json({ error: 'Shipping and billing addresses are required' });
      return;
    }
    if (!paymentMethod) {
      res.status(400).json({ error: 'Payment method is required' });
      return;
    }

    const mappedShippingAddress = {
      fullName: shippingAddress.title,
      address: shippingAddress.streetAddress,
      city: shippingAddress.city,
      postalCode: shippingAddress.zip,
      country: shippingAddress.country,
    };

    const order = await Order.create({
      user: req.user!.userId,
      items: items.map((item: { productId: string; quantity: number; price: number }) => ({
        product: item.productId,
        quantity: item.quantity,
        price: item.price,
      })),
      total,
      shippingAddress: mappedShippingAddress,
      paymentMethod,
      status: 'pending',
      paymentStatus: 'pending',
    });

    await Cart.findOneAndDelete({ user: req.user!.userId });

    res.status(201).json({ message: 'Order created successfully', order });
  } catch (error: any) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: error.message || 'Failed to create order' });
  }
});

// GET /orders/:orderId
router.get('/:orderId', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const order = await Order.findOne({ _id: req.params.orderId, user: req.user!.userId });
    if (!order) {
      res.status(404).json({ error: 'Order not found' });
      return;
    }
    res.json(order);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// PUT /orders/:orderId - update status (admin)
router.put('/:orderId', verifyToken, async (req: Request, res: Response) => {
  try {
    if (req.user?.role !== 'admin') {
      res.status(403).json({ error: 'Unauthorized' });
      return;
    }
    await dbConnect();
    const order = await Order.findByIdAndUpdate(
      req.params.orderId,
      { status: req.body.status },
      { new: true }
    );
    if (!order) {
      res.status(404).json({ error: 'Order not found' });
      return;
    }
    res.json(order);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// DELETE /orders/:orderId - cancel order
router.delete('/:orderId', verifyToken, async (req: Request, res: Response) => {
  try {
    await dbConnect();
    const order = await Order.findOne({ _id: req.params.orderId, user: req.user!.userId });
    if (!order) {
      res.status(404).json({ error: 'Order not found' });
      return;
    }
    if (order.status !== 'pending') {
      res.status(400).json({ error: 'Cannot cancel order in current status' });
      return;
    }
    order.status = 'cancelled';
    await order.save();
    res.json(order);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

export default router;
