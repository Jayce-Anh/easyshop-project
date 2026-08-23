FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
COPY package*.json ./
COPY .env ./
RUN npm install --omit=dev
COPY --from=builder /app/dist ./dist
ENV NODE_ENV=production
EXPOSE 4000
CMD ["node", "dist/app.js"]
