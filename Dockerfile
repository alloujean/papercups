# -----------------------------
# Builder
# -----------------------------
FROM node:20.17.0-alpine AS builder

# Installer les dépendances système nécessaires
RUN apk add --no-cache git make gcc libc-dev python3 curl bash ncurses-libs

# Définir le répertoire de travail
WORKDIR /app

# Copier package.json et package-lock.json
COPY assets/package.json assets/package-lock.json ./assets/

# Installer les dépendances npm
RUN npm install --prefix=assets

# Copier les fichiers sources
COPY assets assets
COPY priv priv

# Définir la variable pour OpenSSL legacy
ENV NODE_OPTIONS=--openssl-legacy-provider

# Build React
RUN npm run build --prefix=assets

# -----------------------------
# Application
# -----------------------------
FROM nginx:alpine

# Copier le build React
COPY --from=builder /app/assets/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80 pour Traefik
EXPOSE 80

# Lancer nginx en foreground
CMD ["nginx", "-g", "daemon off;"]
