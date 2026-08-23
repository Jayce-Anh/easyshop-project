import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import cartRoutes from './routes/cart';
import orderRoutes from './routes/orders';
import { connectCache } from './cache';

const app = express();
const PORT = process.env.PORT || 6000;

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));
app.use(express.json());
app.use(cookieParser());

app.get('/health', (_req, res) => res.json({ status: 'ok', service: 'cart-service' }));

app.use('/cart', cartRoutes);
app.use('/orders', orderRoutes);

async function start(): Promise<void> {
  await connectCache();
  app.listen(PORT, () => {
    console.log(`cart-service running on port ${PORT}`);
  });
}

start().catch((error) => {
  console.error('cart-service failed to start:', error);
  process.exit(1);
});

export default app;
