import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import productRoutes from './routes/products';
import singleProductRoutes from './routes/singleProduct';
import dbConnect from './db';
import { seedProductsIfEmpty } from './seed';
import { connectCache } from './cache';

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));
app.use(express.json());
app.use(cookieParser());

app.get('/health', (_req, res) => res.json({ status: 'ok', service: 'product-service' }));

app.use('/products', productRoutes);
app.use('/singleProduct', singleProductRoutes);

async function start(): Promise<void> {
  await dbConnect();
  await connectCache();
  await seedProductsIfEmpty();
  app.listen(PORT, () => {
    console.log(`product-service running on port ${PORT}`);
  });
}

start().catch((error) => {
  console.error('product-service failed to start:', error);
  process.exit(1);
});

export default app;
