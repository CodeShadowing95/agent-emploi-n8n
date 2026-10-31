# Agent emploi n8n

Un agent auto-hébergé qui automatise une recherche d'emploi : veille d'offres, lecture des réponses des recruteurs, relances et envois. **Rien ne part sans validation humaine.**

> Projet personnel et d'apprentissage, en cours de construction (novembre 2026).

## Le principe

**Claude réfléchit, n8n exécute, l'humain valide.**

- **n8n** (auto-hébergé) orchestre les workflows : déclencheurs, appels d'API, envois.
- **L'API Claude** classe les réponses des recruteurs, note les offres et rédige les relances, toujours en sortie structurée (JSON).
- **Telegram** sert à valider chaque envoi d'un clic (humain dans la boucle).
- **Google Sheets** tient le suivi des candidatures.

## Architecture

```
            ┌──────────── VPS Ubuntu · Docker Compose ────────────┐
Gmail ──┐   │  Caddy (HTTPS, seule porte ouverte)                 │   ┌── API Claude
Apify ──┼──►│     │                                               │◄─►├── Google Sheets
France  ┘   │  n8n (workflows) ◄──► Postgres 17                   │   └── Telegram
Travail     └─────────────────────────────────────────────────────┘
```

Seul Caddy publie des ports. n8n et Postgres restent dans le réseau privé de Docker.

## Les agents

| # | Agent | Déclencheur | État |
|---|---|---|---|
| 1 | Boîte de réception : classe les réponses et met à jour le suivi | Nouveau mail | À venir |
| 2 | Relances à J+7 et J+14, validées sur Telegram | Chaque jour ouvré | À venir |
| 3 | Envoi validé des candidatures, avec le CV en pièce jointe | Mardi au jeudi | À venir |
| 4 | Veille d'offres (LinkedIn via Apify, France Travail), notées sur 100 | Chaque matin | À venir |
| 5 | Rapport hebdomadaire | Vendredi | À venir |

## Installation

Prérequis : un VPS Ubuntu 24.04 sécurisé avec Docker, et un nom de domaine (ou un sous-domaine sslip.io) qui pointe vers lui.

```bash
git clone https://github.com/CodeShadowing95/agent-emploi-n8n.git
cd agent-emploi-n8n
cp .env.example .env   # puis remplir : version, adresse, mot de passe, clé de chiffrement
mkdir -p fichiers && sudo chown 1000:1000 fichiers
docker compose up -d
```

Ouvrir ensuite `https://<N8N_HOST>` et créer immédiatement le compte propriétaire.

## Exploitation

| Script | Rôle |
|---|---|
| `scripts/backup.sh` | Sauvegarde Postgres et le dossier n8n dans `backups/`, garde 14 jours |
| `scripts/restore.sh <fichier>` | Restaure la base depuis une sauvegarde |
| `scripts/export-workflows.sh` | Exporte les workflows dans `workflows/`, sans données de test |

À chaque push, la CI vérifie le `docker-compose.yml`, les scripts (shellcheck), les workflows JSON et l'absence de secrets (gitleaks).

## Sécurité et données

- Aucun secret dans le dépôt : `.env` est ignoré par Git et les identifiants restent chiffrés dans n8n.
- Injection de prompt : le contenu d'un mail reçu est traité comme une donnée. L'agent qui le lit n'a aucun outil d'envoi et sa sortie est limitée à une liste fermée de catégories.
- Données personnelles : le suivi reste dans Google Sheets, et l'historique des exécutions est purgé après 14 jours.

## Auteur

Patrick Namegni, développeur full stack. [LinkedIn](https://linkedin.com/in/frank-patrick-namegni)
