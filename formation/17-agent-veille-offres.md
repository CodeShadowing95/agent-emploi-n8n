# 17 · Agent Veille offres

**Objectif :** être prévenu vite des nouvelles offres, sur **tous** les job boards où tu as un compte. Deux sources alimentent le même agent :

- **les alertes mail** des job boards (HelloWork, Indeed, Apec, Welcome to the Jungle, France Travail, Free-Work, LesJeudis…), lues toutes les 15 minutes ;
- **LinkedIn** via Apify, chaque jour ouvré à 7 h.

L'agent retire les doublons et les offres déjà connues, les fait noter sur 100 par Claude, ajoute les bonnes au suivi et t'envoie les meilleures sur Telegram.

**Durée :** 2 h 30.

> **Et l'API France Travail ?** Elle n'est plus en libre accès, et la demande peut être refusée (chapitre 11, section 6). Ce chapitre s'en passe : France Travail envoie lui aussi des alertes mail, que l'agent lit comme les autres.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Alerte mail** | Une recherche enregistrée sur un job board : le site t'envoie par mail les nouvelles offres qui y correspondent. |
| **Libellé Gmail** | Une étiquette posée sur un mail, comme un dossier. Un mail peut en avoir plusieurs. |
| **Filtre Gmail** | Une règle appliquée par Gmail à chaque mail qui arrive : « si l'expéditeur est X, alors pose le libellé Y et sors-le de la boîte de réception ». |
| **Extraire** | Sortir des informations précises d'un texte libre. Ici, Claude transforme un mail d'alerte en liste d'offres (titre, entreprise, lieu, lien). |
| **Scraper** | Un programme qui lit des pages web pour en extraire des données. Apify en héberge des milliers, appelés *actors*. |
| **Actor Apify** | Un scraper prêt à l'emploi sur Apify. On utilise `valig/linkedin-jobs-scraper`, déjà testé pour ce projet. |
| **Requête HTTP** | Un message envoyé à une adresse web : une **méthode** (`GET` pour lire, `POST` pour envoyer des données), une **adresse**, des **en-têtes** (dont l'authentification) et parfois un **corps** en JSON. |
| **Normaliser** | Mettre des données de sources différentes au même format, avec les mêmes noms de champs. |
| **Dédoublonner** | Retirer les éléments présents plusieurs fois. |
| **Grille de notation** | Les critères et leurs points, pour que la note soit cohérente d'une offre à l'autre. |

## Le canevas

| Case | Contenu |
|---|---|
| 1. Objectif | Ne rater aucune bonne offre et la voir dans l'heure, sans passer une heure par jour à chercher |
| 2. Déclencheurs | Gmail toutes les 15 minutes (libellé `alertes-emploi`) ; Schedule `0 7 * * 1-5` pour LinkedIn |
| 3. Entrées | Les mails d'alerte des job boards ; Apify (LinkedIn, 24 h) ; le suivi |
| 4. Règles | Retirer doublons et offres déjà au suivi ; 40 offres notées au maximum par passage ; garder les notes de 70 et plus |
| 5. Jugement IA | Extraire les offres d'un mail ; noter chaque offre sur 100 avec une raison et un écart honnête (Claude Haiku, température 0) |
| 6. Format | Extraction : `{offres: [{titre, entreprise, lieu, contrat, lien, extrait}]}` ; note : `{score, raison, ecart}` |
| 7. Actions | Ajouter au suivi (`afaire`) ; Telegram avec les 5 meilleures |
| 8. Validation humaine | Aucune action extérieure ; c'est toi qui décides ensuite de postuler |
| 9. Garde-fous | Un lien absent du mail est retiré (Claude ne peut pas en inventer) ; plafond de 40 offres notées ; plafond de 50 résultats Apify |
| 10. Mesure | Offres trouvées, notées, retenues, par site ; coût Apify et Anthropic par semaine |

## Le schéma

```
Branche A, LinkedIn
Schedule 7 h ─► Apify LinkedIn ─► Normaliser LinkedIn ──────────────────────────────┐
                                                                                    ├► Lire le suivi ─► Nouvelles offres ─► Noter ─► ≥ 70 ? ─► Ajouter au suivi ─► Top 5 ─► Telegram
Branche B, alertes mail                                                             │   (une fois)      (dédoublonner, 40)  (Claude)
Gmail 15 min ─► Préparer le mail ─► Extraire les offres (Claude) ─► Normaliser alertes ┘
```

Un workflow peut avoir **plusieurs déclencheurs**. Chacun lance sa branche à son propre rythme ; les deux branches se rejoignent sur **Lire le suivi**, et la suite est commune. À chaque exécution, une seule branche tourne.

## Préparation

### 1. Créer les alertes sur chaque job board

Sur chaque site où tu as un compte, fais ta recherche habituelle (par exemple « développeur full stack », ou « développeur Java », avec ta zone), puis clique sur le bouton de type **Créer une alerte**, **Recevoir ces offres par e-mail** ou **Enregistrer la recherche**. Choisis la fréquence **la plus courte** que le site propose (immédiate ou quotidienne).

Commence par trois ou quatre sites (par exemple HelloWork, Indeed, Apec, France Travail). Tu en ajouteras d'autres plus tard sans toucher au workflow : un site de plus = une alerte de plus et un filtre Gmail de plus.

LinkedIn est déjà couvert par Apify (branche A). Tu peux quand même créer une alerte LinkedIn : les doublons sont retirés.

### 2. Ranger les alertes avec un filtre Gmail

Quand la première alerte d'un site arrive :

1. Ouvre le mail dans Gmail.
2. Menu **⋮** (en haut à droite du mail) → **Filtrer les messages similaires**. Le champ **De** est déjà rempli avec l'adresse du site.
3. **Créer un filtre**, puis coche :
   - **Ignorer la boîte de réception (archiver)** ;
   - **Appliquer le libellé** → **Nouveau libellé** → `alertes-emploi` (le même pour tous les sites) ;
   - **Appliquer également le filtre aux conversations correspondantes**, pour ranger les alertes déjà reçues.
4. Recommence pour chaque site.

Pourquoi archiver ? L'agent du chapitre 14 lit ta boîte de réception pour repérer les réponses des entreprises. Les alertes n'ont rien à y faire : archivées, elles ne passent que par cet agent.

## Pas à pas, nœud par nœud

Crée un workflow `04 Veille offres`.

### Branche A · LinkedIn

#### Nœud 1 · Schedule Trigger

Renomme-le `Chaque jour ouvré à 7 h`. **Custom (Cron)** : `0 7 * * 1-5`.

#### Nœud 2 · Apify LinkedIn (HTTP Request)

- **Method** : `POST`
- **URL** : `https://api.apify.com/v2/acts/valig~linkedin-jobs-scraper/run-sync-get-dataset-items`
- **Authentication** : `Generic Credential Type` → `Header Auth` → ton identifiant `Apify`
- **Send Body** : activé ; **Body Content Type** : `JSON` ; **Specify Body** : `Using JSON` :

```json
{
  "keywords": "développeur full stack",
  "location": "Strasbourg",
  "datePosted": "r86400",
  "limit": 50
}
```

- **Options** → **Timeout** : `300000` (5 minutes : le scraper prend du temps)

Ce que fait cet appel : il lance l'actor, attend qu'il finisse, et renvoie directement ses résultats (`run-sync-get-dataset-items`). `r86400` = publiées dans les dernières 86 400 secondes, soit 24 heures. Chaque offre devient un item avec `title`, `companyName`, `location`, `url`, `description`…

#### Nœud 3 · Normaliser LinkedIn (Code)

```javascript
return $input.all().map(({ json: o }) => ({
  json: {
    source: 'LinkedIn',
    titre: o.title || '',
    entreprise: o.companyName || '',
    lieu: o.location || '',
    contrat: o.contractType || '',
    lien: o.url || '',
    description: (o.description || '').slice(0, 3000),
  },
}));
```

Relie-le à **Lire le suivi** (nœud 8), que tu crées plus bas.

### Branche B · Alertes mail

#### Nœud 4 · Alertes job boards (Gmail Trigger)

Ajoute un **second déclencheur** sur le même canevas : bouton **+** → **Gmail** → **On message received**.

- **Credential** : ton identifiant Gmail
- **Poll Times** : **Every X** → `15` **Minutes**
- **Simplify** : désactivé (on a besoin du HTML du mail, qui contient les liens)
- **Filters** → **Search** : `label:alertes-emploi`

À chaque passage, il renvoie les mails arrivés depuis le passage précédent sous ce libellé : un item par mail.

#### Nœud 5 · Préparer le mail (Code)

Un mail d'alerte est du HTML plein de mise en page. Ce nœud le transforme en texte simple, **en gardant l'adresse de chaque lien entre parenthèses**, et reconnaît le site à l'adresse de l'expéditeur.

```javascript
// Le site qui envoie l'alerte, reconnu à l'adresse de l'expéditeur
const sources = {
  hellowork: 'HelloWork', indeed: 'Indeed', apec: 'Apec', welcometothejungle: 'Welcome to the Jungle',
  francetravail: 'France Travail', 'free-work': 'Free-Work', lesjeudis: 'LesJeudis', linkedin: 'LinkedIn',
  monster: 'Monster', jobteaser: 'JobTeaser', meteojob: 'Meteojob', cadremploi: 'Cadremploi',
  humeet: 'Humeet', jobgether: 'Jobgether',
};

return $input.all().map(({ json: mail }) => {
  const expediteur = (mail.from?.value?.[0]?.address || '').toLowerCase();
  const cle = Object.keys(sources).find(nom => expediteur.includes(nom));

  // Le HTML devient du texte lisible ; chaque lien garde son adresse entre parenthèses
  let contenu = mail.html
    ? String(mail.html)
        .replace(/<(style|script|head)[\s\S]*?<\/\1>/gi, ' ')
        .replace(/<a\s[^>]*?href="([^"]+)"[^>]*>([\s\S]*?)<\/a>/gi, ' $2 ($1) ')
        .replace(/<br\s*\/?>|<\/(p|div|tr|li|h\d|table)>/gi, '\n')
        .replace(/<[^>]+>/g, ' ')
        .replace(/&nbsp;/g, ' ').replace(/&#39;|&apos;/g, "'").replace(/&quot;/g, '"').replace(/&amp;/g, '&')
    : String(mail.text || '');
  contenu = contenu.replace(/[ \t]+/g, ' ').replace(/\s*\n\s*/g, '\n').trim().slice(0, 40000);

  return {
    json: {
      source: cle ? sources[cle] : (expediteur.split('@')[1] || 'Alerte mail'),
      objet: mail.subject || '',
      contenu,
    },
  };
});
```

Lis les `.replace` dans l'ordre : on retire les blocs de style, on remplace chaque lien `<a href="adresse">texte</a>` par `texte (adresse)`, on change les fins de lignes et de cellules en retours à la ligne, on retire les autres balises, puis on remet les caractères spéciaux (`&amp;` redevient `&`). Un site absent de la liste `sources` fonctionne quand même : son nom de domaine sert de source.

Exemple de sortie :

```
Développeur Full Stack H/F (https://www.hellowork.com/fr-fr/emplois/123.html?utm_source=alerte)
ACME - Strasbourg - CDI
Se désinscrire (https://…)
```

#### Nœud 6 · Extraire les offres (Basic LLM Chain)

- **Prompt (User Message)**, en mode Expression :

```
<mail>
Source : {{ $json.source }}
Objet : {{ $json.objet }}

{{ $json.contenu }}
</mail>
```

- **System Message** : celui de [`prompts/extraire-alerte.md`](../prompts/extraire-alerte.md)
- **Require Specific Output Format** : activé. Branche un **Structured Output Parser** → **Schema Type** : `Define using JSON Schema` (pas l'exemple par défaut, voir chapitre 15) :

```json
{
  "type": "object",
  "properties": {
    "offres": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "titre": { "type": "string" },
          "entreprise": { "type": "string" },
          "lieu": { "type": "string" },
          "contrat": { "type": "string" },
          "lien": { "type": "string" },
          "extrait": { "type": "string" }
        },
        "required": ["titre", "entreprise", "lien"]
      }
    }
  },
  "required": ["offres"]
}
```

- **Model** : Claude Haiku, température `0`. Renomme le nœud modèle `Claude (Extraire)` et le parser `Format (Extraire)`.

`"type": "array"` veut dire « une liste ». Un mail d'alerte contient souvent 5 à 20 offres : Claude renvoie un seul item par mail, avec la liste dans `output.offres`.

#### Nœud 7 · Normaliser alertes (Code)

Mode **Run Once for All Items**. Il déplie la liste : une offre = un item, avec les mêmes champs que LinkedIn.

```javascript
const resultat = [];

$input.all().forEach((item, i) => {
  // Le mail d'où viennent ces offres (même position que la sortie de Claude)
  const mail = $('Préparer le mail').itemMatching(i).json;

  for (const o of item.json.output?.offres || []) {
    const lien = String(o.lien || '').trim();
    resultat.push({
      json: {
        source: mail.source,
        titre: o.titre || '',
        entreprise: o.entreprise || '',
        lieu: o.lieu || '',
        contrat: o.contrat || '',
        // Garde-fou : un lien absent du mail a été inventé, on le retire
        lien: lien && mail.contenu.includes(lien) ? lien : '',
        description: (o.extrait || '').slice(0, 3000),
      },
    });
  }
});

return resultat;
```

Le garde-fou du lien est important : un modèle peut fabriquer une adresse qui a l'air vraie. Ici, on vérifie que l'adresse se trouve **telle quelle** dans le mail. Sinon, le lien est vidé, et le nœud suivant écarte l'offre.

`itemMatching(i)` retrouve l'item du nœud `Préparer le mail` qui correspond à l'item `i` de l'entrée : on récupère ainsi la source et le contenu du bon mail.

Relie ce nœud à **Lire le suivi**, comme Normaliser LinkedIn.

### Partie commune

#### Nœud 8 · Lire le suivi (Google Sheets)

`Get Row(s)`, sans filtre, **Settings** → **Execute Once** activé (le suivi n'est lu qu'une fois, même s'il arrive 30 offres).

#### Nœud 9 · Nouvelles offres (Code)

```javascript
const suivi = $input.all().map(i => i.json);

// Les offres de la branche qui vient de tourner : LinkedIn (7 h) ou alertes mail (toutes les 15 min)
const offres = ['Normaliser LinkedIn', 'Normaliser alertes']
  .filter(nom => $(nom).isExecuted)
  .flatMap(nom => $(nom).all().map(i => i.json));

const simplifier = t => (t || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/[^a-z0-9]/g, '');

const liensConnus = new Set(suivi.map(l => l.lien).filter(Boolean));
const cles = new Set(suivi.map(l => simplifier(l.entreprise) + '|' + simplifier(l.poste)));
const entreprisesEcartees = new Set(
  suivi.filter(l => ['refus', 'ecartee'].includes(l.statut)).map(l => simplifier(l.entreprise))
);

const vues = new Set();
const nouvelles = [];

for (const o of offres) {
  const cle = simplifier(o.entreprise) + '|' + simplifier(o.titre);
  if (!o.entreprise || !o.titre || !o.lien) continue;   // offre incomplète
  if (liensConnus.has(o.lien) || cles.has(cle)) continue; // déjà au suivi
  if (entreprisesEcartees.has(simplifier(o.entreprise))) continue; // refus déjà reçu
  if (vues.has(cle)) continue;                           // doublon entre sites
  vues.add(cle);
  nouvelles.push({ json: o });
}

return nouvelles.slice(0, 40); // garde-fou de coût
```

`$(nom).isExecuted` vaut `true` si ce nœud a tourné pendant cette exécution. Comme une seule branche tourne à la fois, on prend les offres de celle-là.

`simplifier` met en minuscules et retire accents, espaces et ponctuation, pour que « Développeur Full-Stack » et « developpeur full stack » soient reconnus comme identiques. La même offre reçue par HelloWork et par Indeed a deux liens différents, mais la même clé entreprise + titre : elle n'est gardée qu'une fois.

#### Nœud 10 · Noter (Basic LLM Chain)

- **Prompt (User Message)** :

```
<offre>
Titre : {{ $json.titre }}
Entreprise : {{ $json.entreprise }}
Lieu : {{ $json.lieu }}
Contrat : {{ $json.contrat }}
Source : {{ $json.source }}
Description :
{{ $json.description }}
</offre>
```

- **System Message** : celui de [`prompts/noter-offre.md`](../prompts/noter-offre.md). Il précise qu'une offre venue d'une alerte, souvent sans longue description, n'est pas pénalisée pour autant.
- **Require Specific Output Format** + **Structured Output Parser** → **Schema Type** : `Define using JSON Schema` :

```json
{
  "type": "object",
  "properties": {
    "score": { "type": "integer", "minimum": 0, "maximum": 100 },
    "raison": { "type": "string" },
    "ecart": { "type": "string" }
  },
  "required": ["score", "raison", "ecart"]
}
```

- **Model** : Claude Haiku, température `0`.

#### Nœud 11 · ≥ 70 ? (Filter)

`{{ $json.output.score }}` **Number → is greater than or equal to** `70`.

#### Nœud 12 · Ajouter au suivi (Google Sheets)

`Append Row` :

- `entreprise` = `{{ $('Nouvelles offres').item.json.entreprise }}`
- `ville` = `{{ $('Nouvelles offres').item.json.lieu }}`
- `poste` = `{{ $('Nouvelles offres').item.json.titre }}`
- `canal` = `offre` ; `statut` = `afaire`
- `lien` = `{{ $('Nouvelles offres').item.json.lien }}`
- `score` = `{{ $json.output.score }}`
- `notes` = `Source : {{ $('Nouvelles offres').item.json.source }}. {{ $json.output.raison }} Écart : {{ $json.output.ecart }}`
- `majLe` = `{{ $now.toFormat('yyyy-MM-dd') }}`

La source dans les notes te dira, au bout de quelques semaines, quels sites t'apportent vraiment de bonnes offres.

#### Nœud 13 · Top 5 (Code)

Mode **Run Once for All Items**. Il reçoit les lignes que le nœud précédent vient d'ajouter au suivi.

```javascript
const retenues = $input.all().map(i => i.json);
const html = texte => String(texte || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

retenues.sort((a, b) => Number(b.score) - Number(a.score));
const top = retenues.slice(0, 5);

const lignes = top.map(o =>
  `<b>${o.score}/100</b> · ${html(o.poste)} · <b>${html(o.entreprise)}</b>\n` +
  `<i>${html(o.notes)}</i>\n` +
  `<a href="${html(o.lien)}">Voir l'offre</a>`
);

return [{ json: { texte: `🔎 <b>Veille offres</b> : ${retenues.length} nouvelle(s) offre(s) retenue(s)\n\n${lignes.join('\n\n')}` } }];
```

`html()` protège les caractères `&`, `<` et `>`, que Telegram prendrait sinon pour des balises (chapitre 14). Les passages où aucune offre ne dépasse 70 ne t'envoient rien : pas de message = pas de bonne offre.

#### Nœud 14 · Telegram

- **Text** : `{{ $json.texte }}`
- **Additional Fields** : **Parse Mode** → `HTML` ; **Append n8n Attribution** désactivé ; **Disable Web Page Preview** activé (pour éviter cinq aperçus de liens).

## Tester

1. **Branche B d'abord**, gratuite. Vérifie qu'au moins un mail porte le libellé `alertes-emploi` dans Gmail. Sur le nœud **Alertes job boards**, clique **Fetch Test Event** : n8n récupère un mail.
2. Exécute **Préparer le mail** : le contenu doit montrer les titres d'offres suivis de leurs adresses entre parenthèses.
3. Exécute **Extraire les offres** : compte les offres dans `output.offres` et compare avec le mail. Ouvre deux ou trois liens : ils doivent mener aux bonnes offres.
4. Exécute la suite jusqu'à Telegram. Relance aussitôt : les mêmes offres doivent être filtrées par **Nouvelles offres** (elles sont maintenant au suivi).
5. **Branche A** : exécute **Apify LinkedIn** une fois, puis **épingle** sa sortie (icône punaise) pour ne pas repayer Apify à chaque essai. Exécute la suite.
6. Désépingle, **Publish**.

## Vérifie

- [ ] Les alertes de chaque site arrivent sous le libellé `alertes-emploi` et plus dans ta boîte de réception.
- [ ] Les deux branches produisent des offres au même format.
- [ ] Aucun lien inventé : chaque lien du suivi ouvre la bonne offre.
- [ ] Une offre déjà au suivi, ou reçue par deux sites, n'est notée qu'une fois.
- [ ] Les offres retenues apparaissent dans le suivi avec score, lien, source et raison.
- [ ] Après une semaine : coût Apify et coût Anthropic notés dans ton journal, et quels sites ont donné les meilleures offres.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| Alertes job boards ne renvoie rien | Aucun mail sous le libellé, ou libellé mal écrit | Dans Gmail, cherche `label:alertes-emploi` : la recherche doit montrer tes alertes |
| Les alertes arrivent encore dans la boîte de réception | Filtre sans **Ignorer la boîte de réception** | Gmail → Paramètres → **Filtres et adresses bloquées** → modifie le filtre |
| `output.offres` est vide alors que le mail contient des offres | Mail sans HTML, ou contenu coupé | Regarde la sortie de Préparer le mail ; si les offres sont au-delà de 40 000 caractères, augmente la limite du `.slice` |
| Toutes les offres d'un site sont écartées | Liens vidés par le garde-fou (Claude a modifié l'adresse) | Compare `output.offres[0].lien` avec le contenu : le lien doit y figurer tel quel |
| Sortie en `output.properties…` | Schema Type resté sur l'exemple | **Define using JSON Schema** (chapitre 15) |
| Apify : délai dépassé | Le scraper met plus de 5 minutes | Augmente le **Timeout**, ou baisse `limit` |
| Apify : `401` | Jeton faux, ou `Bearer` oublié | La valeur de l'en-tête est `Bearer <jeton>` |
| Toutes les notes sont basses | Prompt trop sévère, ou mots-clés trop larges | Ajuste la grille, ou affine tes alertes et `keywords` |

## Exercice : refais-le seul

Ajoute un nouveau site à ta veille sans toucher au workflow : crée l'alerte, puis le filtre Gmail. Vérifie le lendemain que ses offres arrivent dans le suivi avec la bonne source. Si la source affichée est un nom de domaine, ajoute le site à la liste `sources` de **Préparer le mail**.

Ensuite, fais passer le seuil de 70 à 75 et compare le nombre d'offres retenues sur une semaine.
