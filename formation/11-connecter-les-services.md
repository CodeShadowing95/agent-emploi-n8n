# 11 · Connecter les services

**Objectif :** créer dans n8n un identifiant fonctionnel pour chaque service : Telegram, Claude, Gmail, Google Sheets, Apify et France Travail.

**Durée :** 2 heures, dont la moitié pour Google. Fais une pause entre deux services.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Identifiant** (*credential*) | Dans n8n, une connexion enregistrée à un service (clé, jeton…). Tu la crées une fois, puis tous tes nœuds peuvent l'utiliser. Elle est chiffrée avec ta `N8N_ENCRYPTION_KEY`. |
| **Clé d'API** | Un long mot de passe qu'un service te donne pour que tes programmes l'utilisent. Elle se garde secrète comme un mot de passe. |
| **Jeton** (*token*) | Même idée qu'une clé d'API, souvent à durée limitée. |
| **Bot Telegram** | Un compte Telegram piloté par un programme. Le tien enverra les messages de tes agents. |
| **chat_id** | Le numéro de la conversation Telegram entre toi et ton bot. n8n en a besoin pour savoir à qui écrire. |
| **OAuth2** | Une façon de donner à une application un accès limité à ton compte (Gmail, Sheets) **sans lui donner ton mot de passe**. Google te montre une page « Autoriser n8n à lire tes mails ? » ; si tu acceptes, il remet un jeton à n8n. Tu peux le révoquer à tout moment. |
| **Écran de consentement** | La page Google qui te demande d'autoriser l'accès. Tu dois la configurer toi-même dans la console Google Cloud. |
| **URL de redirection** (*redirect URI*) | L'adresse de n8n où Google renvoie le jeton après ton accord. Elle doit être déclarée à l'identique chez Google. |
| **Client ID / Client Secret** | L'identifiant et le mot de passe de **ton application** chez Google (ou France Travail), pas de ton compte. |
| **Client credentials** | Une variante d'OAuth2 sans fenêtre de connexion : l'application s'identifie seule avec son Client ID et son Secret. France Travail l'utilise. |
| **Scope** (portée) | La liste des droits demandés, par exemple « lire les offres ». |
| **Token** (pour un modèle d'IA) | À ne pas confondre avec un jeton d'accès : c'est aussi l'unité de mesure du texte pour Claude, environ trois quarts de mot. L'API Claude est facturée au nombre de tokens lus et écrits. |
| **Modèle** | Une version de Claude. **Haiku** : rapide et économique. **Sonnet** : meilleur en rédaction. **Opus** : le plus puissant, le plus cher. |

## Pourquoi passer par les identifiants de n8n

Tes clés ne sont écrites ni dans les workflows, ni dans le dépôt, ni dans `.env`. Elles vivent chiffrées dans la base de n8n. Quand tu exportes un workflow, il contient seulement le **nom** de l'identifiant, jamais sa valeur : c'est ce qui rend le dépôt publiable.

---

## 1. Telegram

### Créer le bot

1. Dans Telegram, cherche **@BotFather** (avec le badge bleu de vérification) et ouvre la conversation.
2. Envoie `/newbot`.
3. Nom affiché : `Agent Emploi Patrick`.
4. Identifiant : il doit finir par `bot`, par exemple `agent_emploi_patrick_bot`.
5. BotFather répond avec un **jeton** de la forme `123456789:AAH…`. Range-le dans ton gestionnaire. Quiconque a ce jeton contrôle ton bot.

### Trouver ton chat_id

1. Ouvre la conversation avec ton nouveau bot et envoie-lui `bonjour`.
2. Dans ton navigateur, ouvre (en remplaçant `<JETON>` par ton jeton) :
   `https://api.telegram.org/bot<JETON>/getUpdates`
3. Dans la réponse, repère `"chat":{"id":123456789` : ce nombre est ton **chat_id**. Note-le.

Si la réponse est vide (`"result":[]`), renvoie un message au bot et recharge la page.

### Créer l'identifiant dans n8n

*n8n* : **Overview** → onglet **Credentials** → **Create credential** → cherche **Telegram API** → colle le jeton dans **Access Token** → **Save**. Le message « Connection tested successfully » doit apparaître. Renomme l'identifiant `Telegram Agent Emploi` (clic sur son nom en haut).

---

## 2. Claude (Anthropic)

1. Va sur [console.anthropic.com](https://console.anthropic.com), crée un compte, ajoute un moyen de paiement et un petit crédit (5 € suffisent pour des semaines de tests).
2. **Fixe une limite de dépense mensuelle** dans les réglages de facturation (*Limits*). C'est ton garde-fou : si un workflow tourne en boucle, la facture s'arrête là.
3. **API Keys** → **Create Key** → nom `n8n-agent-emploi` → copie la clé (elle commence par `sk-ant-`). Elle ne sera plus jamais affichée : range-la tout de suite.
4. *n8n* : **Create credential** → **Anthropic API** → colle la clé → **Save**.

Quel modèle pour quoi :

| Tâche | Modèle | Pourquoi |
|---|---|---|
| Classer un mail, noter une offre | **Claude Haiku** | Tâche courte et répétée : rapide et économique |
| Rédiger une relance, une lettre | **Claude Sonnet** | Qualité d'écriture nettement supérieure |

Dans le nœud **Anthropic Chat Model**, la liste des modèles est chargée depuis ton compte : choisis le Haiku et le Sonnet les plus récents.

---

## 3. Google : Gmail et Google Sheets

C'est la partie la plus longue. Suis les étapes dans l'ordre, sans en sauter.

### 3.1 Créer un projet Google Cloud

1. Va sur [console.cloud.google.com](https://console.cloud.google.com) avec **ton adresse Gmail de candidature** (le compte depuis lequel tu postules).
2. En haut, menu des projets → **Nouveau projet** → nom `agent-emploi` → **Créer**. Vérifie que ce projet est bien sélectionné en haut de la page.

### 3.2 Activer les API

Menu ☰ → **APIs & Services** → **Library**. Cherche et clique **Enable** sur chacune :

- **Gmail API**
- **Google Sheets API**
- **Google Drive API** (n8n s'en sert pour lister tes fichiers Sheets)

### 3.3 Configurer l'écran de consentement

**APIs & Services** → **OAuth consent screen** → **Get started**.

1. **App name** : `Agent emploi n8n` ; **User support email** : ton adresse. **Next**.
2. **Audience** : **External**. **Next**.
3. **Contact information** : ton adresse. **Next**.
4. Accepte la politique, **Continue**, **Create**.
5. Menu de gauche **Branding** → **Authorized domains** → **Add domain** → ton domaine racine (`patrick-namegni.fr`, ou `sslip.io` si tu utilises sslip). **Save**.
6. Menu **Audience** → **Test users** → **Add users** → ton adresse Gmail de candidature → **Save**.

### 3.4 Créer le client OAuth

1. Dans n8n, ouvre un nouvel identifiant **Gmail OAuth2 API**. Copie l'**OAuth Redirect URL** affichée. Elle ressemble à `https://n8n.patrick-namegni.fr/rest/oauth2-credential/callback`. Laisse cet onglet ouvert.
2. Dans Google : **APIs & Services** → **Credentials** → **+ Create credentials** → **OAuth client ID**.
3. **Application type** : **Web application**. **Name** : `n8n`.
4. **Authorized redirect URIs** → **Add URI** → colle l'URL copiée depuis n8n, **à l'identique**.
5. **Create**. Google affiche le **Client ID** et le **Client Secret** : range-les dans ton gestionnaire.

### 3.5 Connecter Gmail et Sheets dans n8n

1. Dans l'identifiant **Gmail OAuth2 API** resté ouvert, colle le Client ID et le Client Secret → **Sign in with Google**.
2. Choisis ton adresse Gmail de candidature. Google affiche « Google n'a pas validé cette application » : c'est normal, c'est **ta** application. Clique sur **Continuer**.
3. Coche toutes les autorisations demandées → **Continuer**. n8n affiche « Account connected ».
4. Recommence avec un identifiant **Google Sheets OAuth2 API**, avec le **même** Client ID et Secret.

### 3.6 Éviter la déconnexion tous les 7 jours

En mode **Testing**, Google invalide la connexion au bout de 7 jours. Pour l'éviter : **Audience** → **Publish app** → **Confirm**. Ton application passe « In production » sans vérification Google : c'est permis pour un usage personnel. Si une connexion a déjà expiré, rouvre l'identifiant dans n8n et refais **Sign in with Google**.

---

## 4. Le tracker Google Sheets

1. Sur [sheets.google.com](https://sheets.google.com), crée une feuille vide nommée `Suivi candidatures`.
2. **Fichier** → **Importer** → **Importer** → choisis `sheets/tracker-modele.csv` du dépôt → **Remplacer la feuille actuelle**.
3. La ligne 1 contient maintenant les colonnes. Nomme l'onglet `candidatures`.
4. Copie l'adresse de la feuille : l'identifiant du document est la longue suite entre `/d/` et `/edit`. Les nœuds Google Sheets de n8n te laisseront aussi la choisir dans une liste.

À quoi sert chaque colonne :

| Colonne | Contenu |
|---|---|
| `entreprise`, `ville`, `pays` | Qui et où |
| `contact`, `email` | La personne et l'adresse à qui tu as écrit |
| `poste`, `canal`, `lien` | Le poste visé, le canal (`spontanee`, `offre`, `cabinet`) et le lien de l'offre |
| `score` | La note sur 100 donnée par l'agent de veille |
| `statut` | `afaire`, `pret`, `envoye`, `relance`, `entretien`, `refus`, `sansreponse` |
| `dateEnvoi`, `relance1`, `relance2` | Les dates, au format `AAAA-MM-JJ` |
| `threadId` | L'identifiant du fil Gmail, pour retrouver la conversation |
| `objet`, `corps` | L'objet et le texte du mail de candidature préparé, avant envoi (chapitre 16) |
| `cv` | Le nom du PDF à joindre, par exemple `CV_Patrick_NAMEGNI_java.pdf` |
| `notes`, `majLe` | Le résumé de l'agent et la date de dernière mise à jour |

Je migrerai tes candidatures existantes dans cette feuille dès que tu l'auras créée.

---

## 5. Apify (offres LinkedIn)

1. Sur [console.apify.com](https://console.apify.com) : **Settings** → **API & Integrations** → copie ton **Personal API token**.
2. *n8n* : **Create credential** → **Header Auth** → nom `Apify` :
   - **Name** : `Authorization`
   - **Value** : `Bearer <ton jeton>` (le mot `Bearer`, un espace, puis le jeton)

On l'utilisera avec un nœud **HTTP Request**. C'est volontaire : tu apprends à appeler n'importe quelle API, même sans nœud dédié.

---

## 6. France Travail (offres agrégées)

1. Crée un compte sur [francetravail.io](https://francetravail.io), espace **Développeur**.
2. **Mes applications** → **Créer une application** → nom `agent-emploi`.
3. Abonne l'application à l'API **Offres d'emploi**.
4. Note le **Client ID** et le **Client Secret** affichés.
5. *n8n* : **Create credential** → **OAuth2 API** :

| Champ | Valeur |
|---|---|
| Grant Type | **Client Credentials** |
| Access Token URL | `https://entreprise.francetravail.fr/connexion/oauth2/access_token?realm=%2Fpartenaire` |
| Client ID / Client Secret | ceux de ton application |
| Scope | `api_offresdemploiv2 o2dsoffre` |
| Authentication | **Send Credentials in Body** |

Nomme l'identifiant `France Travail`. n8n demandera et renouvellera le jeton tout seul.

Si France Travail affiche d'autres valeurs (scope, adresse) dans la documentation de ton application, ce sont elles qui font foi.

## Vérifie

- [ ] Dans **Credentials**, six identifiants : Telegram, Anthropic, Gmail OAuth2, Google Sheets OAuth2, Apify (Header Auth), France Travail (OAuth2).
- [ ] Telegram, Anthropic, Gmail et Sheets affichent un test de connexion réussi.
- [ ] L'application Google est « In production ».
- [ ] Ta feuille `Suivi candidatures` existe, avec les colonnes en ligne 1.
- [ ] Ta limite de dépense Anthropic est fixée.
- [ ] Tous les secrets sont dans ton gestionnaire, et nulle part ailleurs.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| Google : `redirect_uri_mismatch` | L'URL déclarée chez Google n'est pas exactement celle de n8n | Recopie-la depuis n8n, sans espace ni `/` en trop |
| Google : `access_denied` | Ton adresse n'est pas dans les utilisateurs de test, ou ce n'est pas le bon compte | Ajoute-la dans **Audience** → **Test users** |
| Gmail fonctionnait, puis `invalid_grant` une semaine plus tard | Application restée en mode Testing | Publie l'application (3.6) et reconnecte l'identifiant |
| Telegram : `Unauthorized` | Jeton mal copié | Recopie-le depuis BotFather (`/mybots` → ton bot → **API Token**) |
| Anthropic : `credit balance is too low` | Pas de crédit | Ajoute du crédit dans la console |
| France Travail : `invalid_scope` | L'application n'est pas abonnée à l'API Offres d'emploi | Vérifie l'abonnement dans ton espace francetravail.io |

## Exercice : refais-le seul

1. Supprime l'identifiant Telegram dans n8n et recrée-le de mémoire.
2. Explique, avec tes mots, pourquoi l'OAuth2 est plus sûr que de donner ton mot de passe Gmail à n8n.
3. Révoque l'accès de n8n depuis [myaccount.google.com/permissions](https://myaccount.google.com/permissions), constate que l'identifiant Gmail ne fonctionne plus, puis reconnecte-le.
