# 06 · Installer et comprendre Docker

**Objectif :** installer Docker, et savoir lancer, inspecter, arrêter et supprimer un conteneur, avec ou sans Docker Compose.

**Durée :** 1 heure.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Docker** | Un outil qui fait tourner des logiciels dans des boîtes isolées, les conteneurs. Chaque boîte contient le logiciel et tout ce dont il a besoin, sans rien installer sur le serveur lui-même. |
| **Image** | Le modèle figé d'un logiciel prêt à tourner, par exemple `postgres:17`. Comme une recette de cuisine : elle ne fait rien seule. |
| **Conteneur** | Une image en cours d'exécution. Comme le plat cuisiné d'après la recette. On peut lancer plusieurs conteneurs depuis la même image. |
| **Tag** | La version d'une image, après les deux-points : dans `postgres:17`, le tag est `17`. |
| **Registre** | Le magasin d'images en ligne. Le principal est Docker Hub. `docker pull` y télécharge une image. |
| **Volume** | Un espace de stockage géré par Docker, qui survit à la suppression du conteneur. Un conteneur est jetable, ses données ne doivent pas l'être : elles vont dans un volume. |
| **Port publié** | Un pont entre un port du serveur et un port du conteneur : `8080:80` veut dire « ce qui arrive sur le port 8080 du serveur va au port 80 du conteneur ». |
| **Réseau Docker** | Un réseau privé entre conteneurs. Ils s'y joignent par leur nom, comme `postgres` ou `n8n`. |
| **Docker Compose** | Un outil qui décrit plusieurs conteneurs, leurs volumes et leur réseau dans un seul fichier, `docker-compose.yml`, et les lance d'une commande. |
| **YAML** | Le format du fichier Compose : des paires `clé: valeur`, organisées par **indentation** (les espaces en début de ligne). Une indentation fausse = un fichier invalide. |
| **Logs** (journaux) | Les messages qu'écrit un logiciel pendant qu'il tourne. Le premier endroit où chercher quand quelque chose ne marche pas. |

## Pourquoi Docker

Sans Docker, installer n8n demanderait d'installer Node.js dans la bonne version, Postgres, de les configurer, et de tout désinstaller proprement en cas d'erreur. Avec Docker :

- une ligne dans un fichier suffit à installer un logiciel, dans une version précise ;
- tout est décrit dans un fichier versionné dans Git : on reconstruit le serveur à l'identique en une commande ;
- supprimer un conteneur ne laisse aucune trace, et les données, rangées dans des volumes, restent.

## Pas à pas

### 1. Installer Docker

```bash
[PC] $ ssh agent
[VPS] $ curl -fsSL https://get.docker.com -o get-docker.sh
[VPS] $ sudo sh get-docker.sh
[VPS] $ rm get-docker.sh
```

- `curl -fsSL … -o get-docker.sh` : télécharge le script officiel d'installation de Docker dans un fichier ;
- `sudo sh get-docker.sh` : l'exécute en administrateur (il ajoute le dépôt de paquets Docker, puis installe Docker et le plugin Compose) ;
- `rm` supprime le script, devenu inutile.

Autorise `patrick` à utiliser Docker sans `sudo` :

```bash
[VPS] $ sudo usermod -aG docker patrick
[VPS] $ exit
[PC] $ ssh agent
```

Il faut se déconnecter et se reconnecter pour que le nouveau groupe soit pris en compte.

**À savoir :** être dans le groupe `docker` revient à être administrateur du serveur, car Docker peut tout faire. On n'y met donc que toi.

### 2. Ton premier conteneur

```bash
[VPS] $ docker run hello-world
```

Docker télécharge l'image `hello-world`, crée un conteneur, l'exécute : il affiche « Hello from Docker! » puis s'arrête.

### 3. Les commandes de base, sur un vrai serveur web

Lance un petit serveur web Nginx :

```bash
[VPS] $ docker run -d --name essai -p 127.0.0.1:8080:80 nginx:alpine
```

Décortiquons :

| Morceau | Sens |
|---|---|
| `docker run` | Crée et démarre un conteneur |
| `-d` | En arrière-plan (*detached*) : la commande te rend la main |
| `--name essai` | Le nom du conteneur, pour le désigner ensuite |
| `-p 127.0.0.1:8080:80` | Publie le port 80 du conteneur sur le port 8080 du serveur, **uniquement en local** (`127.0.0.1`) |
| `nginx:alpine` | L'image et son tag |

Puis observe-le :

```bash
[VPS] $ docker ps                      # liste les conteneurs qui tournent
[VPS] $ curl -s localhost:8080 | head  # interroge le serveur web : du HTML s'affiche
[VPS] $ docker logs essai              # affiche ses journaux : tu vois ta requête
[VPS] $ docker exec -it essai sh       # ouvre un terminal DANS le conteneur
/ # ls /usr/share/nginx/html           # les fichiers du site, vus de l'intérieur
/ # exit
[VPS] $ docker stop essai              # l'arrête
[VPS] $ docker ps -a                   # -a montre aussi les conteneurs arrêtés
[VPS] $ docker rm essai                # le supprime
[VPS] $ docker images                  # les images téléchargées restent
```

### 4. Le piège Docker et le pare-feu

**Docker contourne ufw.** Si tu publies un port avec `-p 8080:80` (sans `127.0.0.1:`), ce port est ouvert sur Internet, **même si ufw dit le contraire**. Docker écrit ses propres règles réseau, prioritaires sur celles d'ufw.

Les deux règles qu'on appliquera toujours :

1. Seul Caddy publie des ports vers l'extérieur (80 et 443).
2. Tout autre port publié l'est sur `127.0.0.1` uniquement, ou pas du tout.

Dans notre `docker-compose.yml`, n8n et Postgres n'ont aucune ligne `ports:` : ils sont joignables par Caddy via le réseau Docker privé, et par personne d'autre.

### 5. Docker Compose en pratique

Crée un dossier d'essai et un fichier Compose :

```bash
[VPS] $ mkdir ~/essai-compose && cd ~/essai-compose
[VPS] $ nano docker-compose.yml
```

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "127.0.0.1:8080:80"
    volumes:
      - ./site:/usr/share/nginx/html:ro
```

Puis :

```bash
[VPS] $ mkdir site && echo "<h1>Bonjour Patrick</h1>" > site/index.html
[VPS] $ docker compose up -d
[VPS] $ curl localhost:8080
[VPS] $ docker compose ps
[VPS] $ docker compose logs web
[VPS] $ docker compose down
```

- `volumes: - ./site:/usr/share/nginx/html:ro` : le dossier `site` du serveur apparaît dans le conteneur à l'endroit où Nginx cherche ses pages ; `:ro` = lecture seule (*read only*) ;
- `docker compose up -d` : lit le fichier et démarre tout en arrière-plan ;
- `docker compose down` : arrête et supprime les conteneurs, mais **pas** les volumes nommés. `down -v` supprimerait aussi les volumes : à n'utiliser que si tu veux tout effacer.

Modifie `site/index.html`, relance `curl localhost:8080` : la page a changé sans redémarrer le conteneur. C'est le principe du volume.

Nettoie :

```bash
[VPS] $ cd ~ && rm -rf ~/essai-compose
[VPS] $ docker system prune -a
```

`docker system prune -a` supprime les conteneurs arrêtés et les images inutilisées. Réponds `y`.

## Vérifie

- [ ] `docker run hello-world` fonctionne **sans** `sudo`.
- [ ] `docker compose version` affiche une version.
- [ ] Tu sais expliquer la différence entre une image, un conteneur et un volume.
- [ ] Tu sais pourquoi n8n et Postgres n'ont pas de ligne `ports:`.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `permission denied while trying to connect to the Docker daemon socket` | Le groupe `docker` n'est pas encore actif | Déconnecte-toi (`exit`) et reconnecte-toi |
| `port is already allocated` | Un autre conteneur utilise déjà ce port | `docker ps` pour le trouver, puis `docker stop` |
| `yaml: line X: did not find expected key` | Indentation fausse dans le YAML | Utilise des espaces, jamais de tabulations, et aligne les niveaux |

## Exercice : refais-le seul

Sans regarder : lance un conteneur `nginx:alpine` nommé `exo` sur le port local 9090, affiche ses logs, entre dedans, sors, arrête-le, supprime-le. Puis refais la même chose avec un fichier Compose.
