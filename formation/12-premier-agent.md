# 12 · Ton premier agent

**Objectif :** un agent complet, publié, qui t'envoie chaque matin sur Telegram un message rédigé par Claude, puis exporté et versionné dans Git.

**Durée :** 1 heure.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Prompt** | La consigne écrite que tu donnes à Claude. Sa qualité fait la qualité de la réponse. |
| **Message système** | La partie du prompt qui fixe le rôle et les règles permanentes de Claude (« Tu es un assistant de recherche d'emploi… »). |
| **Message utilisateur** | La partie du prompt qui contient la demande et les données du moment. |
| **Chaîne** (*chain*) | Dans n8n, un nœud qui envoie un prompt à un modèle et récupère sa réponse. La **Basic LLM Chain** fait un aller-retour simple. |
| **Sous-nœud** | Un nœud branché **sous** un autre pour lui fournir une capacité : le modèle (Anthropic Chat Model), le format de sortie (Structured Output Parser)… |
| **LLM** (*Large Language Model*) | Grand modèle de langage : une IA entraînée sur du texte, comme Claude. |
| **Expression cron** | Une façon d'écrire un horaire répétitif en 5 champs : minute, heure, jour du mois, mois, jour de la semaine. `0 8 * * 1-5` = 8 h 00, du lundi au vendredi. |
| **Clé de déploiement** (*deploy key*) | Une clé SSH qui donne accès à **un seul** dépôt GitHub. On la pose sur le serveur pour qu'il puisse pousser dans le dépôt, sans lui confier ton compte entier. |

## Pourquoi un agent si simple

Il contient déjà les quatre briques de tous les agents à venir : un **déclencheur**, un **appel à Claude**, une **action**, et la **publication**. Le reste, c'est la même chose avec plus d'étapes.

## Pas à pas

### 1. Créer le workflow

*n8n* : **Create workflow**, nomme-le `00 Bonjour du matin`.

### 2. Le déclencheur

Ajoute **Schedule Trigger** :

- **Trigger Interval** : `Custom (Cron)`
- **Expression** : `0 8 * * 1-5`

Lis-la ainsi : à la minute `0`, de l'heure `8`, tous les jours du mois (`*`), tous les mois (`*`), du lundi (`1`) au vendredi (`5`).

Le fuseau est Europe/Paris grâce à `GENERIC_TIMEZONE` (chapitre 08). Vérifie-le aussi dans **Workflow settings** (menu ⋯ en haut à droite) → **Timezone**.

### 3. L'appel à Claude

Ajoute après le déclencheur un nœud **Basic LLM Chain**.

- **Source for Prompt (User Message)** : `Define below`
- **Prompt (User Message)** :

```
Nous sommes le {{ $now.setLocale('fr').toFormat('cccc d LLLL yyyy') }}.
Écris un message d'encouragement de deux phrases, en français, pour Patrick,
développeur full stack qui cherche un CDI à Strasbourg. Ton chaleureux mais pas
mielleux, et propose une action concrète pour la journée. Pas d'emoji.
```

- Dans **Options** → **Add Option** → **System Message** :

```
Tu es le coach de recherche d'emploi de Patrick. Tu es bref, concret et honnête.
```

Sous le nœud, un connecteur **Model** apparaît : clique dessus, choisis **Anthropic Chat Model**, sélectionne ton identifiant Anthropic, puis le modèle **Claude Haiku** le plus récent.

Clique sur **Execute step** sur la chaîne. À droite, la sortie contient un champ **`text`** : c'est la réponse de Claude.

### 4. L'action : Telegram

Ajoute un nœud **Telegram** → **Send a text message** :

- **Credential** : `Telegram Agent Emploi`
- **Chat ID** : ton chat_id (chapitre 11)
- **Text** : passe en mode **Expression** et écris `{{ $json.text }}`
- **Additional Fields** → **Append n8n Attribution** : désactivé (sinon n8n ajoute une mention à chaque message)

### 5. Tester

Clique sur **Execute workflow**. Le message arrive sur ton téléphone en quelques secondes.

Ouvre l'onglet **Executions** et clique sur l'exécution : regarde ce qu'il y a dans chaque nœud. Dans la chaîne, tu peux même voir combien de tokens Claude a lus et écrits.

### 6. Publier

Clique sur **Publish**, donne un nom à la version (par exemple `v1`) → **Publish**. Ton agent tournera demain à 8 h, sans toi.

Pour le tester sans attendre demain : modifie temporairement l'expression cron en `*/2 * * * *` (toutes les 2 minutes), publie, attends un message, puis remets `0 8 * * 1-5` et republie.

### 7. Exporter et versionner

Le travail fait dans n8n vit dans la base de données. Pour le garder dans Git, on l'exporte.

**Une seule fois : donner au serveur le droit de pousser dans le dépôt.**

```bash
[VPS] $ ssh-keygen -t ed25519 -C "vps-agent-emploi" -f ~/.ssh/github_deploy -N ""
[VPS] $ cat ~/.ssh/github_deploy.pub
```

Sur GitHub : ton dépôt → **Settings** → **Deploy keys** → **Add deploy key** → titre `VPS agent-emploi`, colle la clé, coche **Allow write access** → **Add key**.

Puis, sur le serveur :

```bash
[VPS] $ cat >> ~/.ssh/config <<'EOF'
Host github.com
    IdentityFile ~/.ssh/github_deploy
EOF
[VPS] $ cd ~/agent-emploi-n8n
[VPS] $ git remote set-url origin git@github.com:CodeShadowing95/agent-emploi-n8n.git
[VPS] $ git config user.name "Patrick Namegni"
[VPS] $ git config user.email "ton-adresse-github@exemple.com"
[VPS] $ ssh -T git@github.com
```

La dernière commande répond `Hi CodeShadowing95/agent-emploi-n8n! You've successfully authenticated`. Réponds `yes` si elle demande de confirmer l'empreinte de GitHub.

**À chaque fois : exporter, committer, pousser.**

```bash
[VPS] $ sudo apt install -y jq          # une seule fois
[VPS] $ ./scripts/export-workflows.sh
[VPS] $ git checkout -b agent-00-bonjour
[VPS] $ git add workflows/
[VPS] $ git commit -m "feat: agent bonjour du matin"
[VPS] $ git push -u origin agent-00-bonjour
```

GitHub affiche un lien pour ouvrir une *pull request* : ouvre-la, vérifie que la CI passe au vert, puis fusionne-la (chapitre 21 pour le détail). Enfin, sur le serveur : `git checkout main && git pull`.

## Vérifie

- [ ] Le message de Claude arrive sur Telegram quand tu exécutes le workflow.
- [ ] Le workflow est publié, et le message arrive seul à l'heure prévue.
- [ ] `workflows/00-bonjour-du-matin.json` est dans le dépôt, sur GitHub.
- [ ] Ce fichier ne contient ni ton jeton Telegram ni ta clé Anthropic (ouvre-le et cherche).

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| La chaîne n'a pas de connecteur Model rempli | Le sous-nœud n'est pas branché | Clique sur le **+** sous **Model** |
| Telegram : `chat not found` | Mauvais chat_id, ou tu n'as jamais écrit au bot | Écris au bot, puis refais `getUpdates` |
| Le message arrive en anglais | Prompt trop vague | Ajoute « Réponds en français » dans le message système |
| Le workflow ne part pas à 8 h | Non publié, ou mauvais fuseau | Vérifie **Publish** et **Workflow settings** → **Timezone** |
| `git push` : `Permission denied (publickey)` | La clé de déploiement n'a pas le droit d'écriture | Coche **Allow write access** sur GitHub |

## Exercice : refais-le seul

Crée de mémoire un second agent `00 Citation du soir` : chaque jour à 20 h, Claude envoie une phrase qui résume une bonne pratique de recherche d'emploi. Utilise Claude Sonnet cette fois, compare la qualité, puis exporte et commite.
