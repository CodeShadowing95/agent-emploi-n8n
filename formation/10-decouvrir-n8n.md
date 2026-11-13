# 10 · Découvrir n8n

**Objectif :** comprendre comment les données circulent dans un workflow, écrire des expressions, et lire une exécution nœud par nœud. C'est le chapitre le plus important pour créer tes propres agents.

**Durée :** 1 h 30, entièrement pratique.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Workflow** | Une chaîne de nœuds reliés par des flèches. Chaque agent est un workflow. |
| **Nœud** (*node*) | Une étape du workflow : lire Gmail, appeler Claude, filtrer, envoyer un message… |
| **Déclencheur** (*trigger*) | Le premier nœud, celui qui démarre le workflow : une heure (Schedule), un nouveau mail (Gmail Trigger), un clic (Manual Trigger), un appel extérieur (Webhook). |
| **Canevas** (*canvas*) | La grande surface où tu poses et relies les nœuds. |
| **Item** | Une unité de donnée qui passe d'un nœud à l'autre. Si Gmail trouve 3 mails, il produit 3 items, et le nœud suivant s'exécute **une fois par item**. |
| **JSON** | Le format des données dans n8n : des paires `"clé": valeur` entre accolades. Exemple : `{"entreprise": "SFEIR", "score": 84}`. |
| **Champ** (*field*) | Une clé d'un item, comme `entreprise` ou `score`. |
| **Expression** | Un petit morceau de code entre `{{ }}` qui va chercher une valeur dans les données. `{{ $json.entreprise }}` = « le champ entreprise de l'item en cours ». |
| **Exécution** | Un passage complet du workflow. Chacune est enregistrée et consultable, avec les données de chaque nœud. |
| **Épingler des données** (*pin data*) | Figer la sortie d'un nœud pour tester la suite sans le relancer. Pratique pour ne pas rappeler Claude ou Gmail à chaque essai. |
| **Publier** (*publish*) | Mettre un workflow en production : il se déclenche alors tout seul. Avant, il ne tourne que quand tu cliques sur « Execute ». (Avant n8n 2.0, on disait « activer ».) |
| **Brouillon** | Les modifications non publiées. n8n enregistre tout automatiquement, mais la production n'utilise que la version publiée. |
| **Branche** | Un chemin du workflow après un nœud qui aiguille les items (IF, Switch). |

## Pourquoi ce chapitre compte

Neuf blocages sur dix dans n8n viennent d'une seule incompréhension : **quelles données arrivent dans ce nœud, et sous quel nom ?** Si tu maîtrises les items, les expressions et la lecture des exécutions, tu sais tout construire.

## Pas à pas

### 1. Tour de l'interface

*n8n* : à gauche, le menu.

| Élément | À quoi il sert |
|---|---|
| **Overview** | La liste de tes workflows et identifiants |
| **Create workflow** (bouton +) | Un nouveau workflow vide |
| **Credentials** | Tes connexions aux services (chapitre 11) |
| **Executions** | L'historique de toutes les exécutions |
| **Settings** | Ton compte, les utilisateurs, la licence |

Dans un workflow ouvert :

| Élément | À quoi il sert |
|---|---|
| Le **+** sur le canevas ou à droite d'un nœud | Ajouter un nœud |
| **Execute workflow** (en bas) | Lancer le workflow une fois, pour tester |
| **Publish** (en haut à droite) | Mettre en production |
| Onglet **Executions** (en haut) | L'historique de ce workflow |
| Double-clic sur un nœud | Ouvrir ses réglages : entrée à gauche, paramètres au milieu, sortie à droite |

### 2. Ton premier workflow d'essai

Crée un workflow, nomme-le `Essai : découvrir n8n`.

**Nœud 1 : Manual Trigger.** Ajoute **Trigger manually**. C'est le déclencheur « je clique ».

**Nœud 2 : Code**, pour fabriquer trois fausses candidatures. Ajoute un nœud **Code**, mode **Run Once for All Items**, langage JavaScript, et remplace le contenu par :

```javascript
return [
  { json: { entreprise: "SFEIR", ville: "Strasbourg", score: 84, statut: "envoye", dateEnvoi: "2026-11-02" } },
  { json: { entreprise: "Viveris", ville: "Strasbourg", score: 82, statut: "afaire", dateEnvoi: "" } },
  { json: { entreprise: "Inetum", ville: "Strasbourg", score: 65, statut: "envoye", dateEnvoi: "2026-10-26" } },
];
```

Un nœud Code doit toujours renvoyer une **liste d'items**, chacun de la forme `{ json: { … } }`.

Clique sur **Execute step**. À droite, la sortie montre 3 items. Essaie les trois vues : **Table**, **JSON**, **Schema**.

**Nœud 3 : Filter.** Ajoute un nœud **Filter**. Condition : glisse le champ `score` depuis le panneau de gauche jusqu'à la case de valeur. n8n écrit tout seul `{{ $json.score }}`. Choisis **Number** → **is greater than or equal to** → `70`. Exécute : il ne reste que 2 items. Inetum a été retiré.

**Nœud 4 : Edit Fields (Set).** Ajoute **Edit Fields (Set)**, et crée un champ `message` de type String avec la valeur :

```
Candidature {{ $json.entreprise }} ({{ $json.ville }}) : note {{ $json.score }}/100
```

Exécute : chaque item a un champ `message` différent. **L'expression a été calculée une fois par item.**

### 3. Les expressions à connaître

| Expression | Ce qu'elle donne |
|---|---|
| `{{ $json.entreprise }}` | Le champ `entreprise` de l'item en cours, tel qu'il arrive dans ce nœud |
| `{{ $json["date envoi"] }}` | Un champ dont le nom contient un espace |
| `{{ $('Code').item.json.ville }}` | Le champ `ville` de l'item correspondant, **dans un nœud précédent** nommé `Code` |
| `{{ $now.toFormat('yyyy-MM-dd') }}` | La date du jour, par exemple `2026-11-13` |
| `{{ $now.minus({ days: 7 }).toFormat('yyyy-MM-dd') }}` | La date d'il y a 7 jours |
| `{{ $json.score >= 70 ? 'retenue' : 'écartée' }}` | Une condition : « si… alors… sinon… » |
| `{{ $json.entreprise.toUpperCase() }}` | Du JavaScript simple fonctionne : ici, en majuscules |

Astuce : dans un champ, clique sur **Expression** (au lieu de **Fixed**) pour ouvrir l'éditeur. Le résultat s'affiche en direct en dessous.

### 4. Aiguiller : IF et Switch

Remplace le Filter par un **IF** (même condition, `score >= 70`). Le nœud IF a deux sorties : **true** et **false**. Branche un Edit Fields différent sur chacune. Exécute : les items se répartissent sur les deux branches.

Le **Switch** fait la même chose avec plus de deux sorties. On l'utilisera pour classer les mails : refus, entretien, demande d'infos…

### 5. Lire une exécution

Clique sur l'onglet **Executions** du workflow, puis sur la dernière exécution. Tu revois le canevas tel qu'il était, avec le nombre d'items sur chaque flèche. Clique sur chaque nœud : tu vois exactement ce qui est entré et sorti.

**Règle de dépannage n° 1 :** quand quelque chose ne marche pas, ouvre l'exécution et remonte les nœuds un par un jusqu'à trouver le premier dont la sortie n'est pas celle que tu attendais.

### 6. Épingler des données

Sur la sortie du nœud Code, clique sur l'icône **épingle** (*Pin data*). La sortie est figée : aux prochains tests, n8n ne réexécutera pas ce nœud. Indispensable quand le nœud appelle Claude (ça coûte) ou Gmail (ça prend du temps). Désépingle avant de publier. Le script `export-workflows.sh` retire de toute façon les données épinglées avant chaque export.

### 7. Tester, puis publier

- **Execute workflow** : une exécution de test, maintenant, avec toi devant.
- **Publish** : le workflow passe en production. Les déclencheurs automatiques (horaire, nouveau mail) ne fonctionnent **qu'après publication**.
- Chaque modification ultérieure reste un brouillon jusqu'au prochain **Publish**. Le bouton est actif dès qu'il y a des changements non publiés.

Un workflow à déclencheur manuel n'a pas besoin d'être publié.

### 8. Les nœuds que tu utiliseras le plus

| Nœud | Rôle |
|---|---|
| **Schedule Trigger** | Déclencher à heure fixe |
| **Gmail Trigger** | Déclencher sur un nouveau mail (n8n vérifie Gmail à intervalle régulier) |
| **Edit Fields (Set)** | Créer ou renommer des champs |
| **Filter** | Garder les items qui respectent une condition |
| **IF / Switch** | Aiguiller les items vers des branches |
| **Code** | Tout ce qu'aucun nœud ne fait : calculs de dates, mise en forme |
| **Merge** | Réunir deux flux d'items |
| **Loop Over Items** | Traiter les items par paquets, par exemple pour respecter une limite d'envoi |
| **HTTP Request** | Appeler n'importe quelle API |
| **Basic LLM Chain** + **Anthropic Chat Model** | Demander quelque chose à Claude |
| **Structured Output Parser** | Forcer Claude à répondre dans un format JSON précis |
| **Google Sheets, Gmail, Telegram** | Lire et écrire dans ces services |
| **Error Trigger** | Démarrer un workflow quand un autre échoue (chapitre 19) |

## Vérifie

- [ ] Ton workflow d'essai produit 2 items avec un champ `message` correct.
- [ ] Tu sais retrouver, dans une exécution passée, ce qui est sorti d'un nœud.
- [ ] Tu sais expliquer la différence entre `{{ $json.x }}` et `{{ $('Nom du nœud').item.json.x }}`.
- [ ] Tu sais la différence entre exécuter et publier.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| L'expression affiche `undefined` ou `[null]` | Le champ n'existe pas sous ce nom à cet endroit | Regarde le panneau d'entrée du nœud : glisse le champ plutôt que de le taper |
| `Code doesn't return items properly` | Le Code ne renvoie pas une liste de `{ json: … }` | Vérifie le `return [...]` |
| Le workflow ne se déclenche jamais seul | Il n'est pas publié | Clique sur **Publish** |
| Un nœud s'exécute une seule fois au lieu de plusieurs | Il reçoit un seul item contenant une liste | Utilise **Split Out** pour transformer la liste en items |

## Exercice : refais-le seul

Sans regarder, construis un workflow qui :

1. crée 4 fausses offres avec un Code (titre, entreprise, score) ;
2. les sépare avec un IF : score de 75 ou plus d'un côté, le reste de l'autre ;
3. sur la branche « true », crée un champ `texte` : `« <titre> chez <entreprise> : <score>/100 »` ;
4. sur la branche « false », crée un champ `raison` : `« note trop basse »`.

Puis retrouve l'exécution et explique, nœud par nœud, combien d'items sont passés et pourquoi.
