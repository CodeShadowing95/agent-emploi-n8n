# 04 · Clé SSH et première connexion

**Objectif :** te connecter au serveur depuis ton PC avec une clé, sans mot de passe, en tapant simplement `ssh agent`.

**Durée :** 45 minutes.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **SSH** (*Secure Shell*) | Le moyen de piloter un serveur à distance : tu tapes des commandes sur ton PC, elles s'exécutent sur le serveur. Tout le trafic est chiffré. |
| **Paire de clés SSH** | Deux fichiers liés mathématiquement. La **clé publique** se pose sur le serveur, comme une serrure. La **clé privée** reste sur ton PC, c'est la clé qui ouvre cette serrure. Ce que l'une ferme, seule l'autre peut l'ouvrir. |
| **Clé publique** | Fichier `id_ed25519.pub`. On peut la donner à n'importe qui sans risque : elle ne permet que de vérifier. |
| **Clé privée** | Fichier `id_ed25519`, sans extension. Elle ne quitte **jamais** ton PC, ne s'envoie à personne, ne se colle nulle part. |
| **Phrase de passe** (*passphrase*) | Un mot de passe qui protège ta clé privée. Si on te vole ton PC, la clé reste inutilisable sans elle. |
| **ed25519** | Le type de clé moderne recommandé : courte, rapide, très sûre. |
| **Empreinte** (*fingerprint*) | Une sorte de carte d'identité du serveur. À la première connexion, SSH te la montre pour que tu confirmes que c'est bien ton serveur. |
| **`authorized_keys`** | Le fichier du serveur qui liste les clés publiques autorisées à se connecter. |
| **Prompt** (invite) | Le texte affiché avant le curseur, par exemple `root@agent-emploi:~#`. Il te dit qui tu es et où tu es. |

## Pourquoi une clé plutôt qu'un mot de passe

Dès qu'un serveur est sur Internet, des robots essaient d'y entrer en testant des milliers de mots de passe par heure. Une clé ed25519 est impossible à deviner par ce moyen. Au chapitre 05, on interdira complètement les mots de passe : seule ta clé ouvrira la porte.

## Pas à pas

### 1. Créer ta paire de clés (sur ton PC)

```bash
[PC] $ ssh-keygen -t ed25519 -C "patrick@agent-emploi"
```

- `-t ed25519` : le type de clé ;
- `-C "…"` : un commentaire pour reconnaître la clé plus tard.

Le programme pose trois questions :

1. `Enter file in which to save the key` : appuie sur **Entrée** (emplacement par défaut).
2. `Enter passphrase` : choisis une phrase de passe et range-la dans ton gestionnaire. Rien ne s'affiche pendant que tu tapes : c'est normal.
3. `Enter same passphrase again` : retape-la.

Deux fichiers sont créés dans le dossier `.ssh` de ton dossier personnel. Affiche la clé **publique** :

```bash
[PC] $ cat ~/.ssh/id_ed25519.pub
```

Tu vois une ligne qui commence par `ssh-ed25519 AAAA…` et finit par ton commentaire. C'est elle, et seulement elle, qu'on copie sur le serveur.

### 2. Première connexion en root

> **Serveur AWS :** pas de root ni de mot de passe chez AWS. Fais l'étape 1 ci-dessus, puis suis l'[annexe E, étape 4](annexe-e-aws.md#4-première-connexion-remplace-le-chapitre-04-étapes-2-et-3) à la place des étapes 2 et 3.

```bash
[PC] $ ssh root@TON_IP
```

À la toute première connexion, SSH affiche :

```
The authenticity of host 'TON_IP' can't be established.
ED25519 key fingerprint is SHA256:xxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Tape `yes` puis Entrée. SSH mémorise l'empreinte du serveur ; s'il la voit changer un jour, il refusera de se connecter, ce qui te protège contre un imposteur.

Entre le mot de passe root reçu par mail (si tu as fourni ta clé à la commande, aucun mot de passe n'est demandé). Le prompt devient :

```
root@agent-emploi:~#
```

Tu es sur le serveur. Le `#` final signifie « je suis root ». Tape `exit` pour revenir sur ton PC.

### 3. Copier ta clé publique sur le serveur

Si tu as déjà donné ta clé à l'hébergeur lors de la commande, saute cette étape.

**Sur Mac :**

```bash
[PC] $ ssh-copy-id -i ~/.ssh/id_ed25519.pub root@TON_IP
```

**Sur Windows (PowerShell)**, qui n'a pas `ssh-copy-id`, en une seule ligne :

```powershell
[PC] $ type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh root@TON_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

**Sur Windows, dans l'Invite de commandes (cmd)**, reconnaissable à son invite `C:\Users\…>` : `$env:USERPROFILE` n'y existe pas (erreur « La syntaxe du nom de fichier, de répertoire ou de volume est incorrecte »). Écris `%USERPROFILE%` à la place :

```bat
[PC] > type %USERPROFILE%\.ssh\id_ed25519.pub | ssh root@TON_IP "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

Pour tout le reste de la formation, préfère PowerShell : touche Windows, tape « PowerShell », Entrée. Son invite commence par `PS C:\Users\…>`.

Ce que fait cette ligne : elle lit ta clé publique (`type`), l'envoie (`|`) au serveur, qui crée le dossier `.ssh`, ajoute la clé à la fin du fichier `authorized_keys`, et règle les permissions pour que personne d'autre ne puisse le modifier.

Teste : `ssh root@TON_IP` ne doit plus demander le mot de passe root, seulement ta phrase de passe de clé.

### 4. Créer un raccourci de connexion

Plutôt que de retaper l'IP à chaque fois, crée le fichier de configuration SSH. Ouvre-le dans VS Code :

```bash
[PC] $ code ~/.ssh/config
```

Colle ceci, enregistre :

```
Host agent
    HostName TON_IP
    User root
    IdentityFile ~/.ssh/id_ed25519
```

Désormais, `ssh agent` suffit. Au chapitre 05, on remplacera `User root` par `User patrick`.

## Vérifie

- [ ] `ssh agent` te connecte sans le mot de passe root.
- [ ] Le prompt affiche `root@agent-emploi`.
- [ ] Sur le serveur, `cat ~/.ssh/authorized_keys` affiche ta clé publique, identique à celle de ton PC.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `Connection timed out` | Mauvaise IP, ou serveur pas encore prêt | Vérifie l'IP dans l'espace client, attends quelques minutes |
| `Permission denied (publickey)` | Le serveur n'accepte que les clés, et la tienne n'y est pas | Ajoute ta clé publique via la console web de l'hébergeur, dans `/root/.ssh/authorized_keys` |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED` | Le serveur a été réinstallé, son empreinte a changé | Si tu l'as réinstallé toi-même : `ssh-keygen -R TON_IP`, puis reconnecte-toi. Sinon, ne te connecte pas et vérifie |
| Il redemande la phrase de passe à chaque fois | Normal | Optionnel : `ssh-add` (Mac) ou le service « OpenSSH Authentication Agent » (Windows) la retient pour la session |

## Exercice : refais-le seul

1. Explique à quelqu'un, avec l'image de la serrure et de la clé, pourquoi on peut donner sa clé publique mais jamais sa clé privée.
2. Crée une deuxième paire de clés nommée `essai` (`ssh-keygen -t ed25519 -f ~/.ssh/essai`), ajoute sa clé publique au serveur, connecte-toi avec `ssh -i ~/.ssh/essai root@TON_IP`, puis retire cette ligne de `authorized_keys` avec `nano`.
