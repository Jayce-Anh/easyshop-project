/** @type {import('next').NextConfig} */
const config = {
  output: 'export',
  trailingSlash: true,
  swcMinify: true,
  images: { unoptimized: true },
};

module.exports = config;