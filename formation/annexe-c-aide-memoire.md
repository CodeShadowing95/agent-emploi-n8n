# Annexe C · Aide-mémoire

Toutes les commandes et syntaxes de la formation, rangées par outil, sur une seule page. Garde-la ouverte dans un onglet.

## Se repérer dans le terminal

| Commande | Effet |
|---|---|
| `pwd` | Affiche le dossier où tu es |
| `ls -la` | Liste les fichiers, cachés compris |
| `cd dossier` · `cd ..` · `cd ~` | Entrer dans un dossier · remonter d'un cran · revenir à ton dossier personnel |
| `cat fichier` | Affiche un fichier |
| `less fichier` | Lit un long fichier (`q` pour quitter, `/mot` pour chercher) |
| `nano fichier` | Édite un fichier (Ctrl + O, Entrée : enregistrer ; Ctrl + X : quitter) |
| `cp a b` · `mv a b` · `rm a` | Copier · déplacer ou renommer · supprimer (sans corbeille) |
| `mkdir -p a/b` | Créer un dossier, et ses parents si besoin |
| `chmod +x script.sh` | Rendre un script exécutable |
| `whoami` · `hostname` | Qui suis-je · sur quelle machine |
| `history` | Les dernières commandes tapées |
| Flèche haut · Tab · Ctrl + C · Ctrl + L | Commande précédente · compléter un nom · interrompre · effacer l'écran |

## SSH (chapitre 04)

| Commande | Effet |
|---|---|
| `ssh-keygen -t ed25519 -C "pc-patrick"` | Créer une paire de clés |
| `ssh agent` | Se connecter, grâce à l'alias de `~/.ssh/config` |
| `ssh -v agent` | Se connecter en affichant le détail (pour dépanner) |
| `exit` ou Ctrl + D | Se déconnecter |
| `scp fichier agent:~/dossier/` | Copier du PC vers le serveur |
| `scp -r agent:~/dossier ./local` | Copier un dossier du serveur vers le PC |
| `ssh-keygen -R TON_IP` | Oublier l'empreinte d'un serveur réinstallé |

Le bloc de `~/.ssh/config` :

```
Host agent
    HostName TON_IP
    User patrick
    IdentityFile ~/.ssh/id_ed25519
```

## Système Ubuntu (chapitre 05)

| Commande | Effet |
|---|---|
| `sudo apt update && sudo apt upgrade -y` | Mettre à jour tous les paquets |
| `sudo apt install -y paquet` | Installer un paquet |
| `sudo systemctl status ssh` | État d'un service (`q` pour quitter) |
| `sudo systemctl restart ssh` | Redémarrer un service |
| `sudo journalctl -u ssh --since today` | Journal d'un service |
| `df -h /` | Espace disque libre |
| `free -h` | Mémoire et swap |
| `htop` | Processus en cours, en direct (`q` pour quitter) |
| `ls /var/run/reboot-required` | S'il existe, un redémarrage est conseillé |
| `sudo reboot` | Redémarrer le serveur |

## Pare-feu et protection (chapitre 05)

| Commande | Effet |
|---|---|
| `sudo ufw status verbose` | Règles actives |
| `sudo ufw allow 443/tcp` | Ouvrir un port |
| `sudo ufw delete allow 443/tcp` | Supprimer une règle |
| `sudo ufw enable` | Activer (après avoir autorisé le 22 !) |
| `sudo fail2ban-client status sshd` | Adresses bannies pour SSH |
| `sudo fail2ban-client set sshd unbanip ADRESSE` | Débannir une adresse |

## Docker (chapitre 06)

| Commande | Effet |
|---|---|
| `docker ps` · `docker ps -a` | Conteneurs en marche · tous |
| `docker images` | Images téléchargées |
| `docker logs -f NOM` | Journal d'un conteneur, en direct (Ctrl + C pour sortir) |
| `docker exec -it NOM sh` | Ouvrir un terminal dans un conteneur |
| `docker system df` | Place prise par Docker |
| `docker image prune -a` | Supprimer les images inutilisées |

## Docker Compose (chapitres 06, 08, 19)

À lancer depuis `~/agent-emploi-n8n`.

| Commande | Effet |
|---|---|
| `docker compose config -q` | Vérifier `docker-compose.yml` et `.env` (aucune sortie = OK) |
| `docker compose up -d` | Créer et démarrer, ou appliquer un changement |
| `docker compose ps` | État des services |
| `docker compose logs --tail 50 n8n` | 50 dernières lignes du journal de n8n |
| `docker compose logs -f` | Tous les journaux, en direct |
| `docker compose restart n8n` | Redémarrer un service (sans relire `.env`) |
| `docker compose stop` · `start` | Arrêter · relancer, sans rien supprimer |
| `docker compose down` | Supprimer les conteneurs, **garder** les données |
| `docker compose down -v` | Supprimer conteneurs **et données** (dangereux) |
| `docker compose pull` | Télécharger les nouvelles versions des images |
| `docker compose exec postgres psql -U n8n -d n8n` | Ouvrir la base (`\q` pour quitter) |

Mode local (annexe A) : mêmes commandes, avec `docker compose up -d postgres n8n` pour démarrer.

## Git (chapitres 02, 12, 21)

| Commande | Effet |
|---|---|
| `git status` | Ce qui a changé |
| `git diff` | Le détail des changements |
| `git checkout main && git pull` | Revenir sur `main` à jour |
| `git checkout -b nom-branche` | Créer une branche et y aller |
| `git add fichier` · `git add dossier/` | Préparer pour le commit |
| `git commit -m "feat: …"` | Enregistrer une étape |
| `git push -u origin nom-branche` | Envoyer la branche sur GitHub (la première fois) |
| `git push` | Envoyer les commits suivants |
| `git log --oneline -10` | Les 10 derniers commits |
| `git restore fichier` | Annuler les modifications non commitées d'un fichier |
| `git branch -d nom-branche` | Supprimer une branche locale fusionnée |

Types de commit : `feat` (nouveauté), `fix` (correction), `docs` (documentation), `chore` (entretien).

## Scripts du dépôt (chapitre 19)

| Commande | Effet |
|---|---|
| `./scripts/export-workflows.sh` | Exporter les workflows dans `workflows/`, sans données épinglées |
| `./scripts/backup.sh` | Sauvegarder base et données dans `backups/` |
| `./scripts/restore.sh backups/n8n-db-….sql.gz` | Restaurer une sauvegarde (demande `oui`) |

## Secrets

| Commande | Effet |
|---|---|
| `openssl rand -hex 24` | Mot de passe aléatoire (Postgres) |
| `openssl rand -hex 32` | Clé aléatoire (`N8N_ENCRYPTION_KEY`) |
| `grep N8N_VERSION .env` | Lire une valeur de `.env` sans tout afficher |

## Syntaxe cron (chapitres 12, 19)

```
┌───────── minute (0-59)
│ ┌─────── heure (0-23)
│ │ ┌───── jour du mois (1-31)
│ │ │ ┌─── mois (1-12)
│ │ │ │ ┌─ jour de la semaine (0-7 ; 0 et 7 = dimanche, 1 = lundi)
│ │ │ │ │
0 8 * * 1-5
```

| Expression | Quand |
|---|---|
| `0 8 * * 1-5` | 8 h 00, du lundi au vendredi |
| `30 8 * * 2-4` | 8 h 30, du mardi au jeudi |
| `0 17 * * 5` | Vendredi à 17 h 00 |
| `0 3 * * *` | Chaque nuit à 3 h 00 |
| `*/15 * * * *` | Toutes les 15 minutes |
| `0 9,14 * * *` | À 9 h et à 14 h |

`*` veut dire « tous », `1-5` « de 1 à 5 », `9,14` « 9 et 14 », `*/15` « tous les 15 ». Pour vérifier une expression : [crontab.guru](https://crontab.guru).

## Expressions n8n (chapitre 10)

Tout ce qui est entre `{{ }}` est calculé.

| Expression | Donne |
|---|---|
| `{{ $json.entreprise }}` | Le champ `entreprise` de l'item courant |
| `{{ $json["date envoi"] }}` | Un champ dont le nom contient un espace |
| `{{ $('Lire le suivi').item.json.email }}` | Le champ `email` de l'item lié, dans un nœud précédent |
| `{{ $('Lire le suivi').first().json.email }}` | Le champ du premier item de ce nœud |
| `{{ $json.texte.slice(0, 4000) }}` | Les 4 000 premiers caractères |
| `{{ $json.email.toLowerCase().trim() }}` | En minuscules, sans espaces autour |
| `{{ $json.score >= 70 }}` | `true` ou `false` |
| `{{ $json.contact \|\| 'Madame, Monsieur' }}` | Le contact, ou un texte par défaut s'il est vide |
| `{{ $now.toFormat('yyyy-MM-dd') }}` | La date du jour, `2026-11-13` |
| `{{ $now.minus({ days: 7 }).toFormat('yyyy-MM-dd') }}` | Il y a 7 jours |
| `{{ $today.weekday }}` | Jour de la semaine (1 = lundi … 7 = dimanche) |
| `{{ DateTime.fromISO($json.dateEnvoi).plus({ days: 7 }).toFormat('yyyy-MM-dd') }}` | Date d'envoi + 7 jours |
| `{{ $execution.id }}` | Le numéro de l'exécution |
| `{{ $workflow.name }}` | Le nom du workflow |

Dans un nœud **Code** : `$input.all()` (tous les items), `$input.first()`, `item.json.champ`, et le code doit `return` une liste d'objets `{ json: { … } }`.

## Nœuds n8n les plus utiles

| Besoin | Nœud |
|---|---|
| Démarrer à heure fixe | Schedule Trigger |
| Démarrer à chaque mail | Gmail Trigger |
| Démarrer quand un workflow échoue | Error Trigger |
| Lire ou écrire le suivi | Google Sheets |
| Appeler une API sans nœud dédié | HTTP Request |
| Garder certains items | Filter |
| Deux chemins selon une condition | IF |
| Plusieurs chemins selon une valeur | Switch |
| Ajouter, renommer, calculer des champs | Edit Fields (Set) |
| Ne garder que les N premiers | Limit |
| Réunir deux flux | Merge |
| Calcul sur mesure | Code |
| Faire réfléchir Claude | Basic LLM Chain + Anthropic Chat Model (+ Structured Output Parser) |
| Demander ta validation | Telegram → Send and Wait for Response (Approval) |
| Envoyer un mail | Gmail → Send |
| Lire un fichier (CV) | Read/Write Files from Disk |

## Adresses utiles

| Quoi | Où |
|---|---|
| Ton n8n | `https://TON_DOMAINE` (ou `http://localhost:5678` en local) |
| Santé de n8n | `https://TON_DOMAINE/healthz` |
| Versions de n8n | [github.com/n8n-io/n8n/releases](https://github.com/n8n-io/n8n/releases) |
| Documentation n8n | [docs.n8n.io](https://docs.n8n.io) |
| Forum n8n | [community.n8n.io](https://community.n8n.io) |
| Console Anthropic | [console.anthropic.com](https://console.anthropic.com) |
| Console Google Cloud | [console.cloud.google.com](https://console.cloud.google.com) |
| Console Apify | [console.apify.com](https://console.apify.com) |
| API France Travail | [francetravail.io](https://francetravail.io) |
| Vérifier une expression cron | [crontab.guru](https://crontab.guru) |
