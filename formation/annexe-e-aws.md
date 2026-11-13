# Annexe E · Ton VPS sur AWS (EC2 ou Lightsail)

**Objectif :** adapter les chapitres 03, 04, 05 et 07 à un serveur loué chez AWS (Amazon Web Services). Tout le reste de la formation s'applique sans changement.

**Durée :** 30 minutes, à faire entre le chapitre 03 et le chapitre 04.

## Mots nouveaux de cette annexe

| Mot | Définition simple |
|---|---|
| **AWS** (*Amazon Web Services*) | Le service d'hébergement d'Amazon. Il loue des serveurs, du stockage et des centaines d'autres services, facturés à l'usage. |
| **EC2** (*Elastic Compute Cloud*) | Le service de serveurs « à la carte » d'AWS. Très souple, mais chaque option (disque, IP, trafic) se règle et se paie à part. |
| **Lightsail** | La version simplifiée d'EC2 : un prix fixe par mois qui inclut disque, IP et trafic. C'est l'équivalent AWS d'un VPS classique. |
| **Instance** | Le nom qu'AWS donne à un serveur. « Lancer une instance » = créer un serveur. |
| **AMI** (*Amazon Machine Image*) | L'image du système installé sur l'instance. Ici : Ubuntu 24.04 LTS. |
| **Région** | La ville où se trouve physiquement ton serveur. Choisis `eu-west-3` (Paris). |
| **Key pair** (paire de clés) | La paire de clés SSH qu'AWS associe à l'instance. AWS garde la clé publique sur le serveur ; toi, tu gardes la clé privée (un fichier `.pem`). |
| **Security Group** (groupe de sécurité) | Le pare-feu d'AWS, **devant** le serveur. Il bloque tout ce que tu n'as pas autorisé, avant même que ufw soit consulté. |
| **Elastic IP / Static IP** | Une adresse IP fixe que tu attaches à ton instance. Sans elle, l'IP publique change à chaque arrêt et redémarrage. |
| **EBS** | Le disque d'une instance EC2. Sa taille se choisit à la création (8 Go par défaut, trop peu pour nous). |
| **Budget** | Une alerte AWS qui t'écrit quand tes dépenses dépassent un montant. |

## Ce qui change par rapport à la formation

| Chapitre | Chez un hébergeur classique | Chez AWS |
|---|---|---|
| 03 | Mail de livraison avec IP et mot de passe root | Console AWS ; aucun mot de passe ; IP à rendre fixe |
| 04 | `ssh root@TON_IP` | `ssh -i cle.pem ubuntu@TON_IP` : l'utilisateur s'appelle `ubuntu` |
| 05 | ufw seul | **Security Group** (ou pare-feu Lightsail) **et** ufw |
| 05 | Copier la clé de root vers `patrick` | Copier la clé de `ubuntu` vers `patrick` |
| 07 | L'IP ne bouge pas | Attacher l'IP fixe **avant** de créer le nom de domaine |
| Console de secours | Console VNC de l'hébergeur | **EC2 Instance Connect** ou bouton **Connect using SSH** de Lightsail |

## Pas à pas

Repère d'abord quel service tu as utilisé : si l'adresse de ta console commence par `lightsail.aws.amazon.com`, c'est **Lightsail** ; si tu vois « EC2 » et « Instances », c'est **EC2**. Suis la colonne correspondante.

### 1. Vérifier la taille du serveur et du disque

n8n, Postgres et Caddy ont besoin d'au moins **2 Go de mémoire** et de **20 Go de disque**.

| | EC2 | Lightsail |
|---|---|---|
| Où regarder | **EC2** → **Instances** → ton instance → **Instance type**, et onglet **Storage** | Ton instance → onglet **Metrics** ou la carte de l'instance |
| Minimum | `t3.small` (2 Go) avec le swap du chapitre 05 ; `t3.medium` (4 Go) est confortable | Offre à 2 Go de mémoire ou plus |
| Disque | **30 Go** (type `gp3`) | Inclus dans l'offre |

Une instance `t2.micro` ou `t3.micro` (1 Go, souvent proposée en offre gratuite) est **trop petite** : n8n s'y arrêtera au premier gros workflow.

**Agrandir le disque EC2** s'il fait 8 Go :

1. **Instances** → ton instance → onglet **Storage** → clique le **Volume ID**.
2. **Actions** → **Modify volume** → **Size** : `30` → **Modify** → **Modify**.
3. Une fois connecté (étape 4), fais prendre la nouvelle taille au système :

```bash
[VPS] $ lsblk                                # repère le disque, souvent nvme0n1
[VPS] $ sudo growpart /dev/nvme0n1 1         # agrandit la partition 1
[VPS] $ sudo resize2fs /dev/nvme0n1p1        # agrandit le système de fichiers
[VPS] $ df -h /                              # doit afficher environ 29G
```

Si `lsblk` montre `xvda` au lieu de `nvme0n1`, remplace dans les deux commandes : `/dev/xvda 1` puis `/dev/xvda1`.

### 2. Rendre l'IP fixe

À faire **maintenant**, avant de noter l'adresse où que ce soit.

**EC2 :**

1. Menu de gauche → **Network & Security** → **Elastic IPs** → **Allocate Elastic IP address** → **Allocate**.
2. Sélectionne la nouvelle adresse → **Actions** → **Associate Elastic IP address**.
3. **Instance** : la tienne → **Associate**.

**Lightsail :**

1. Ton instance → onglet **Networking** → **Attach static IP** (ou **Create static IP**).
2. Donne-lui un nom (`ip-agent-emploi`) → **Create**.

Note cette adresse dans ton gestionnaire de mots de passe, entrée « VPS agent-emploi » : c'est **TON_IP** pour toute la suite.

À savoir : sur EC2, une IP publique coûte quelques euros par mois (environ 0,005 $ de l'heure), qu'elle soit fixe ou non. Sur Lightsail, l'IP fixe est gratuite tant qu'elle est attachée à une instance ; détachée, elle est facturée. Supprime-la si tu supprimes le serveur.

### 3. Ouvrir les ports 22, 80 et 443 dans le pare-feu AWS

**EC2 :**

1. Ton instance → onglet **Security** → clique le **Security group** (`sg-…`).
2. **Edit inbound rules**. Il faut exactement ces trois règles :

| Type | Port | Source |
|---|---|---|
| SSH | 22 | `0.0.0.0/0` (ou **My IP**, voir plus bas) |
| HTTP | 80 | `0.0.0.0/0` |
| HTTPS | 443 | `0.0.0.0/0` |

3. **Save rules**.

**Lightsail :**

1. Ton instance → onglet **Networking** → **IPv4 Firewall**.
2. SSH (22) et HTTP (80) y sont déjà. **Add rule** → **HTTPS** → **Create**.
3. Même chose dans **IPv6 Firewall** si la section existe.

**SSH ouvert à tout le monde, est-ce grave ?** Non, à condition d'avoir fait le chapitre 05 : connexion par clé uniquement et fail2ban. Choisir **My IP** est plus strict, mais l'IP de ta box change parfois, et tu serais alors bloqué dehors jusqu'à ce que tu corriges la règle. Commence avec `0.0.0.0/0`.

**Bonne nouvelle pour le chapitre 06 :** Docker contourne ufw, mais il ne peut pas contourner le Security Group, qui est en dehors du serveur. Chez AWS, tu as donc deux pare-feu l'un derrière l'autre.

### 4. Première connexion (remplace le chapitre 04, étapes 2 et 3)

À la création, AWS t'a fait choisir ou créer une **key pair**, et ton navigateur a téléchargé un fichier `.pem`. C'est ta clé privée.

1. Range-la dans ton dossier `.ssh` :

```bash
[PC] $ mkdir -p ~/.ssh
[PC] $ mv ~/Downloads/NOM-DE-TA-CLE.pem ~/.ssh/aws-agent.pem
```

(Sous Windows, le dossier s'appelle parfois `Téléchargements` dans l'explorateur, mais `Downloads` dans le terminal.)

2. Restreins ses droits, sinon SSH refuse de l'utiliser :

Sur Mac :

```bash
[PC] $ chmod 400 ~/.ssh/aws-agent.pem
```

Sous Windows (PowerShell), en une ligne :

```powershell
[PC] $ icacls $env:USERPROFILE\.ssh\aws-agent.pem /inheritance:r /grant:r "$($env:USERNAME):R"
```

Cette ligne retire tous les droits hérités, puis ne donne la lecture qu'à toi.

Sur **Lightsail**, si tu n'as pas choisi de clé, la clé par défaut se télécharge dans **Account** → **SSH keys** → la région de ton instance → **Download**.

3. Connecte-toi, avec l'utilisateur `ubuntu` :

```bash
[PC] $ ssh -i ~/.ssh/aws-agent.pem ubuntu@TON_IP
```

Réponds `yes` à la question sur l'empreinte, comme au chapitre 04. Le prompt devient `ubuntu@ip-172-31-…:~$`.

4. Ajoute aussi ta propre clé ed25519 (chapitre 04, étape 1), pour ne plus dépendre du fichier `.pem`. Sur ton PC, affiche-la et copie la ligne :

```bash
[PC] $ cat ~/.ssh/id_ed25519.pub
```

Puis, sur le serveur :

```bash
[VPS] $ nano ~/.ssh/authorized_keys
```

Va à la fin du fichier, colle ta ligne **sur une nouvelle ligne**, sans toucher à celle d'AWS, puis Ctrl + O, Entrée, Ctrl + X.

5. Donne un nom au serveur :

```bash
[VPS] $ sudo hostnamectl set-hostname agent-emploi
```

6. Mets ton raccourci dans `~/.ssh/config` (chapitre 04, étape 4), avec `ubuntu` pour l'instant :

```
Host agent
    HostName TON_IP
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
```

Teste `ssh agent` dans un **nouveau** terminal avant de fermer l'ancien.

### 5. Sécuriser (chapitre 05, avec deux différences)

Sur AWS, il n'y a pas de mot de passe root, et `ubuntu` peut utiliser `sudo` sans mot de passe. Pour suivre le chapitre 05, deviens root :

```bash
[VPS] $ sudo -i
```

Le prompt finit maintenant par `#`. Suis le chapitre 05 normalement, sauf :

1. **Copier la clé vers `patrick`** : la clé est chez `ubuntu`, pas chez root. Remplace la commande `rsync` par :

```bash
[VPS] # rsync --archive --chown=patrick:patrick /home/ubuntu/.ssh /home/patrick
```

2. **Pare-feu** : ouvre bien 22, 80 et 443 dans ufw **et** garde les règles AWS de l'étape 3. Les deux doivent être d'accord.

Garde le compte `ubuntu` tel quel : il ne sert plus au quotidien, mais c'est lui qu'utilisent les consoles de secours d'AWS (étape 7). Comme il n'a pas de mot de passe et que l'accès se fait par clé, il ne t'expose pas.

À la fin du chapitre 05, remplace `User ubuntu` par `User patrick` dans `~/.ssh/config`. Le swap de 2 Go (section 7 du chapitre 05) est **indispensable** sur une instance à 2 Go.

### 6. Le nom de domaine (chapitre 07)

Utilise l'IP fixe de l'étape 2. Avec sslip.io : `n8n.TON-IP-AVEC-DES-TIRETS.sslip.io`. Ne prends pas l'adresse en `…compute.amazonaws.com` affichée par AWS : elle change avec l'IP.

### 7. Ta roue de secours

Si un jour `ssh agent` ne marche plus :

- **EC2** : ton instance → **Connect** → onglet **EC2 Instance Connect** → **Username** `ubuntu` → **Connect**. Un terminal s'ouvre dans ton navigateur.
- **Lightsail** : ton instance → bouton **Connect using SSH**.

Les deux passent par le port 22 : ne supprime jamais la règle SSH du pare-feu AWS.

### 8. Surveiller la facture

AWS facture à l'usage. Une seule fois, pour dormir tranquille :

1. Console AWS → barre de recherche → **Budgets** → **Create budget**.
2. **Use a template** → **Monthly cost budget**.
3. Montant : par exemple `20` $, et ton adresse mail → **Create budget**.

Tu recevras un mail si tes dépenses du mois approchent ce montant. Ajoute « vérifier la facture AWS » à ta routine mensuelle (chapitre 19).

## Vérifie

- [ ] L'instance a au moins 2 Go de mémoire, et `df -h /` montre au moins 20 Go.
- [ ] Une IP fixe (Elastic IP ou Static IP) est attachée, et notée dans ton gestionnaire.
- [ ] Le pare-feu AWS autorise 22, 80 et 443, et rien d'autre.
- [ ] `ssh agent` te connecte avec ta clé ed25519.
- [ ] Un budget AWS est créé.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `WARNING: UNPROTECTED PRIVATE KEY FILE!` | Le fichier `.pem` est lisible par d'autres | Étape 4.2 (`chmod 400` ou `icacls`) |
| `Permission denied (publickey)` | Mauvais utilisateur (`root` au lieu de `ubuntu`), ou mauvaise clé | `ssh -i ~/.ssh/aws-agent.pem ubuntu@TON_IP` |
| `Connection timed out` | Port 22 fermé dans le Security Group, ou instance arrêtée | Étape 3 ; état de l'instance : **Running** |
| L'IP a changé après un redémarrage | Pas d'IP fixe | Étape 2, puis mets à jour `~/.ssh/config` et le DNS |
| HTTPS ne marche pas, Caddy n'obtient pas de certificat | Port 80 ou 443 fermé côté AWS | Étape 3 : les trois règles |
| n8n s'arrête tout seul, `Killed` dans les logs | Mémoire insuffisante | Swap (chapitre 05) ; ou passe à une instance plus grande : **Instance state** → **Stop**, **Actions** → **Instance settings** → **Change instance type**, **Start** |
| `No space left on device` | Disque de 8 Go | Étape 1 : agrandir le disque |

## Exercice : refais-le seul

Sans regarder cette annexe, dessine sur une feuille le chemin d'une visite vers `https://TON_DOMAINE` : Internet, IP fixe, pare-feu AWS, ufw, Caddy, n8n. Pour chaque étape, écris ce qui se passerait si elle était mal réglée, et la commande ou l'écran qui te permettrait de le voir.
