# 08 · Déployer la stack

**Objectif :** n8n, Postgres et Caddy tournent sur ton serveur, lancés depuis le dépôt, et redémarrent seuls après une panne.

**Durée :** 1 heure.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Stack** | L'ensemble des logiciels qui fonctionnent ensemble pour rendre un service. Ici : Caddy + n8n + Postgres. |
| **Base de données** | Un logiciel spécialisé dans le rangement et la recherche de données. **Postgres** (ou PostgreSQL) est l'une des plus fiables. |
| **Reverse proxy** | Un intermédiaire placé devant une application : il reçoit les visiteurs, gère le HTTPS, et transmet les requêtes à l'application cachée derrière. **Caddy** joue ce rôle. |
| **Variable d'environnement** | Un réglage donné à un programme au moment de son lancement, sous la forme `NOM=valeur`. |
| **Fichier `.env`** | Le fichier où l'on écrit ces variables, notamment les secrets. Docker Compose le lit automatiquement. Il n'est **jamais** versionné dans Git. |
| **Clé de chiffrement** | Une longue suite de caractères aléatoires qui sert à chiffrer les identifiants enregistrés dans n8n. Sans elle, ils sont illisibles. |
| **Healthcheck** | Un test régulier qui vérifie qu'un service répond vraiment, pas seulement qu'il est lancé. |
| **`openssl rand -hex 32`** | Une commande qui génère 32 octets aléatoires, écrits en hexadécimal (64 caractères de 0 à 9 et de a à f). Parfait pour un mot de passe ou une clé. |

## Pourquoi déployer depuis le dépôt

Le serveur ne doit contenir **rien** qui ne vienne du dépôt, à part le fichier `.env` et les données. Ainsi, si le serveur disparaît, tu en loues un autre, tu clones, tu remets ton `.env` et une sauvegarde : tout revient. C'est ce qu'on appelle une infrastructure reproductible.

## Le fichier `docker-compose.yml`, ligne par ligne

Ouvre-le dans VS Code sur ton PC et lis-le avec ce tableau à côté.

### Service `postgres`

| Ligne | Ce qu'elle fait | Pourquoi |
|---|---|---|
| `image: postgres:17` | Utilise l'image officielle de Postgres, version 17 | n8n 2.x exige Postgres 17 ou plus récent |
| `restart: unless-stopped` | Relance le conteneur après un plantage ou un redémarrage du serveur | L'agent doit tourner sans toi. Seul un `docker compose stop` volontaire l'arrête |
| `POSTGRES_DB=n8n`, `POSTGRES_USER=n8n` | Crée au premier démarrage une base `n8n` et un utilisateur `n8n` | n8n s'y connectera avec ces noms |
| `POSTGRES_PASSWORD=${POSTGRES_PASSWORD}` | Le mot de passe, lu dans `.env` | Le secret n'est jamais écrit dans le fichier versionné |
| `postgres_data:/var/lib/postgresql/data` | Range les données dans le volume `postgres_data` | Elles survivent aux mises à jour et aux suppressions de conteneur |
| `healthcheck` / `pg_isready` | Toutes les 10 s, vérifie que Postgres accepte les connexions | Pour que n8n attende une base vraiment prête |

### Service `n8n`

| Ligne | Ce qu'elle fait | Pourquoi |
|---|---|---|
| `image: docker.n8n.io/n8nio/n8n:${N8N_VERSION}` | L'image officielle de n8n, dans la version écrite dans `.env` | Une version figée : rien ne change sans ta décision |
| `depends_on` + `condition: service_healthy` | Démarre n8n seulement quand le healthcheck de Postgres est vert | Sinon n8n démarre trop tôt et plante au premier lancement |
| `DB_TYPE=postgresdb` et `DB_POSTGRESDB_*` | Indique à n8n d'utiliser Postgres, à l'adresse `postgres` | Sur le réseau privé de Compose, chaque service se joint par son nom |
| `N8N_HOST` | L'adresse publique de n8n | Pour fabriquer les bons liens |
| `N8N_LISTEN_ADDRESS=0.0.0.0` | n8n écoute sur toutes les interfaces IPv4 du conteneur | Évite une erreur de démarrage sur les machines sans IPv6 |
| `N8N_PROTOCOL=https` | n8n sait qu'il est servi en HTTPS (par Caddy) | Pour les cookies sécurisés et les liens |
| `WEBHOOK_URL=https://${N8N_HOST}/` | L'adresse que n8n donne à Telegram, Google… pour le rappeler | Sans elle, les webhooks pointeraient vers `localhost` et n'arriveraient jamais |
| `N8N_ENCRYPTION_KEY` | La clé qui chiffre tes identifiants | Perdue = tous les identifiants à recréer |
| `GENERIC_TIMEZONE`, `TZ` | Fuseau Europe/Paris | « Tous les jours à 8 h » veut dire 8 h à Paris |
| `N8N_DIAGNOSTICS_ENABLED=false` | Désactive l'envoi de statistiques d'usage à n8n | Moins de données qui sortent |
| `EXECUTIONS_DATA_PRUNE=true`, `EXECUTIONS_DATA_MAX_AGE=336` | Efface l'historique des exécutions de plus de 336 heures (14 jours) | La base ne grossit pas sans fin, et les mails lus ne traînent pas |
| `n8n_data:/home/node/.n8n` | Le dossier interne de n8n, dans un volume | Il contient sa configuration |
| `./fichiers:/home/node/.n8n-files` | Le dossier `fichiers` du serveur apparaît dans n8n | Depuis n8n 2.0, les nœuds de fichiers ne peuvent lire **que** ce dossier. C'est là que tu déposeras tes CV en PDF |

Remarque : n8n n'a **aucune** ligne `ports:`. Il est invisible depuis Internet ; seul Caddy peut le joindre.

### Service `caddy`

| Ligne | Ce qu'elle fait | Pourquoi |
|---|---|---|
| `ports: "80:80"` et `"443:443"` | Les deux seules portes publiées | HTTP (pour Let's Encrypt et la redirection) et HTTPS |
| `./caddy/Caddyfile:/etc/caddy/Caddyfile:ro` | Donne à Caddy sa configuration, en lecture seule | Le fichier vient du dépôt |
| `caddy_data:/data` | Garde les certificats dans un volume | Sinon Caddy redemanderait un certificat à chaque redémarrage et atteindrait les limites de Let's Encrypt |

### Le `Caddyfile`

```
{$N8N_HOST} {
    encode gzip
    reverse_proxy n8n:5678
}
```

- `{$N8N_HOST}` : l'adresse, lue dans l'environnement. Quand Caddy voit un nom de domaine, il active automatiquement le HTTPS ;
- `encode gzip` : compresse les pages, pour qu'elles se chargent plus vite ;
- `reverse_proxy n8n:5678` : transmet tout au conteneur `n8n`, sur son port interne 5678.

## Pas à pas

### 1. Cloner le dépôt sur le serveur

```bash
[PC] $ ssh agent
[VPS] $ git clone https://github.com/CodeShadowing95/agent-emploi-n8n.git
[VPS] $ cd agent-emploi-n8n
[VPS] $ ls -la
```

### 2. Créer le fichier `.env`

```bash
[VPS] $ cp .env.example .env
[VPS] $ chmod 600 .env
```

`chmod 600` : seul toi peux lire et écrire ce fichier. Génère maintenant les deux secrets :

```bash
[VPS] $ openssl rand -hex 24
[VPS] $ openssl rand -hex 32
```

Copie le premier résultat dans ton gestionnaire sous le nom `POSTGRES_PASSWORD`, le second sous `N8N_ENCRYPTION_KEY`. Puis ouvre le fichier :

```bash
[VPS] $ nano .env
```

Remplis les quatre valeurs :

```
N8N_VERSION=2.45.7
N8N_HOST=n8n.patrick-namegni.fr
POSTGRES_PASSWORD=<le premier résultat>
N8N_ENCRYPTION_KEY=<le second résultat>
```

Pour `N8N_VERSION`, prends la dernière version stable affichée sur [github.com/n8n-io/n8n/releases](https://github.com/n8n-io/n8n/releases) (celle marquée *Latest*). `2.45.7` est un exemple : c'était la version stable lors des tests de ce dépôt.

Pour `N8N_HOST`, mets ton adresse du chapitre 07, **sans** `https://` et sans `/` à la fin.

### 3. Préparer le dossier des fichiers

```bash
[VPS] $ mkdir -p fichiers
[VPS] $ sudo chown 1000:1000 fichiers
```

Dans son conteneur, n8n ne tourne pas en root mais sous l'utilisateur numéro 1000. Il doit être propriétaire du dossier pour lire et écrire tes PDF.

### 4. Lancer

```bash
[VPS] $ docker compose up -d
```

La première fois, Docker télécharge les trois images (environ 1 Go), puis démarre Postgres, attend qu'il soit prêt, démarre n8n, puis Caddy.

### 5. Surveiller le démarrage

```bash
[VPS] $ docker compose ps
```

Tu dois voir trois lignes en état `running`, et `postgres` marqué `(healthy)`.

```bash
[VPS] $ docker compose logs -f caddy
```

`-f` (*follow*) affiche les logs en continu. Attends une ligne contenant `certificate obtained successfully`, puis Ctrl + C.

```bash
[VPS] $ docker compose logs --tail 30 n8n
```

Tu dois lire `Editor is now accessible via`.

## Vérifie

- [ ] `docker compose ps` : trois services `running`, Postgres `healthy`.
- [ ] Les logs de Caddy contiennent `certificate obtained successfully`.
- [ ] Depuis ton PC, `curl https://TON_DOMAINE/healthz` répond `{"status":"ok"}`.
- [ ] `git status` sur le serveur ne montre **pas** `.env` (il est ignoré par Git).

Puis le test de résistance :

```bash
[VPS] $ sudo reboot
```

Attends une minute, reconnecte-toi, et lance `docker compose ps` dans le dossier : tout doit être revenu tout seul, grâce à `restart: unless-stopped`.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| Caddy : `challenge failed` ou `no such host` | Le DNS ne pointe pas encore vers le serveur, ou le port 80 est fermé | `nslookup` depuis ton PC ; `sudo ufw status` sur le serveur |
| `502 Bad Gateway` dans le navigateur | Caddy marche, mais n8n ne répond pas | `docker compose logs n8n` |
| n8n : `password authentication failed for user "n8n"` | Le mot de passe a changé après la création de la base | Le mot de passe est figé à la création du volume. Remets l'ancien, ou repars de zéro avec `docker compose down -v` (efface tout) |
| n8n redémarre en boucle | Erreur de configuration | `docker compose logs --tail 50 n8n` et cherche la première ligne `Error` |
| `variable is not set` | Une valeur manque dans `.env` | Relis le fichier |

## Exercice : refais-le seul

1. Arrête la stack (`docker compose down`), relance-la (`docker compose up -d`) et vérifie que rien n'est perdu.
2. Sans regarder, explique ce qui arriverait si tu ajoutais `ports: - "5678:5678"` au service n8n, et pourquoi on ne le fait pas.
3. Retrouve dans le tableau la ligne qui permet à n8n de lire tes CV, et explique le chemin d'un fichier déposé dans `~/agent-emploi-n8n/fichiers`.
