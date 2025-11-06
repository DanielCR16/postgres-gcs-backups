# Etapa de build (Node)
FROM node:18-alpine AS build
WORKDIR /root
COPY package*.json ./
COPY tsconfig.json ./
COPY src ./src
RUN npm ci
RUN npm run build
RUN npm prune --production

# Etapa de runtime con pg_dump 14
FROM postgres:14-alpine
WORKDIR /root

# Instala Node para ejecutar la app
RUN apk add --no-cache nodejs npm

# Copia artefactos
COPY --from=build /root/node_modules ./node_modules
COPY --from=build /root/dist ./dist

# (Opcional) utilidades extra:
# RUN apk add --no-cache bash curl

ENTRYPOINT ["node", "dist/index.js"]
