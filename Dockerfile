# ---------- Build (Node) ----------
FROM node:18-alpine AS build
WORKDIR /root

# Copia manifiestos primero para aprovechar cache de capa
COPY package*.json ./
COPY tsconfig.json ./
COPY src ./src

# Si tienes package-lock.json, usa npm ci; si no, cae a npm install
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

RUN npm run build
RUN npm prune --production

# ---------- Runtime (pg_dump 14 + Node) ----------
FROM postgres:14-alpine
WORKDIR /root

# Instala Node para ejecutar tu app
RUN apk add --no-cache nodejs npm

# Copia artefactos del build
COPY --from=build /root/node_modules ./node_modules
COPY --from=build /root/dist ./dist

# (Opcional, útil para debug rápido)
# RUN pg_dump --version

ENTRYPOINT ["node", "dist/index.js"]
