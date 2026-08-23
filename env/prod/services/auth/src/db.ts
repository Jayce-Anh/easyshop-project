import mongoose from 'mongoose';

function buildMongoUri(): string {
  const host = process.env.DATABASE_HOST || 'localhost';
  const port = process.env.DATABASE_PORT || '27017';
  const username = process.env.DATABASE_USERNAME;
  const password = process.env.DATABASE_PASSWORD;
  const dbName = process.env.DATABASE_NAME || 'easyshop';

  if (username && password) {
    return `mongodb://${encodeURIComponent(username)}:${encodeURIComponent(password)}@${host}:${port}/${dbName}?authMechanism=SCRAM-SHA-1&retryWrites=false`;
  }

  return `mongodb://${host}:${port}/${dbName}`;
}

let isConnected = false;

async function dbConnect(): Promise<void> {
  if (isConnected) return;

  await mongoose.connect(buildMongoUri());
  isConnected = true;
  console.log('MongoDB connected');
}

export default dbConnect;
