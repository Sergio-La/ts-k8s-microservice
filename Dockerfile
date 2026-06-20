# syntax=docker/dockerfile:1

# ===== Stage 1: Builder =====
# Compila TypeScript -> JavaScript usando TODAS las dependencias (incluidas dev)
# Tag pinado (alpine3.20) para reproducibilidad
FROM node:20-alpine3.20 AS builder

WORKDIR /app

# Copiamos primero los manifiestos para aprovechar el caché de capas
COPY package.json package-lock.json ./
RUN npm ci

# Copiamos configuración de TS y código fuente
COPY tsconfig.json ./
COPY src ./src

# Compilamos el proyecto
RUN npm run build


# ===== Stage 2: Runner (imagen final mínima) =====
FROM node:20-alpine3.20 AS runner

ENV NODE_ENV=production

# tini como init: propagación correcta de SIGTERM y evita procesos zombi
RUN apk add --no-cache tini

WORKDIR /app

# Instalamos SOLO dependencias de producción (capa cachable independiente del código)
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Traemos solo el código ya compilado desde el builder
COPY --from=builder /app/dist ./dist

# Usuario no privilegiado (la imagen node:alpine incluye 'node', UID 1000)
USER node

EXPOSE 3000

# Healthcheck basado en el endpoint /health
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1

# tini como PID 1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/index.js"]
