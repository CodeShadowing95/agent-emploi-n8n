# Annexe B · Dépannage

**Objectif :** retrouver seul la cause d'une erreur, avec une méthode qui marche à tous les coups, puis la corriger.

Les erreurs propres à chaque chapitre sont dans sa section **Si ça bloque**. Cette annexe donne la méthode générale et les erreurs qui reviennent partout.

## Mots nouveaux de cette annexe

| Mot | Définition simple |
|---|---|
| **Symptôme** | Ce que tu vois : une page qui ne s'ouvre pas, un message rouge. Ce n'est pas encore la cause. |
| **Cause** | La raison réelle du problème. Une même cause peut donner plusieurs symptômes. |
| **Message d'erreur** | Le texte qu'affiche le programme quand il échoue. Il contient presque toujours la réponse, à condition de le lire jusqu'au bout. |
| **Code HTTP** | Le nombre à trois chiffres que renvoie un service web : `200` = OK, `401`/`403` = accès refusé, `404` = introuvable, `429` = trop de demandes, `5xx` = le service a planté. |
| **Reproduire** | Refaire exprès l'action qui échoue, pour vérifier une hypothèse ou une correction. |

## La méthode en 6 étapes

1. **Lis le message d'erreur en entier.** Pas seulement la première ligne. Copie-le dans ton journal.
2. **Situe la panne.** Dans quelle couche est-elle ? Remonte la chaîne depuis le bas :

```
Ton PC ─► Internet / DNS ─► Serveur (SSH, ufw) ─► Docker ─► Caddy ─► n8n ─► Nœud ─► Service extérieur
```

   Le premier maillon qui ne répond pas est le coupable. La section suivante dit comment tester chaque maillon.
3. **Une seule hypothèse à la fois.** « Je pense que c'est le DNS parce que… ». Teste-la.
4. **Change une seule chose**, puis reproduis. Si tu changes trois choses et que ça marche, tu ne sauras pas laquelle a réglé le problème.
5. **Vérifie** que le symptôme a disparu, et que le reste marche encore.
6. **Note** dans ton journal : symptôme, cause, solution. La deuxième fois, tu iras dix fois plus vite.

Si tu tournes en rond plus de 30 minutes : fais une pause, puis relis le message d'erreur depuis le début. Ensuite seulement, cherche le message exact entre guillemets sur Internet ou sur [community.n8n.io](https://community.n8n.io).

## Tester chaque maillon

| Maillon | Test | Bon résultat |
|---|---|---|
| Internet depuis ton PC | Ouvrir n'importe quel site | Il s'affiche |
| DNS | `[PC] $ nslookup TON_DOMAINE` | L'adresse IP de ton VPS |
| Serveur joignable | `[PC] $ ssh agent` | Tu obtiens l'invite `patrick@…` |
| Pare-feu | `[VPS] $ sudo ufw status` | 22, 80 et 443 en `ALLOW` |
| Docker | `[VPS] $ docker compose ps` | 3 services `running`, Postgres `healthy` |
| Caddy et HTTPS | `[VPS] $ docker compose logs --tail 30 caddy` | `certificate obtained successfully`, aucune erreur |
| n8n | `[PC] $ curl https://TON_DOMAINE/healthz` | `{"status":"ok"}` |
| Un workflow | n8n → **Executions** → l'exécution en rouge | Le nœud en erreur est entouré de rouge, avec son message |
| Un service extérieur | Le message du nœud (voir les codes HTTP ci-dessous) | |

## Lire une exécution n8n en échec

1. Ouvre **Executions** (dans le workflow, onglet du haut, ou dans le menu de gauche pour tous les workflows).
2. Clique l'exécution en rouge : le workflow s'affiche tel qu'il a tourné.
3. Le nœud en échec est entouré de rouge. Clique-le : **Input** montre ce qu'il a reçu, **Output** l'erreur.
4. Regarde d'abord **Input** : la plupart des erreurs viennent d'une donnée mal formée **en amont**, pas du nœud lui-même.
5. Pour rejouer avec les mêmes données : **Debug in editor** (ou **Copy to editor**), corrige, puis **Execute workflow**.

## Les codes HTTP, traduits

| Code | Signifie | Cause probable dans ce projet |
|---|---|---|
| `400 Bad Request` | La demande est mal formée | Un JSON invalide, un champ manquant, une expression vide |
| `401 Unauthorized` | Pas reconnu | Clé d'API fausse, expirée ou révoquée ; jeton Google expiré |
| `403 Forbidden` | Reconnu, mais pas autorisé | Scope manquant (Google, France Travail), crédit épuisé |
| `404 Not Found` | L'adresse n'existe pas | Faute dans l'URL ; identifiant de feuille ou d'actor faux |
| `429 Too Many Requests` | Trop de demandes trop vite | Ralentis : moins d'items, ou **Retry On Fail** avec une attente |
| `500`, `502`, `503` | Le service a un problème | Chez eux : réessaie plus tard. `502` via Caddy : n8n est arrêté |

## Les erreurs qui reviennent partout

### Serveur et connexion

| Symptôme | Cause | Solution |
|---|---|---|
| `Permission denied (publickey)` | Mauvaise clé, ou mauvais utilisateur | `ssh -v agent` pour voir quelle clé est essayée ; vérifie `~/.ssh/config` |
| `Connection timed out` en SSH | Serveur éteint, ou port 22 fermé par ufw | Console de secours de l'hébergeur ; `sudo ufw allow 22/tcp` |
| `REMOTE HOST IDENTIFICATION HAS CHANGED` | Le serveur a été réinstallé | `ssh-keygen -R TON_IP`, puis reconnecte-toi |
| `sudo: command not found` ou `not in the sudoers file` | Tu es sur le mauvais compte | `whoami` ; reconnecte-toi avec `patrick` |
| `No space left on device` | Disque plein | `df -h /`, `docker image prune -a`, supprime les vieilles sauvegardes |

### Docker

| Symptôme | Cause | Solution |
|---|---|---|
| `permission denied while trying to connect to the Docker daemon socket` | Ton utilisateur n'est pas dans le groupe `docker`, ou tu ne t'es pas reconnecté | `sudo usermod -aG docker $USER`, puis déconnexion et reconnexion |
| Un conteneur `Restarting` en boucle | Il plante au démarrage | `docker compose logs --tail 50 NOM` : la cause est dans les dernières lignes |
| `variable is not set. Defaulting to a blank string` | Une valeur manque dans `.env` | Ouvre `.env`, remplis la variable nommée |
| `yaml: line X: …` | Faute d'indentation dans un fichier `.yml` | Espaces uniquement, jamais de tabulation ; même décalage que les lignes voisines |
| Les modifications de `.env` ne servent à rien | Le conteneur n'a pas été recréé | `docker compose up -d` (et non `restart`) |

### n8n

| Symptôme | Cause | Solution |
|---|---|---|
| `502 Bad Gateway` sur ton domaine | Caddy tourne, n8n non | `docker compose ps`, puis `docker compose logs n8n` |
| `Mismatching encryption keys` | `N8N_ENCRYPTION_KEY` différente de celle d'origine | Remets la clé d'origine, sauvegardée dans ton gestionnaire de mots de passe |
| Un agent ne se lance pas seul | Pas publié, ou publié avant la dernière modification | **Publish** (le bouton indique s'il y a des changements non publiés) |
| Il tourne à la mauvaise heure | Fuseau horaire | `GENERIC_TIMEZONE=Europe/Paris` dans `docker-compose.yml` ; **Settings** du workflow → **Timezone** |
| `Cannot read properties of undefined` dans un nœud Code | Un champ n'existe pas dans l'item | Regarde **Input** : le nom exact du champ, majuscules comprises |
| Une expression affiche `[undefined]` ou devient rouge | Nom de champ faux, ou nœud référencé qui n'a pas tourné | Glisse le champ depuis le panneau **Input** au lieu de le taper |
| `Referenced node is unexecuted` | `$('Nœud')` vise un nœud qui n'a pas tourné dans cette exécution | Exécute le workflow depuis le début, ou change de branche |
| Un nœud tourne une fois par item alors que tu voulais une seule fois | Comportement normal de n8n | **Settings** du nœud → **Execute Once** |
| `Access to the file is not allowed` | Le chemin n'est pas dans `/home/node/.n8n-files` | Range le fichier dans `fichiers/` du dépôt, chemin `/home/node/.n8n-files/NOM` |

### Services extérieurs

| Symptôme | Cause | Solution |
|---|---|---|
| Google : `redirect_uri_mismatch` | L'URL de redirection ne correspond pas | Copie-la depuis n8n, colle-la à l'identique dans Google Cloud |
| Google : ça marchait, puis `invalid_grant` après une semaine | Application en mode **Testing** : jetons valables 7 jours | Publie l'application (chapitre 11), puis reconnecte l'identifiant |
| Telegram : `chat not found` | Mauvais `chat_id`, ou tu n'as jamais écrit au bot | Envoie `/start` à ton bot, relis le `chat_id` (chapitre 11) |
| Anthropic : `credit balance is too low` | Plus de crédit | Recharge, et vérifie ta limite de dépense |
| Anthropic : `overloaded_error` | Service saturé un instant | **Settings** du nœud → **Retry On Fail** |
| Apify : `0 items` | Mots-clés trop précis, ou aucune offre ce jour-là | Teste l'actor sur la console Apify avec les mêmes paramètres |
| France Travail : `401` | Jeton refusé | Vérifie Client ID, Secret et scope `api_offresdemploiv2 o2dsoffre` |
| Structured Output Parser : `Failed to parse` | Claude a répondu hors du format | Baisse la température à 0 ; rappelle le format dans le prompt ; active **Retry On Fail** |

## Repartir d'un état sain

Quand tu ne comprends plus rien, ces gestes remettent les choses d'aplomb, du plus doux au plus fort :

1. Recharger la page n8n (Ctrl + F5).
2. `docker compose restart n8n`.
3. `docker compose down && docker compose up -d` : recrée les conteneurs, garde les données.
4. Restaurer la sauvegarde de la nuit (chapitre 19).

Jamais `docker compose down -v` sans sauvegarde récente : le `-v` efface les données.

## Demander de l'aide efficacement

Une bonne question contient :

- ce que tu voulais faire ;
- ce que tu as fait (les commandes, les réglages du nœud) ;
- le message d'erreur **complet**, copié, pas résumé ;
- ce que tu as déjà essayé.

Avant de coller quoi que ce soit, **retire les secrets** : clés d'API, mots de passe, contenu de `.env`, adresses mail réelles.

## Exercice : refais-le seul

Provoque trois pannes, une par une, et retrouve-les avec la méthode, sans regarder ce que tu as cassé : arrête le conteneur n8n, mets une fausse clé d'API dans l'identifiant Anthropic, et renomme une colonne de ta feuille de suivi. Pour chacune, note dans ton journal le maillon qui a lâché et le message qui te l'a dit.
