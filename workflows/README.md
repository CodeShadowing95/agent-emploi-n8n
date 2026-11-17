# Les agents, prêts à importer

Ce dossier contient les six workflows de la formation, déjà construits nœud par nœud comme dans les chapitres 14 à 19. Tu n'as qu'à les importer, brancher tes connexions et les publier.

| Fichier | Agent | Quand il tourne | Chapitre |
|---|---|---|---|
| `01-boite-de-reception.json` | Classe les réponses des recruteurs et met à jour le suivi | Toutes les 5 minutes | 14 |
| `02-relances.json` | Propose les relances J+7 et J+14, envoie après ton accord | Jours ouvrés, 9 h | 15 |
| `03-envoi-valide.json` | Envoie les candidatures « pret » avec le CV, après ton accord | Mardi au jeudi, 8 h 30 | 16 |
| `04-veille-offres.json` | Cherche les offres LinkedIn (et France Travail quand l'accès est accordé), les note, garde les ≥ 70 | Jours ouvrés, 7 h | 17 |
| `05-rapport-du-vendredi.json` | Bilan chiffré de la semaine | Vendredi, 17 h | 18 |
| `99-alerte-erreurs.json` | Te prévient sur Telegram si un agent échoue | Quand un agent échoue | 19 |

**Rien ne part sans toi :** les agents 02 et 03 attendent ton clic sur **Envoyer** dans Telegram avant d'envoyer un mail. Sans réponse, rien n'est envoyé.

## Avant d'importer

1. Avoir fait le **chapitre 11** : identifiants Telegram, Anthropic, Google (Sheets et Gmail), Apify (Header Auth) créés dans n8n. France Travail (OAuth2) seulement quand l'accès à l'API t'a été accordé (chapitre 11, section 6).
2. Avoir la feuille **Suivi candidatures**, avec un onglet nommé exactement `candidatures` et les colonnes de [`sheets/tracker-modele.csv`](../sheets/tracker-modele.csv).
3. Avoir créé dans Gmail l'étiquette `agent-traite`.

## Étape 1 · Remplacer trois repères dans les fichiers

Les fichiers contiennent trois repères à remplacer par tes vraies valeurs. Ouvre le dossier `workflows/` dans VS Code, puis **Ctrl + Maj + H** (rechercher et remplacer dans tous les fichiers) :

| Repère | Remplace par | Où le trouver |
|---|---|---|
| `TON_ID_DE_FEUILLE` | L'identifiant de ta feuille | Dans l'adresse de la feuille : `docs.google.com/spreadsheets/d/`**`CET_IDENTIFIANT`**`/edit` |
| `TON_CHAT_ID` | Ton chat_id Telegram | Chapitre 11 |
| `TON_TELEPHONE` | Ton numéro, pour la signature des relances | (dans `02-relances.json` seulement) |

**Ne commite pas ces fichiers modifiés** : le dépôt est public. Après l'import, annule tes modifications avec `git restore workflows/`.

## Étape 2 · Importer dans n8n

Pour chaque fichier, en commençant par `99-alerte-erreurs.json` :

1. Dans n8n : **Create workflow** (ou bouton **+**), puis menu **⋯** en haut à droite → **Import from File**.
2. Choisis le fichier. Le workflow apparaît sur le canevas.
3. **Enregistre** (Ctrl + S).

## Étape 3 · Brancher tes connexions

Les nœuds qui ont besoin d'un identifiant affichent un **triangle rouge**. Ouvre chacun et choisis ton identifiant dans **Credential to connect with** :

| Nœuds | Identifiant |
|---|---|
| Google Sheets (Lire le suivi, Mettre à jour…, Ajouter…) | Google Sheets |
| Gmail Trigger, Envoyer, Étiqueter le mail | Gmail |
| Telegram, Validation | Telegram |
| Claude (…) | Anthropic |
| Apify LinkedIn | Header Auth `Apify` |
| France Travail (désactivé, voir plus bas) | OAuth2 `France Travail` |

Deux réglages restent à choisir à la main :

- **01 · Étiqueter le mail** : dans **Label Names or IDs**, choisis `agent-traite`.
- **03 · Lire le CV** : rien à changer, mais tes PDF doivent être dans le dossier `fichiers/` du serveur, et la colonne `cv` du suivi doit contenir leur nom exact (par exemple `CV_Patrick_NAMEGNI.pdf`).

Les modèles Claude sont réglés sur Haiku 5.5 (classer, noter) et Sonnet 5.5 (rédiger). Si un nœud Claude affiche une erreur de modèle, ouvre-le et choisis le modèle Haiku ou Sonnet le plus récent dans la liste.

## Étape 4 · Tester, puis publier

Teste chaque agent avec la section **Tester** de son chapitre (lignes `TEST` dans le suivi, ton adresse personnelle comme destinataire). Puis :

1. Menu **⋯** → **Settings** → **Error workflow** → `99 Alerte erreurs` → **Save**.
2. **Publish**.

Ordre conseillé : 99, puis 05 (le plus simple), 01, 04, 02, 03.

## Écarts avec les chapitres

Les fichiers suivent les chapitres, avec quatre petites différences :

- **04 · France Travail désactivé** : l'API Offres d'emploi est accessible sur demande depuis 2026 (chapitre 11, section 6). Le nœud est livré désactivé, et l'agent tourne avec LinkedIn seul. Quand l'accès est accordé : ouvre le nœud, choisis l'identifiant `France Travail`, réactive-le (touche **D**), puis **Publish**.
- **04 · France Travail** : pas de nœud Split Out. Le nœud **Normaliser France Travail** déplie lui-même la liste `resultats`, ce qui évite une erreur les jours sans offre.
- **04 · Normaliser** : les deux nœuds ont **Always Output Data** activé, pour que le Merge continue même si une source ne renvoie rien.
- **Telegram** : les boutons s'ouvrent dans ton navigateur (réglage par défaut). L'option **Approve Within Chat** du chapitre 15 reste désactivée : tu peux l'activer dans le nœud **Validation** si tu préfères répondre sans quitter Telegram.

## Après une modification

Quand tu modifies un agent dans n8n, exporte-le avec `./scripts/export-workflows.sh` (chapitre 12). Le script exporte **tous** les workflows et remplace tes valeurs personnelles par les repères listés dans `masques.local` (à créer une fois depuis `masques.local.example`). Vérifie avec `git diff` qu'aucune valeur personnelle (identifiant de feuille, chat_id, téléphone) n'y figure avant de commiter.
