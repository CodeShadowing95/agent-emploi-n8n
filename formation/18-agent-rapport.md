# 18 · Agent Rapport du vendredi

**Objectif :** chaque vendredi à 17 h, un résumé chiffré de ta semaine sur Telegram : envois, relances, réponses, entretiens, refus, et taux de réponse par canal.

**Durée :** 45 minutes. Aucun appel à Claude : c'est un agent 100 % règles.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Indicateur** (KPI) | Un chiffre suivi dans le temps pour savoir si une action marche. Ici, le taux de réponse. |
| **Taux de réponse** | Réponses reçues ÷ candidatures envoyées. Un taux de 15 % veut dire environ 1 réponse pour 7 envois. |
| **Agrégation** | Regrouper des lignes pour en tirer des totaux : compter, additionner, faire des moyennes. |
| **Canal** | Le chemin d'une candidature : `spontanee`, `offre` (job board), `cabinet`. |

## Pourquoi un agent sans IA

Compter des lignes est une **règle** : le faire faire par Claude coûterait de l'argent pour un résultat moins fiable. C'est l'application directe de la première question du canevas (chapitre 13). Un bon concepteur d'agents sait aussi quand ne pas utiliser l'IA.

## Le canevas

| Case | Contenu |
|---|---|
| 1. Objectif | Savoir chaque semaine ce qui marche, pour mettre mon énergie au bon endroit |
| 2. Déclencheur | Schedule `0 17 * * 5` |
| 3. Entrées | Toutes les lignes du suivi |
| 4. Règles | Compter par statut et par canal ; « cette semaine » = du lundi au vendredi en cours |
| 5. Jugement IA | Aucun |
| 7. Actions | Un message Telegram |
| 8. Validation humaine | Aucune |
| 10. Mesure | Comparer les taux d'une semaine à l'autre dans ton journal |

## Pas à pas

Crée un workflow `05 Rapport du vendredi`.

### Nœud 1 · Schedule Trigger

**Custom (Cron)** : `0 17 * * 5`.

### Nœud 2 · Lire le suivi (Google Sheets)

`Get Row(s)`, sans filtre.

### Nœud 3 · Calculer (Code)

```javascript
const lignes = $input.all().map(i => i.json);
const lundi = DateTime.now().setZone('Europe/Paris').startOf('week').toFormat('yyyy-MM-dd');
const cetteSemaine = date => Boolean(date) && String(date) >= lundi;

const repondu = ['entretien', 'refus'];
const compter = filtre => lignes.filter(filtre).length;

const semaine = {
  envois: compter(l => cetteSemaine(l.dateEnvoi)),
  relances: compter(l => cetteSemaine(l.relance1) || cetteSemaine(l.relance2)),
  entretiens: compter(l => l.statut === 'entretien' && cetteSemaine(l.majLe)),
  refus: compter(l => l.statut === 'refus' && cetteSemaine(l.majLe)),
  nouvellesOffres: compter(l => l.canal === 'offre' && l.statut === 'afaire' && cetteSemaine(l.majLe)),
};

// Taux de réponse depuis le début, par canal
const canaux = ['spontanee', 'offre', 'cabinet'];
const parCanal = canaux.map(canal => {
  const envoyees = lignes.filter(l => l.canal === canal && l.dateEnvoi);
  const reponses = envoyees.filter(l => repondu.includes(l.statut));
  const taux = envoyees.length ? Math.round((reponses.length / envoyees.length) * 100) : 0;
  return `${canal} : ${reponses.length}/${envoyees.length} (${taux} %)`;
});

const enCours = compter(l => ['envoye', 'relance'].includes(l.statut));

const texte = [
  `Semaine du ${DateTime.fromISO(lundi).setLocale('fr').toFormat('d LLLL')}`,
  `Envois : ${semaine.envois} · Relances : ${semaine.relances}`,
  `Entretiens : ${semaine.entretiens} · Refus : ${semaine.refus}`,
  `Nouvelles offres retenues : ${semaine.nouvellesOffres}`,
  `En attente de réponse : ${enCours}`,
  '',
  'Taux de réponse par canal (depuis le début) :',
  ...parCanal,
].join('\n');

return [{ json: { texte } }];
```

Lis ce code bloc par bloc :

1. `lundi` : la date du lundi de la semaine en cours. Les dates du suivi sont au format `AAAA-MM-JJ`, qui se compare correctement comme du texte : `"2026-11-13" >= "2026-11-09"` est vrai.
2. `semaine` : des compteurs filtrés sur cette semaine.
3. `parCanal` : pour chaque canal, réponses ÷ envois.
4. `texte` : le message, une ligne par information.

### Nœud 4 · Telegram

**Text** : `{{ $json.texte }}`, attribution désactivée.

Teste avec **Execute workflow**, puis **Publish**.

## Vérifie

- [ ] Les chiffres du message correspondent à ce que tu comptes à la main dans la feuille.
- [ ] Le message arrive seul le vendredi à 17 h.
- [ ] Après trois semaines, tu sais quel canal répond le mieux, et tu l'as noté dans ton journal.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| Tous les compteurs à 0 | Dates au mauvais format dans la feuille | Format `AAAA-MM-JJ`, cellules en texte brut |
| `DateTime is not defined` | Faute de frappe | Respecte la majuscule : `DateTime` |
| Un canal manque | Valeur différente dans la feuille (`Spontanée`) | Harmonise les valeurs de la colonne `canal` |

## Exercice : refais-le seul

Ajoute au rapport la liste des entreprises passées en `entretien` cette semaine, puis le nombre moyen de jours entre l'envoi et la première réponse. Ensuite, et seulement ensuite, demande-toi si une phrase de commentaire rédigée par Claude apporterait vraiment quelque chose : si oui, ajoute une Basic LLM Chain avant Telegram.
