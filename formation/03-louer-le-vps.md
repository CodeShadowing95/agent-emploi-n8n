# 03 · Louer le VPS

**Objectif :** commander un serveur Ubuntu 24.04 adapté, et savoir lire ce que tu as acheté.

**Durée :** 20 minutes (plus le temps de livraison de l'hébergeur, souvent moins de 10 minutes).

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Hébergeur** | L'entreprise qui loue des serveurs (LWS, Hetzner, OVHcloud…). Elle s'occupe du matériel, de l'électricité et du réseau. |
| **vCPU** (processeur virtuel) | La part de processeur réservée à ton VPS. 2 vCPU = ton serveur peut faire deux calculs vraiment en parallèle. |
| **RAM** (mémoire vive) | La mémoire de travail. Les logiciels en cours d'exécution y vivent. n8n, Postgres et Caddy ensemble utilisent environ 1 à 1,5 Go ; on prend 4 Go pour être à l'aise. |
| **SSD NVMe** | Le disque de stockage, rapide. 40 Go suffisent largement ici. |
| **Distribution Linux** | Une version de Linux préparée par un éditeur. **Ubuntu** est la plus répandue sur les serveurs. |
| **LTS** (*Long Term Support*) | Une version maintenue longtemps (5 ans pour Ubuntu). 24.04 veut dire avril 2024. On prend toujours une LTS pour un serveur. |
| **Adresse IP** | Le numéro qui identifie ton serveur sur Internet, par exemple `203.0.113.42`. C'est son adresse postale. |
| **IPv4 / IPv6** | Deux formats d'adresse IP. IPv4 : quatre nombres séparés par des points. IPv6 : plus long, avec des `:`. On utilisera l'IPv4. |
| **Image** (d'un VPS) | Le système installé d'office sur le serveur à sa création. |
| **Root** | Le compte administrateur de Linux, qui a tous les droits. |

## Pourquoi ces choix

- **Ubuntu 24.04 LTS** : maintenu jusqu'en 2029, et c'est la distribution la plus documentée. La plupart des réponses que tu trouveras en ligne s'y appliquent.
- **Une image nue, pas une image « n8n préinstallé »** : certains hébergeurs proposent n8n tout prêt. Pour cette formation, on veut justement apprendre à l'installer : prends l'image Ubuntu simple.
- **4 Go de RAM** : 2 Go suffisent pour démarrer, mais 4 Go te laissent de la marge pour d'autres projets plus tard, pour un écart de prix minime.
- **Datacenter en France ou en Allemagne** : proche de toi (la connexion est plus rapide) et soumis au RGPD.

## Pas à pas

> **Ton serveur est chez AWS (EC2 ou Lightsail) ?** Lis ce chapitre pour comprendre, puis suis l'[annexe E](annexe-e-aws.md) : elle remplace les étapes 2 et 3, et adapte les chapitres 04, 05 et 07.

### 1. Choisir l'offre

Les offres équivalentes (prix indicatifs, à vérifier le jour de la commande) :

| Hébergeur | Offre | Ressources | Ordre de prix |
|---|---|---|---|
| LWS | VPS KVM S, image **Ubuntu 24.04** | 2 vCPU, 4 Go, 100 Go | environ 12 € TTC/mois |
| Hetzner | Cloud, plus petite offre x86 | 2 vCPU, 4 Go, 40 Go | environ 5 à 6 €/mois |
| OVHcloud | VPS, première gamme | 2 vCPU, 4 Go | environ 6 à 8 €/mois |

Méfie-toi des prix « premier mois » qui triplent ensuite : regarde toujours le prix de renouvellement.

### 2. Commander

Pendant la commande, l'hébergeur te pose généralement ces questions :

| Question | Ta réponse |
|---|---|
| Système / image | **Ubuntu 24.04** (pas de « n8n », pas de panneau d'administration type Plesk ou cPanel) |
| Localisation | France ou Allemagne |
| Clé SSH | Si on te la demande maintenant, va d'abord faire l'étape 1 du chapitre 04, puis colle ta clé publique ici. Sinon, passe : on l'ajoutera après. |
| Nom du serveur (*hostname*) | `agent-emploi` |
| Sauvegardes automatiques de l'hébergeur | Facultatif : nos propres sauvegardes viennent au chapitre 19 |

### 3. Récupérer les informations de livraison

Après la commande, tu reçois un mail ou un écran avec :

- **l'adresse IPv4** du serveur → note-la dans ton gestionnaire de mots de passe, entrée « VPS agent-emploi » ;
- **l'utilisateur** : `root` (parfois `ubuntu` chez certains hébergeurs) ;
- **un mot de passe root**, si tu n'as pas fourni de clé SSH → range-le dans le gestionnaire ; on le désactivera au chapitre 05.

Repère aussi dans l'espace client la **console web** (ou « console VNC », « console de secours ») : c'est un terminal du serveur ouvert dans ton navigateur. C'est ta roue de secours si un jour tu ne peux plus te connecter en SSH.

## Vérifie

- [ ] Tu as l'adresse IP du serveur, rangée dans ton gestionnaire.
- [ ] L'espace client indique que le serveur est « actif » ou « en ligne ».
- [ ] Tu sais où se trouve la console web de secours.

Test rapide depuis ton PC :

```bash
[PC] $ ping TON_IP
```

Des lignes `Réponse de …` (Windows) ou `64 bytes from …` (Mac) doivent défiler : le serveur est joignable. Sur Mac, arrête avec Ctrl + C.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `ping` ne répond pas | Serveur encore en installation, ou ping bloqué par l'hébergeur | Attends 10 minutes. Certains hébergeurs bloquent le ping : passe au chapitre 04, SSH dira la vérité |
| Pas d'image Ubuntu 24.04 proposée | Offre « préinstallée » choisie | Dans l'espace client, cherche « Réinstaller » et choisis Ubuntu 24.04 |

## Exercice : refais-le seul

Sans regarder ce chapitre, explique à voix haute à quoi servent la RAM, le vCPU, l'adresse IP et la console web. Puis va sur le site d'un autre hébergeur et retrouve l'offre équivalente à la tienne.
