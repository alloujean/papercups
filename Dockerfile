# -----------------------------
# Builder
# -----------------------------
FROM node:20.17.0-alpine AS builder

# Installer les dépendances système nécessaires
RUN apk add --no-cache erlang git make gcc libc-dev python3 curl bash ncurses-libs

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY assets/package.json assets/package-lock.json ./assets/

# Installer les dépendances npm
RUN npm install --prefix=assets

# Copier les fichiers sources
COPY priv priv
COPY assets assets

# Définir la variable pour supporter OpenSSL legacy provider
ENV NODE_OPTIONS=--openssl-legacy-provider

# Build React
RUN npm run build --prefix=assets

# -----------------------------
# Application
# -----------------------------
FROM alpine:3.18 AS app

# Installer les dépendances nécessaires
RUN apk add --no-cache openssl ncurses-libs bash

# Créer un utilisateur pour l'application
RUN adduser -h /app -u 1000 -s /bin/sh -D papercupsuser

# Définir le répertoire de travail
WORKDIR /app

# Copier depuis le builder
COPY --from=builder /app/priv priv
COPY --from=builder /app/assets/build assets/build

# Définir l'utilisateur
USER papercupsuser

# Commande par défaut (à adapter selon ton entrypoint)
CMD ["sh"]
