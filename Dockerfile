# Build (TS -> dist)
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
COPY tsconfig.json ./
COPY src ./src
RUN npm ci
RUN npm run build
RUN npm prune --production

# Runtime (pg_dump 15 para servidor 14.x)
FROM node:18-alpine
WORKDIR /app
RUN apk add --no-cache postgresql15-client

# Un solo prefijo configurable (sin obligación de subcarpetas)
ENV BACKUP_PREFIX=

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

# Crea /tmp/${BACKUP_PREFIX} si viene; si no, usa /tmp
ENTRYPOINT ["sh","-lc","\
  PREF=${BACKUP_PREFIX:-}; \
  PREF=${PREF#/}; PREF=${PREF%/}; \
  BASE=/tmp; \
  TARGET=$BASE; \
  [ -n \"$PREF\" ] && TARGET=\"$BASE/$PREF\"; \
  mkdir -p \"$TARGET\"; \
  export BACKUP_LOCAL_DIR=\"$TARGET\"; \
  export BACKUP_PREFIX=\"$PREF\"; \
  node dist/index.js \
"]
