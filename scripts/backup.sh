#!/usr/bin/env bash
# Sauvegarde la base Postgres et le dossier de n8n dans backups/.
# À lancer depuis la racine du dépôt. Exemple de crontab (chaque nuit à 3 h) :
#   0 3 * * * cd /home/patrick/agent-emploi-n8n && ./scripts/backup.sh >> backups/backup.log 2>&1
set -euo pipefail

cd "$(dirname "$0")/.."
date_du_jour=$(date +%Y-%m-%d_%H%M)
mkdir -p backups

echo "[$(date)] Sauvegarde de la base Postgres"
docker compose exec -T postgres pg_dump -U n8n -d n8n | gzip > "backups/n8n-db-${date_du_jour}.sql.gz"

echo "[$(date)] Sauvegarde du dossier de n8n"
docker run --rm \
  --volumes-from "$(docker compose ps -q n8n)" \
  -v "$PWD/backups:/sauvegardes" \
  alpine tar czf "/sauvegardes/n8n-data-${date_du_jour}.tgz" -C /home/node/.n8n .

echo "[$(date)] Suppression des sauvegardes de plus de 14 jours"
find backups -name 'n8n-*' -mtime +14 -delete

echo "[$(date)] Terminé : backups/n8n-db-${date_du_jour}.sql.gz"
