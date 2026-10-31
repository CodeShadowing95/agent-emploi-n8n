#!/usr/bin/env bash
# Restaure la base Postgres depuis une sauvegarde faite par backup.sh.
# Usage : ./scripts/restore.sh backups/n8n-db-AAAA-MM-JJ_HHMM.sql.gz
# Attention : remplace entièrement la base actuelle.
set -euo pipefail

cd "$(dirname "$0")/.."
fichier="${1:?Usage : ./scripts/restore.sh backups/n8n-db-....sql.gz}"
[ -f "$fichier" ] || { echo "Fichier introuvable : $fichier"; exit 1; }

read -r -p "Remplacer la base actuelle par $fichier ? (oui/non) " reponse
[ "$reponse" = "oui" ] || { echo "Annulé."; exit 0; }

echo "Arrêt de n8n"
docker compose stop n8n

echo "Recréation de la base vide"
docker compose exec -T postgres psql -U n8n -d postgres -c "DROP DATABASE IF EXISTS n8n;" -c "CREATE DATABASE n8n OWNER n8n;"

echo "Chargement de la sauvegarde"
gunzip -c "$fichier" | docker compose exec -T postgres psql -q -U n8n -d n8n

echo "Redémarrage de n8n"
docker compose start n8n
echo "Restauration terminée. Vérifie tes workflows dans l'interface."
