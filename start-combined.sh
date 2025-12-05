#!/bin/sh

# Démarrer Nginx en arrière-plan
nginx

# Attendre que la DB soit prête
sleep 5

# Créer la DB et migrer
/entrypoint.sh db createdb
/entrypoint.sh db migrate

# Démarrer le backend Phoenix
exec /entrypoint.sh run
