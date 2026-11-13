# 02 · Préparer ton ordinateur

**Objectif :** avoir sur ton PC un terminal, Git, un éditeur de code, un gestionnaire de mots de passe, et une copie du dépôt.

**Durée :** 45 minutes.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Terminal** (ou console, invite de commandes) | Une fenêtre où l'on tape des commandes au lieu de cliquer. Sous Windows : PowerShell. Sous Mac : l'application Terminal. |
| **Commande** | Une instruction tapée dans le terminal, validée par la touche Entrée. Exemple : `git --version` demande à Git d'afficher sa version. |
| **Git** | Un logiciel qui enregistre l'historique de tes fichiers : qui a changé quoi, quand, et pourquoi. On peut revenir en arrière à tout moment. |
| **GitHub** | Un site qui héberge des dépôts Git en ligne, pour les sauvegarder, les partager et les montrer. |
| **Dépôt** (*repository*, « repo ») | Un dossier de projet suivi par Git, avec tout son historique. |
| **Cloner** | Télécharger une copie complète d'un dépôt GitHub sur ton ordinateur. |
| **Commit** | Une photo de l'état de tes fichiers à un instant, avec un message qui explique le changement. |
| **Gestionnaire de mots de passe** | Un coffre-fort chiffré pour tes mots de passe et secrets. Tu ne retiens qu'un seul mot de passe : celui du coffre. |
| **Secret** | Toute information qui donne un accès : mot de passe, clé d'API, jeton. Un secret ne s'écrit jamais dans le code ni dans un message. |

## Pourquoi ces outils

Tu vas manipuler une dizaine de secrets (mot de passe du serveur, clé de chiffrement de n8n, clé de l'API Claude, jeton Telegram…). Les perdre, c'est devoir tout refaire. Les laisser traîner dans un fichier texte, c'est risquer qu'on te les vole. D'où le gestionnaire de mots de passe **avant** tout le reste.

## Pas à pas

### 1. Ouvrir un terminal

- **Windows** : touche Windows, tape `PowerShell`, ouvre **Windows PowerShell**. Mieux : installe **Windows Terminal** depuis le Microsoft Store, qui gère plusieurs onglets.
- **Mac** : Cmd + Espace, tape `Terminal`, Entrée.

Tape cette commande et appuie sur Entrée :

```bash
[PC] $ echo "Bonjour"
```

Le terminal répond `Bonjour`. Tu viens de taper ta première commande.

### 2. Installer Git

- **Windows** : télécharge l'installeur sur [git-scm.com](https://git-scm.com/download/win), garde toutes les options par défaut.
- **Mac** : tape `git --version`. Si Git n'est pas installé, le Mac propose de l'installer : accepte.

Ferme et rouvre le terminal, puis vérifie :

```bash
[PC] $ git --version
```

Tu dois voir `git version 2.x.x`.

Puis présente-toi à Git (ces informations apparaîtront dans tes commits) :

```bash
[PC] $ git config --global user.name "Patrick Namegni"
[PC] $ git config --global user.email "ton-adresse-github@exemple.com"
```

### 3. Installer un éditeur de code

Installe **Visual Studio Code** ([code.visualstudio.com](https://code.visualstudio.com)). Il servira à lire et modifier les fichiers du dépôt, avec la coloration du YAML et du Markdown. Extensions utiles (onglet Extensions, à gauche) :

- **YAML** (Red Hat) : signale les erreurs dans `docker-compose.yml` ;
- **Remote - SSH** (Microsoft) : plus tard, pour ouvrir les fichiers du serveur directement dans VS Code.

### 4. Installer un gestionnaire de mots de passe

Installe **Bitwarden** (gratuit, sur [bitwarden.com](https://bitwarden.com)) ou utilise celui que tu as déjà. Crée tout de suite un dossier **« Agent emploi »**. Chaque fois que la formation te dit « garde ce secret », c'est là qu'il va.

Liste des secrets que tu vas y ranger au fil de la formation :

| Secret | Chapitre |
|---|---|
| Accès à l'espace client de l'hébergeur | 03 |
| Phrase de passe de ta clé SSH | 04 |
| Mot de passe de l'utilisateur `patrick` sur le serveur | 05 |
| `POSTGRES_PASSWORD` | 08 |
| `N8N_ENCRYPTION_KEY` (le plus important) | 08 |
| Mot de passe et codes de secours 2FA de n8n | 09 |
| Jeton du bot Telegram | 11 |
| Clé API Anthropic | 11 |
| Client ID et Client Secret Google | 11 |
| Jeton Apify, identifiants France Travail | 11 |

### 5. Cloner le dépôt

Choisis un dossier pour tes projets, puis :

```bash
[PC] $ cd ~
[PC] $ mkdir projets
[PC] $ cd projets
[PC] $ git clone https://github.com/CodeShadowing95/agent-emploi-n8n.git
[PC] $ cd agent-emploi-n8n
[PC] $ code .
```

Explication ligne par ligne :

- `cd ~` : va dans ton dossier personnel (`~` est un raccourci qui veut dire « mon dossier utilisateur ») ;
- `mkdir projets` : crée (*make directory*) un dossier `projets` ;
- `cd projets` : entre dedans (*change directory*) ;
- `git clone …` : télécharge le dépôt dans un nouveau dossier `agent-emploi-n8n` ;
- `code .` : ouvre le dossier courant (`.` veut dire « ici ») dans VS Code.

## Vérifie

- [ ] `git --version` affiche une version.
- [ ] VS Code s'ouvre sur le dossier `agent-emploi-n8n`, et tu vois `docker-compose.yml`, `FORMATION.md` et le dossier `formation`.
- [ ] Ton gestionnaire de mots de passe contient un dossier « Agent emploi ».

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `git n'est pas reconnu en tant que commande` | Le terminal a été ouvert avant l'installation | Ferme et rouvre le terminal |
| `code n'est pas reconnu` (Mac) | VS Code n'a pas installé sa commande | Dans VS Code : Cmd + Maj + P, tape `Shell Command: Install 'code' command in PATH` |
| `Permission denied` au clone | Mauvaise adresse ou dépôt privé | Vérifie l'adresse : le dépôt est public, aucun mot de passe n'est nécessaire |

## Exercice : refais-le seul

1. Dans ton dossier `projets`, crée un dossier `essai`, entre dedans, puis reviens dans `projets` avec `cd ..` (`..` veut dire « le dossier parent »).
2. Supprime le dossier `agent-emploi-n8n` et clone-le à nouveau, de mémoire.
