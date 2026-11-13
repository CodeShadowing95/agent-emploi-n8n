# 17 · Agent Veille offres

**Objectif :** chaque jour ouvré à 7 h, l'agent récupère les offres des dernières 24 heures sur LinkedIn (via Apify) et France Travail, retire les doublons et celles déjà connues, les fait noter sur 100 par Claude, ajoute les bonnes au suivi et t'envoie le top 5 sur Telegram.

**Durée :** 2 heures.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Scraper** | Un programme qui lit des pages web pour en extraire des données. Apify en héberge des milliers, appelés *actors*. |
| **Actor Apify** | Un scraper prêt à l'emploi sur Apify. On utilise `valig/linkedin-jobs-scraper`, déjà testé pour ce projet. |
| **Requête HTTP** | Un message envoyé à une adresse web : une **méthode** (`GET` pour lire, `POST` pour envoyer des données), une **adresse**, des **en-têtes** (dont l'authentification) et parfois un **corps** en JSON. |
| **Paramètres de requête** (*query parameters*) | Les filtres ajoutés à une adresse après `?`, par exemple `?motsCles=java&distance=30`. |
| **Normaliser** | Mettre des données de sources différentes au même format, avec les mêmes noms de champs. |
| **Dédoublonner** | Retirer les éléments présents plusieurs fois. |
| **Code commune INSEE** | Le numéro officiel d'une commune française. Strasbourg : `67482`. France Travail l'utilise pour la localisation. |
| **Grille de notation** | Les critères et leurs points, pour que la note soit cohérente d'une offre à l'autre. |

## Le canevas

| Case | Contenu |
|---|---|
| 1. Objectif | Ne rater aucune bonne offre, sans passer une heure par jour à chercher |
| 2. Déclencheur | Schedule `0 7 * * 1-5` |
| 3. Entrées | Apify (LinkedIn, 24 h, Strasbourg) ; France Travail (24 h, 30 km autour de Strasbourg) ; le suivi |
| 4. Règles | Retirer doublons et offres déjà au suivi ; 40 offres notées au maximum ; garder les notes de 70 et plus |
| 5. Jugement IA | Note sur 100, raison, écart honnête (Claude Haiku, température 0) |
| 6. Format | `{score: entier, raison, ecart}` |
| 7. Actions | Ajouter au suivi (`afaire`) ; Telegram top 5 |
| 8. Validation humaine | Aucune action extérieure ; c'est toi qui décides ensuite de postuler |
| 9. Garde-fous | Plafond de 40 offres notées par jour (coût) ; plafond de 50 résultats Apify (coût) |
| 10. Mesure | Nombre d'offres trouvées, notées, retenues ; coût Apify et Anthropic par semaine |

## Le schéma

```
Schedule ─┬► Apify LinkedIn (HTTP POST) ─────► Normaliser LinkedIn (Code) ─┐
 7 h      │                                                              ├► Merge ─► Lire le suivi ─► Nouvelles offres (Code) ─► Noter (Claude) ─► ≥ 70 ? ─► Ajouter au suivi ─► Top 5 (Code) ─► Telegram
          └► France Travail (HTTP GET) ──────► Normaliser France Travail ──┘                            (dédoublonner, max 40)
```

## Pas à pas, nœud par nœud

Crée un workflow `04 Veille offres`.

### Nœud 1 · Schedule Trigger

**Custom (Cron)** : `0 7 * * 1-5`. Relie-le aux **deux** nœuds suivants : le flux se sépare en deux branches qui s'exécutent l'une après l'autre.

### Nœud 2 · Apify LinkedIn (HTTP Request)

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

Ce que fait cet appel : il lance l'actor, attend qu'il finisse, et renvoie directement ses résultats (`run-sync-get-dataset-items`). `r86400` = publiées dans les dernières 86 400 secondes, soit 24 heures. Chaque offre devient un item avec `title`, `companyName`, `location`, `url`, `description`, `postedDate`…

### Nœud 3 · Normaliser LinkedIn (Code)

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

### Nœud 4 · France Travail (HTTP Request)

- **Method** : `GET`
- **URL** : `https://api.francetravail.io/partenaire/offresdemploi/v2/offres/search`
- **Authentication** : `Generic Credential Type` → `OAuth2 API` → ton identifiant `France Travail`
- **Send Query Parameters** : activé

| Name | Value |
|---|---|
| `motsCles` | `développeur` |
| `commune` | `67482` |
| `distance` | `30` |
| `publieeDepuis` | `1` |
| `range` | `0-49` |

La réponse est **un seul** item avec une liste `resultats`. Ajoute juste après un nœud **Split Out**, champ `resultats`, pour obtenir un item par offre.

### Nœud 5 · Normaliser France Travail (Code)

```javascript
return $input.all().map(({ json: o }) => ({
  json: {
    source: 'France Travail',
    titre: o.intitule || '',
    entreprise: o.entreprise?.nom || '',
    lieu: o.lieuTravail?.libelle || '',
    contrat: o.typeContratLibelle || o.typeContrat || '',
    lien: o.origineOffre?.urlOrigine || `https://candidat.francetravail.fr/offres/recherche/detail/${o.id}`,
    description: (o.description || '').slice(0, 3000),
  },
}));
```

Les deux sources ont maintenant **les mêmes champs** : c'est tout l'intérêt de la normalisation.

### Nœud 6 · Merge

**Mode** : `Append`. Branche Normaliser LinkedIn sur l'entrée 1 et Normaliser France Travail sur l'entrée 2.

### Nœud 7 · Lire le suivi (Google Sheets)

`Get Row(s)`, sans filtre, **Execute Once** activé.

### Nœud 8 · Nouvelles offres (Code)

```javascript
const suivi = $input.all().map(i => i.json);
const offres = $('Merge').all().map(i => i.json);

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
  if (!o.entreprise || !o.lien) continue;              // offre incomplète
  if (liensConnus.has(o.lien) || cles.has(cle)) continue; // déjà au suivi
  if (entreprisesEcartees.has(simplifier(o.entreprise))) continue; // refus déjà reçu
  if (vues.has(cle)) continue;                           // doublon entre sources
  vues.add(cle);
  nouvelles.push({ json: o });
}

return nouvelles.slice(0, 40); // garde-fou de coût
```

`simplifier` met en minuscules et retire accents, espaces et ponctuation, pour que « Développeur Full-Stack » et « developpeur full stack » soient reconnus comme identiques.

### Nœud 9 · Noter (Basic LLM Chain)

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

- **System Message** : celui de [`prompts/noter-offre.md`](../prompts/noter-offre.md)
- **Require Specific Output Format** + **Structured Output Parser** :

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

### Nœud 10 · ≥ 70 ? (Filter)

`{{ $json.output.score }}` **Number → is greater than or equal to** `70`.

### Nœud 11 · Ajouter au suivi (Google Sheets)

`Append Row` :

- `entreprise` = `{{ $('Nouvelles offres').item.json.entreprise }}`
- `ville` = `{{ $('Nouvelles offres').item.json.lieu }}`
- `poste` = `{{ $('Nouvelles offres').item.json.titre }}`
- `canal` = `offre` ; `statut` = `afaire`
- `lien` = `{{ $('Nouvelles offres').item.json.lien }}`
- `score` = `{{ $json.output.score }}`
- `notes` = `{{ $json.output.raison }} Écart : {{ $json.output.ecart }}`
- `majLe` = `{{ $now.toFormat('yyyy-MM-dd') }}`

### Nœud 12 · Top 5 (Code)

Mode **Run Once for All Items**. Il reçoit les lignes que le nœud précédent vient d'ajouter au suivi : elles contiennent déjà `poste`, `entreprise`, `score`, `notes` et `lien`.

```javascript
const retenues = $input.all().map(i => i.json);

retenues.sort((a, b) => Number(b.score) - Number(a.score));
const top = retenues.slice(0, 5);

const lignes = top.map((o, n) => `${n + 1}. ${o.score}/100 · ${o.poste} · ${o.entreprise}\n${o.notes}\n${o.lien}`);

return [{ json: { texte: `Veille du jour : ${retenues.length} offre(s) retenue(s).\n\n${lignes.join('\n\n')}` } }];
```

Les jours où aucune offre ne dépasse 70, le Filter ne laisse rien passer : les nœuds suivants ne s'exécutent pas et tu ne reçois pas de message. Pas de message = pas de bonne offre ce jour-là.

### Nœud 13 · Telegram

**Text** : `{{ $json.texte }}`. Désactive l'attribution, et dans **Additional Fields** → **Disable Web Page Preview** : activé, pour éviter cinq aperçus de liens.

## Tester

1. Épingle la sortie des deux appels (Apify et France Travail) après un premier essai réussi : tu ne repaieras pas Apify à chaque test.
2. Exécute le reste du workflow, regarde le nombre d'items à chaque étape.
3. Relance immédiatement : les mêmes offres doivent maintenant être filtrées par **Nouvelles offres** (elles sont dans le suivi).
4. Désépingle, **Publish**.

## Vérifie

- [ ] Les deux sources produisent des items au même format.
- [ ] Une offre déjà au suivi n'est jamais renotée.
- [ ] Les offres retenues apparaissent dans le suivi avec score, lien et raison.
- [ ] Le message Telegram arrive les matins où au moins une offre est retenue.
- [ ] Après une semaine : coût Apify (console Apify) et coût Anthropic (console Anthropic) notés dans ton journal.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| Apify : délai dépassé | Le scraper met plus de 5 minutes | Augmente le **Timeout**, ou baisse `limit` |
| Apify : `401` | Jeton faux, ou `Bearer` oublié | La valeur de l'en-tête est `Bearer <jeton>` |
| France Travail : `401` / `invalid_client` | Identifiants ou scope | Recontrôle l'identifiant OAuth2 (chapitre 11) |
| France Travail : `204 No Content` | Aucune offre publiée depuis 24 h | Normal certains jours ; teste avec `publieeDepuis` = `7` |
| Toutes les notes sont basses | Prompt trop sévère, ou mots-clés trop larges | Ajuste la grille, ou affine `keywords` et `motsCles` |

## Exercice : refais-le seul

Ajoute une troisième recherche Apify (mots-clés `développeur java`) en parallèle des deux autres, avec son nœud de normalisation, et branche-la sur un Merge à trois entrées. Puis fais passer le seuil de 70 à 75 et compare le nombre d'offres retenues sur une semaine.
