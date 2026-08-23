import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import authRoutes from './routes/auth';

const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));
app.use(express.json());
app.use(cookieParser());

app.get('/health', (_req, res) => res.json({ status: 'ok', service: 'auth-service' }));

app.use('/auth', authRoutes);

app.listen(PORT, () => {
  console.log(`auth-service running on port ${PORT}`);
});

export default app;
