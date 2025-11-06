# Etapa de build (Node)
FROM node:18-alpine AS build
WORKDIR /root

# copia package.json y (si existe) package-lock.json
COPY package*.json ./
COPY tsconfig.json ./
COPY src ./src

# usa cache de npm y fallback si no hay lockfile
RUN --mount=type=cache,target=/root/.npm \
    if [ -f package-lock.json ]; then \
      npm ci; \
    else \
      npm install; \
    fi

RUN npm run build
RUN npm prune --production

# Etapa de runtime con pg_dump 14 (para backups)
FROM postgres:14-alpine
WORKDIR /root

# Node para ejecutar tu app
RUN apk add --no-cache nodejs npm

# Artefactos de build
COPY --from=build /root/node_modules ./node_modules
COPY --from=build /root/dist ./dist

ENTRYPOINT ["node", "dist/index.js"]
