/** @type {import('next').NextConfig} */
const isExport = process.env.NEXT_OUTPUT === 'export';

const config = {
  output: isExport ? 'export' : 'standalone',
  trailingSlash: isExport,
  swcMinify: true,
  images: isExport ? { unoptimized: true } : undefined,
};

module.exports = config;