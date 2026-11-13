# 15 · Agent Relances

**Objectif :** chaque jour ouvré à 9 h, l'agent repère les candidatures sans réponse depuis 7 jours, fait rédiger une relance par Claude, te la montre sur Telegram avec deux boutons, et ne l'envoie que si tu cliques sur « Envoyer ».

**Durée :** 2 heures.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Send and Wait for Response** | Une opération des nœuds Telegram et Gmail : envoyer un message, puis **mettre le workflow en pause** jusqu'à ta réponse. C'est l'humain dans la boucle. |
| **Approval** (approbation) | Le type de réponse le plus simple : un bouton « Approuver » et, si tu veux, un bouton « Refuser ». |
| **Exécution en attente** (*waiting*) | Une exécution en pause, qui reprendra quand tu répondras. Tu la vois dans **Executions** avec le statut *Waiting*. |
| **Luxon / `DateTime`** | La bibliothèque de dates disponible dans les nœuds Code et les expressions de n8n. `DateTime.now()` = maintenant. |
| **Température** | Un réglage du modèle : à 0, ses réponses sont stables et prévisibles ; vers 1, plus variées. Pour classer : 0. Pour rédiger : environ 0,7. |

## Le canevas

| Case | Contenu |
|---|---|
| 1. Objectif | Relancer au bon moment, avec un texte personnalisé, sans y penser |
| 2. Déclencheur | Schedule, `0 9 * * 1-5` |
| 3. Entrées | Les lignes du suivi |
| 4. Règles | Statut `envoye` ou `relance` ; email connu ; J+7 sans relance 1 → relance 1 ; 7 jours après la relance 1 sans relance 2 → relance 2 ; 7 jours après la relance 2 → `sansreponse` ; 10 relances par jour au maximum |
| 5. Jugement IA | Rédiger la relance (Claude Sonnet, température 0,7) |
| 6. Format | `{objet, corps}` |
| 7. Actions | Envoyer le mail ; mettre à jour `relance1` ou `relance2` et le statut |
| 8. Validation humaine | **Oui** : chaque relance passe par Telegram, boutons « Envoyer » / « Ne pas relancer » |
| 9. Garde-fous | Plafond de 10 ; pause limitée à 2 jours ; aucun envoi sans clic |
| 10. Test | Une ligne de test avec ton adresse personnelle et une date d'envoi il y a 8 jours |

## Le schéma

```
Schedule ─► Lire le suivi ─► À relancer ? (Code) ─► IF abandon ─┬► (true)  Passer en « sansreponse » ─► Telegram info
 9 h                                                             │
                                                                 └► (false) Rédiger (Claude) ─► Validation Telegram ─► IF approuvé ─┬► Envoyer (Gmail) ─► Noter la relance
                                                                                                (en pause jusqu'au clic)            └► Noter « sansreponse »
```

## Pas à pas, nœud par nœud

Crée un workflow `02 Relances`.

### Nœud 1 · Schedule Trigger

**Custom (Cron)** : `0 9 * * 1-5`.

### Nœud 2 · Lire le suivi (Google Sheets)

`Get Row(s)` sur `Suivi candidatures` / `candidatures`, sans filtre.

### Nœud 3 · À relancer ? (Code)

Mode **Run Once for All Items** :

```javascript
const aujourdhui = DateTime.now().setZone('Europe/Paris').startOf('day');

// Nombre de jours écoulés depuis une date AAAA-MM-JJ (null si la date est vide)
const joursDepuis = date => {
  if (!date) return null;
  const d = DateTime.fromISO(String(date), { zone: 'Europe/Paris' });
  return d.isValid ? Math.floor(aujourdhui.diff(d, 'days').days) : null;
};

const aRelancer = [];

for (const { json: ligne } of $input.all()) {
  if (!['envoye', 'relance'].includes(ligne.statut)) continue;
  if (!ligne.email) continue;

  let etape = null;
  if (!ligne.relance1 && joursDepuis(ligne.dateEnvoi) >= 7) etape = 'relance1';
  else if (ligne.relance1 && !ligne.relance2 && joursDepuis(ligne.relance1) >= 7) etape = 'relance2';
  else if (ligne.relance2 && joursDepuis(ligne.relance2) >= 7) etape = 'abandon';

  if (etape) {
    aRelancer.push({ json: { ...ligne, etape, joursDepuisEnvoi: joursDepuis(ligne.dateEnvoi) } });
  }
}

// Garde-fou : 10 au maximum par jour
return aRelancer.slice(0, 10);
```

En clair : on garde les candidatures envoyées dont la dernière action a au moins 7 jours, et on note à quelle étape elles en sont.

### Nœud 4 · IF abandon

Condition : `{{ $json.etape }}` **String → is equal to** `abandon`.

**Branche true** → **Google Sheets** `Update Row`, colonne de correspondance `entreprise`, `statut` = `sansreponse`, `majLe` = `{{ $now.toFormat('yyyy-MM-dd') }}` → **Telegram** : `Sans réponse : {{ $('À relancer ?').item.json.entreprise }}, classée après deux relances.`

### Nœud 5 · Rédiger (Basic LLM Chain), sur la branche false

- **Prompt (User Message)** :

```
<candidature>
Entreprise : {{ $json.entreprise }}
Poste : {{ $json.poste || 'candidature spontanée' }}
Contact : {{ $json.contact || 'non connu' }}
Envoyée il y a {{ $json.joursDepuisEnvoi }} jours
Étape : {{ $json.etape === 'relance1' ? 'première relance' : 'seconde et dernière relance' }}
Notes : {{ $json.notes }}
</candidature>
```

- **System Message** : celui de [`prompts/rediger-relance.md`](../prompts/rediger-relance.md).
- **Require Specific Output Format** : activé, avec un **Structured Output Parser** :

```json
{
  "type": "object",
  "properties": {
    "objet": { "type": "string" },
    "corps": { "type": "string" }
  },
  "required": ["objet", "corps"]
}
```

- **Model** : **Anthropic Chat Model** → Claude **Sonnet**, **Sampling Temperature** `0.7`.

### Nœud 6 · Validation (Telegram, Send and Wait for Response)

- **Resource** : `Message` ; **Operation** : `Send and Wait for Response`
- **Chat ID** : ton chat_id
- **Message** :

```
Relance proposée ({{ $('À relancer ?').item.json.etape }}) pour {{ $('À relancer ?').item.json.entreprise }}
À : {{ $('À relancer ?').item.json.email }}
Objet : {{ $json.output.objet }}

{{ $json.output.corps }}
```

- **Response Type** : `Approval`
- **Approval Options** : **Type of Approval** = `Approve and Disapprove` ; **Approve Button Label** = `Envoyer` ; **Disapprove Button Label** = `Ne pas relancer`
- **Limit Wait Time** : activé, `2` jours. Sans réponse dans ce délai, le workflow reprend comme un refus.
- **Advanced Interactivity** → **Approve Within Chat** : activé, pour répondre d'un simple tap dans Telegram.

Quand ce nœud s'exécute, le workflow se met en pause. Tu reçois le message avec deux boutons. Ton clic le réveille.

Regarde la sortie de ce nœud dans une exécution terminée : la réponse s'y trouve sous la forme `approved: true` ou `false` (dans un objet `data`). Utilise le chemin exact que tu vois pour le nœud suivant.

### Nœud 7 · IF approuvé

Condition : `{{ $json.data.approved }}` **Boolean → is true**. Adapte le chemin si la sortie de ton nœud 6 est différente.

**Branche true → Envoyer (Gmail)**

- **Resource** : `Message` ; **Operation** : `Send`
- **To** : `{{ $('À relancer ?').item.json.email }}`
- **Subject** : `{{ $('Rédiger').item.json.output.objet }}`
- **Email Type** : `Text`
- **Message** : `{{ $('Rédiger').item.json.output.corps }}`
- **Options** → **Append n8n Attribution** : désactivé

Puis **Noter la relance (Google Sheets)** `Update Row`, correspondance `entreprise` :

- `statut` = `relance`
- la colonne de l'étape : si `etape` vaut `relance1`, remplis `relance1` avec `{{ $now.toFormat('yyyy-MM-dd') }}`. Le plus simple : deux champs, `relance1` = `{{ $('À relancer ?').item.json.etape === 'relance1' ? $now.toFormat('yyyy-MM-dd') : $('À relancer ?').item.json.relance1 }}` et `relance2` = `{{ $('À relancer ?').item.json.etape === 'relance2' ? $now.toFormat('yyyy-MM-dd') : $('À relancer ?').item.json.relance2 }}`
- `majLe` = `{{ $now.toFormat('yyyy-MM-dd') }}`

**Branche false → Noter « sansreponse »** : `Update Row`, `statut` = `sansreponse`, `notes` = `Relance refusée le {{ $now.toFormat('yyyy-MM-dd') }}`.

## Tester

1. Dans le suivi, ajoute une ligne `TEST` avec **ton adresse personnelle** en `email`, `statut` = `envoye`, `dateEnvoi` = une date d'il y a 8 jours.
2. **Execute workflow**. Tu reçois la proposition sur Telegram.
3. Clique sur **Envoyer** : le mail arrive dans ta boîte personnelle, `relance1` est rempli.
4. Remets `relance1` à une date d'il y a 8 jours, relance : c'est la relance 2. Clique sur **Ne pas relancer** : statut `sansreponse`.
5. Supprime la ligne `TEST`, puis **Publish**.

## Vérifie

- [ ] Une ligne à J+7 génère une proposition sur Telegram, et aucune ligne à J+6.
- [ ] « Envoyer » envoie bien le mail et remplit la bonne colonne.
- [ ] « Ne pas relancer » n'envoie rien.
- [ ] Une exécution en attente apparaît en *Waiting* dans **Executions** tant que tu n'as pas répondu.
- [ ] Le workflow est publié, exporté et commité.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| Les boutons Telegram ne font rien | n8n n'est pas joignable depuis Internet, ou `WEBHOOK_URL` est faux | Vérifie `https://TON_DOMAINE/healthz` depuis ton téléphone, et `WEBHOOK_URL` dans le compose |
| Le Code ne trouve aucune ligne | Dates au mauvais format dans la feuille (`13/11/2026`) | Utilise `AAAA-MM-JJ` ; dans Sheets, format de cellule **Texte brut** |
| L'IF ne voit jamais `approved` | Chemin différent dans ta version | Ouvre l'exécution, regarde la sortie du nœud 6 et recopie le chemin |
| La relance est trop longue | Prompt | Renforce la limite de mots dans le message système |

## Exercice : refais-le seul

Modifie l'agent pour qu'il ne relance jamais un vendredi (une règle dans le Code : `aujourdhui.weekday === 5`), puis fais passer le délai de la seconde relance à 10 jours. Teste avec la ligne `TEST`.
