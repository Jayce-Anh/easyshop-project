import Redis from 'ioredis';

const host = process.env.CACHE_HOST;

export const cache = host
  ? new Redis({
      host,
      port: Number(process.env.CACHE_PORT || 6379),
      password: process.env.CACHE_PASSWORD || undefined,
      tls: process.env.CACHE_TLS === 'true' ? {} : undefined,
      lazyConnect: true,
      maxRetriesPerRequest: 2,
    })
  : null;

export async function connectCache(): Promise<void> {
  if (!cache) {
    console.log('Cache disabled (CACHE_HOST not set)');
    return;
  }

  try {
    await cache.connect();
    console.log(`Valkey connected at ${host}`);
  } catch (error) {
    console.error('Valkey connect failed, continuing without cache:', error);
  }
}

export async function cacheGet<T>(key: string): Promise<T | null> {
  if (!cache) return null;
  try {
    const value = await cache.get(key);
    return value ? (JSON.parse(value) as T) : null;
  } catch (error) {
    console.error('Cache get failed:', error);
    return null;
  }
}

export async function cacheSet(key: string, value: unknown, ttlSeconds = 60): Promise<void> {
  if (!cache) return;
  try {
    await cache.set(key, JSON.stringify(value), 'EX', ttlSeconds);
  } catch (error) {
    console.error('Cache set failed:', error);
  }
}

export async function cacheDelByPrefix(prefix: string): Promise<void> {
  if (!cache) return;
  try {
    const keys = await cache.keys(`${prefix}*`);
    if (keys.length) await cache.del(...keys);
  } catch (error) {
    console.error('Cache invalidate failed:', error);
  }
}
