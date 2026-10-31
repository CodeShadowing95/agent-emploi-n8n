#!/usr/bin/env bash
# Exporte tous les workflows de n8n dans workflows/, un fichier JSON par workflow,
# en retirant les données de test épinglées (pinData) qui peuvent contenir de vrais mails.
# Les identifiants ne sont jamais exportés : seules leurs références (id, nom) le sont.
set -euo pipefail

cd "$(dirname "$0")/.."
command -v jq >/dev/null || { echo "jq est requis : sudo apt install -y jq"; exit 1; }

docker compose exec -T n8n sh -c 'rm -rf /tmp/export && mkdir -p /tmp/export && n8n export:workflow --all --separate --output=/tmp/export/'
rm -rf /tmp/n8n-export && mkdir -p /tmp/n8n-export
docker compose cp n8n:/tmp/export/. /tmp/n8n-export/

for f in /tmp/n8n-export/*.json; do
  nom=$(jq -r '.name' "$f" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')
  jq 'del(.pinData)' "$f" > "workflows/${nom}.json"
  echo "Exporté : workflows/${nom}.json"
done
