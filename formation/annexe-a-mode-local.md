# Annexe A · Mode local (sans VPS)

**Objectif :** faire tourner n8n et Postgres sur ton propre ordinateur, avec Docker, pour apprendre et tester avant (ou sans) louer un serveur.

**Durée :** 45 minutes.

## Mots nouveaux de cette annexe

| Mot | Définition simple |
|---|---|
| **localhost** | Le nom qui veut dire « cet ordinateur-ci ». `http://localhost:5678` ouvre le n8n qui tourne sur ta propre machine, et personne d'autre ne peut l'ouvrir. |
| **Docker Desktop** | L'application qui installe Docker sur Windows ou Mac, avec une petite fenêtre pour voir tes conteneurs. |
| **Fichier de surcharge** (*override*) | Un second fichier Compose qui modifie le premier sans le recopier. Ici, `docker-compose.local.yml` change seulement ce qui diffère en local. |
| **Tunnel** | Un passage qui rend accessible sur Internet un service de ton PC, sans ouvrir de port sur ta box. Cloudflare en fournit un gratuit. |

## Local ou VPS : ce qui change

| | Mode local | VPS |
|---|---|---|
| Coût | Gratuit | Environ 5 € par mois |
| Les agents tournent | Seulement quand ton PC est allumé et Docker lancé | Tout le temps |
| Adresse de n8n | `http://localhost:5678` | `https://TON_DOMAINE` |
| HTTPS, Caddy, domaine | Inutiles | Indispensables |
| Chapitres à faire | 01, 02, 06 (partie théorie), puis 10 à 21 | Tous |
| Boutons Telegram (validation) | Demandent un tunnel (section 5) | Marchent directement |

Le mode local est parfait pour apprendre n8n et construire tes agents. Pour un agent qui doit tourner chaque matin à 8 h, il faut le VPS. Bonne nouvelle : tout ce que tu construis en local se déplace sur le VPS en quelques minutes (section 7).

## Pourquoi un fichier à part

`docker-compose.yml` est écrit pour le serveur : n8n se cache derrière Caddy, en HTTPS. Sur ton PC, il n'y a ni domaine ni certificat. Plutôt que de modifier ce fichier (et risquer de casser le serveur), on lui ajoute `docker-compose.local.yml`, qui dit seulement :

| Ligne | Ce qu'elle fait |
|---|---|
| `ports: "127.0.0.1:5678:5678"` | Ouvre n8n sur ton PC, et uniquement pour ton PC (`127.0.0.1`), pas pour le reste du réseau |
| `N8N_HOST=localhost`, `N8N_PROTOCOL=http` | n8n sait qu'il est à l'adresse `http://localhost` |
| `WEBHOOK_URL=…` | L'adresse que n8n donne aux services extérieurs. `localhost` par défaut, ou ton tunnel |
| `N8N_SECURE_COOKIE=false` | Autorise la connexion sans HTTPS. **Uniquement en local.** |

Docker Compose lit les deux fichiers dans l'ordre et applique le second par-dessus le premier.

## Pas à pas

### 1. Installer Docker Desktop

1. Télécharge Docker Desktop sur [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/).
2. Installe-le, redémarre si demandé, puis lance-le. Sous Windows, accepte l'installation de **WSL 2** s'il la propose.
3. Vérifie dans un terminal :

```bash
[PC] $ docker --version
[PC] $ docker compose version
[PC] $ docker run --rm hello-world
```

La dernière commande doit afficher `Hello from Docker!`.

Sous Windows, ouvre **Git Bash** (installé au chapitre 02) pour toutes les commandes de cette annexe : les scripts du dépôt sont écrits en Bash.

### 2. Préparer le fichier `.env`

```bash
[PC] $ cd agent-emploi-n8n
[PC] $ git checkout main && git pull
[PC] $ cp .env.local.example .env
[PC] $ openssl rand -hex 24      # copie le résultat dans POSTGRES_PASSWORD
[PC] $ openssl rand -hex 32      # copie le résultat dans N8N_ENCRYPTION_KEY
```

Ouvre `.env` dans VS Code et remplis :

- `N8N_VERSION` : la dernière version stable, lue sur [github.com/n8n-io/n8n/releases](https://github.com/n8n-io/n8n/releases) (par exemple `2.45.7`, sans le `n8n@`) ;
- `POSTGRES_PASSWORD` et `N8N_ENCRYPTION_KEY` : les deux valeurs générées.

Range `N8N_ENCRYPTION_KEY` dans ton gestionnaire de mots de passe **tout de suite** : c'est elle qui te permettra de déménager sur le VPS sans refaire tes identifiants.

### 3. Lancer la stack

```bash
[PC] $ docker compose up -d postgres n8n
```

Lis la commande :

- `up -d` : démarrer en arrière-plan ;
- `postgres n8n` : seulement ces deux services. Caddy n'est pas lancé : on ne le nomme pas.

Et le fichier de surcharge ? Ton `.env` contient la ligne `COMPOSE_FILE=docker-compose.yml:docker-compose.local.yml`. Docker Compose la lit seul, et utilise donc les deux fichiers à chaque commande, y compris dans les scripts du dépôt. Tu n'as rien à retenir de plus.

Vérifie :

```bash
[PC] $ docker compose ps
[PC] $ docker compose logs --tail 20 n8n
```

Les deux services doivent être `running` (Postgres `healthy`), et le journal de n8n doit finir par `Editor is now accessible via: http://localhost:5678`.

### 4. Ouvrir n8n

Ouvre [http://localhost:5678](http://localhost:5678) et suis le chapitre 09 à partir de la création du compte propriétaire. La 2FA est facultative en local, mais fais-la pour t'entraîner.

Tu peux maintenant suivre les chapitres 10 à 18. Deux différences :

| Endroit | En local |
|---|---|
| URL de redirection Google (chapitre 11) | `http://localhost:5678/rest/oauth2-credential/callback`. Google accepte `localhost` sans HTTPS. |
| Dossier des fichiers (chapitre 16) | Le dossier `fichiers/` du dépôt, sur ton PC. Le chemin dans n8n reste `/home/node/.n8n-files/…`. |

### 5. Les boutons de validation Telegram : le tunnel

Quand n8n attend ta validation, le bouton **Approuver** de Telegram ouvre une adresse de n8n. Telegram refuse les adresses `localhost`, et ton téléphone ne pourrait de toute façon pas les ouvrir. Il faut donc une adresse publique temporaire : un tunnel.

1. Installe `cloudflared` :
   - Windows : `winget install --id Cloudflare.cloudflared`
   - Mac : `brew install cloudflared`
2. Lance le tunnel dans un terminal que tu laisses ouvert :

```bash
[PC] $ cloudflared tunnel --url http://localhost:5678
```

3. Dans ce qu'il affiche, repère l'adresse en `https://….trycloudflare.com`.
4. Dans `.env`, décommente la ligne `WEBHOOK_URL` et mets cette adresse, terminée par `/`.
5. Redémarre n8n pour qu'il la prenne en compte :

```bash
[PC] $ docker compose up -d n8n
```

Teste avec l'agent Relances (chapitre 15) : le bouton doit ouvrir une page « Response recorded » ou similaire.

À savoir :

- L'adresse change **à chaque** lancement de `cloudflared`. Il faut alors refaire les étapes 4 et 5.
- Pendant que le tunnel tourne, la page de connexion de ton n8n est visible sur Internet. Ton mot de passe et ta 2FA le protègent ; coupe le tunnel (Ctrl + C) quand tu as fini.
- Les déclencheurs qui **attendent** des appels extérieurs (Webhook, Telegram Trigger) ont le même besoin. Ceux qui **vont chercher** (Schedule, Gmail Trigger) marchent sans tunnel.

### 6. Les scripts du dépôt

Ils marchent aussi en local, depuis le dossier du dépôt :

```bash
[PC] $ ./scripts/export-workflows.sh   # exporter tes workflows vers workflows/
[PC] $ ./scripts/backup.sh             # sauvegarder dans backups/
```

Pas de crontab (chapitre 19) en local : lance `backup.sh` à la main avant une manipulation risquée.

### 7. Déménager sur le VPS le jour venu

1. En local : `./scripts/export-workflows.sh`, puis commit et push (chapitre 21).
2. Sur le VPS : suis les chapitres 03 à 09, en mettant dans le `.env` du serveur **la même** `N8N_ENCRYPTION_KEY` que sur ton PC.
3. Deux options pour récupérer ton travail :
   - **Tout récupérer** (workflows et identifiants) : fais `./scripts/backup.sh` en local, copie le fichier `backups/n8n-db-….sql.gz` sur le serveur avec `scp`, puis `./scripts/restore.sh` (chapitre 19). Grâce à la même clé, les identifiants restent lisibles.
   - **Repartir propre** : importe les fichiers de `workflows/` dans n8n (**Import from File**), puis recrée les identifiants.
4. Dans Google Cloud, ajoute l'URL de redirection du serveur (`https://TON_DOMAINE/rest/oauth2-credential/callback`) à côté de celle de `localhost`.
5. Republie chaque agent sur le serveur. Arrête la stack locale pour qu'un agent ne tourne pas deux fois : `docker compose down`.

## Arrêter, relancer, tout effacer

| Je veux… | Commande |
|---|---|
| Arrêter (les données restent) | `docker compose stop` |
| Relancer | `docker compose up -d postgres n8n` |
| Tout supprimer, conteneurs **et données** | `docker compose down -v` (irréversible) |

Docker Desktop peut se lancer au démarrage de ton PC : **Settings** → **General** → **Start Docker Desktop when you sign in**. Les conteneurs redémarrent alors seuls (`restart: unless-stopped`).

## Vérifie

- [ ] `http://localhost:5678` affiche n8n, et `http://localhost:5678/healthz` répond `{"status":"ok"}`.
- [ ] Ta `N8N_ENCRYPTION_KEY` est dans ton gestionnaire de mots de passe.
- [ ] Après `docker compose stop` puis `docker compose up -d postgres n8n`, tes workflows sont toujours là.
- [ ] Avec le tunnel, un bouton **Approuver** de Telegram fait avancer un workflow.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `Cannot connect to the Docker daemon` | Docker Desktop n'est pas lancé | Lance-le, attends la baleine fixe, réessaie |
| `port is already allocated` sur 5678 | Un autre n8n tourne déjà (par exemple installé avec `npx`) | Arrête-le, ou change le premier `5678` dans `docker-compose.local.yml` |
| Page blanche ou message sur les cookies sécurisés | La surcharge n'est pas prise en compte | Vérifie que ton `.env` vient de `.env.local.example` et contient `COMPOSE_FILE`, puis `docker compose up -d n8n` |
| `./scripts/backup.sh: Permission denied` | Script non exécutable | `chmod +x scripts/*.sh`, ou `bash scripts/backup.sh` |
| Telegram : `Bad Request: … button URL … is invalid` | `WEBHOOK_URL` vaut encore `localhost` | Section 5 : tunnel, `.env`, redémarrage |
| Le bouton Telegram ouvre une page d'erreur | L'adresse du tunnel a changé | Recopie la nouvelle adresse dans `.env`, `docker compose up -d n8n` |

## Exercice : refais-le seul

Supprime tout (`docker compose down -v`, puis supprime `.env`), et réinstalle le mode local sans regarder cette annexe. Puis exporte un workflow, sauvegarde la base, efface à nouveau tout, et restaure la sauvegarde : ton workflow doit revenir avec ses identifiants.
