# 16 · Agent Envoi validé

**Objectif :** les candidatures préparées (statut `pret`) te sont présentées une par une sur Telegram ; sur ton accord, l'agent les envoie depuis ton Gmail **avec le bon CV en pièce jointe**, et met à jour le suivi.

**Durée :** 1 h 30.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Données binaires** (*binary data*) | Dans n8n, un fichier (PDF, image) qui voyage avec un item, à côté de son JSON. Il est rangé dans un champ binaire, souvent nommé `data`. |
| **Pièce jointe** | Un fichier envoyé avec un mail. Le nœud Gmail la prend dans un champ binaire. |
| **Chemin de fichier** | L'adresse d'un fichier dans un système, par exemple `/home/node/.n8n-files/CV_Patrick_NAMEGNI_java.pdf`. |
| **Limit** | Un nœud qui ne laisse passer que les N premiers items. |
| **Délivrabilité** | La capacité de tes mails à arriver en boîte de réception plutôt qu'en spam. Envoyer trop, trop vite, la dégrade. |

## Le canevas

| Case | Contenu |
|---|---|
| 1. Objectif | Envoyer les candidatures prêtes, au bon moment, avec la bonne pièce jointe |
| 2. Déclencheur | Schedule `30 8 * * 2-4` (mardi, mercredi, jeudi à 8 h 30, les créneaux où les recruteurs lisent le plus) |
| 3. Entrées | Les lignes `pret` du suivi (avec `email`, `objet`, `corps`, `cv`) ; les PDF dans `fichiers/` |
| 4. Règles | Statut `pret` ; email, objet, corps et cv remplis ; 10 envois au maximum par jour |
| 5. Jugement IA | Aucun : le texte a été rédigé avant (par Claude dans le projet, ou par toi) |
| 6. Format | Sans objet |
| 7. Actions | Lire le PDF, envoyer le mail, passer la ligne en `envoye` avec la date et le `threadId` |
| 8. Validation humaine | **Oui** : chaque mail passe par Telegram |
| 9. Garde-fous | Plafond de 10 ; vérification que le PDF existe ; aucun envoi sans clic |
| 10. Test | Une ligne `TEST` vers ton adresse personnelle |

## Le schéma

```
Schedule ─► Lire les « pret » ─► Complètes ? (Filter) ─► Limit 10 ─► Validation Telegram ─► IF approuvé ─┬► Lire le CV ─► Envoyer (Gmail + PJ) ─► Passer en « envoye »
 mar-jeu                                                              (pause)                            └► Remettre en « afaire »
 8 h 30
```

## Préparation

1. Copie tes CV sur le serveur, dans le dossier lu par n8n. Depuis ton PC :

```bash
[PC] $ scp CV_Patrick_NAMEGNI_java.pdf agent:~/agent-emploi-n8n/fichiers/
[VPS] $ sudo chown 1000:1000 ~/agent-emploi-n8n/fichiers/*.pdf
[VPS] $ ls -la ~/agent-emploi-n8n/fichiers/
```

`scp` copie un fichier par SSH. Ces PDF ne vont jamais dans Git : le `.gitignore` les exclut.

2. Dans le suivi, une candidature prête ressemble à ceci :

| entreprise | email | statut | cv | objet | corps |
|---|---|---|---|---|---|
| Versusmind | jobs@versusmind.eu | pret | CV_Patrick_NAMEGNI_java.pdf | Développeur full stack Java · Patrick Namegni | Bonjour, Votre agence strasbourgeoise… |

## Pas à pas, nœud par nœud

Crée un workflow `03 Envoi validé`.

### Nœud 1 · Schedule Trigger

**Custom (Cron)** : `30 8 * * 2-4`.

### Nœud 2 · Lire les « pret » (Google Sheets)

`Get Row(s)` ; **Filters** → colonne `statut`, valeur `pret`.

### Nœud 3 · Complètes ? (Filter)

Quatre conditions, combinées en **AND** : `{{ $json.email }}`, `{{ $json.objet }}`, `{{ $json.corps }}`, `{{ $json.cv }}`, chacune **String → is not empty**.

Une ligne incomplète est ignorée en silence : elle restera `pret` et tu la verras dans la feuille.

### Nœud 4 · Limit

**Max Items** : `10`.

### Nœud 5 · Validation (Telegram, Send and Wait for Response)

Mêmes réglages qu'au chapitre 15, avec les boutons `Envoyer` / `Pas maintenant` et un délai de `1` jour. Message :

```
Candidature à envoyer : {{ $json.entreprise }}
À : {{ $json.email }}
PJ : {{ $json.cv }}
Objet : {{ $json.objet }}

{{ $json.corps }}
```

### Nœud 6 · IF approuvé

`{{ $json.data.approved }}` **is true** (même remarque qu'au chapitre 15 sur le chemin exact).

### Nœud 7 · Lire le CV (Read/Write Files from Disk), branche true

- **Operation** : `Read File(s) From Disk`
- **File(s) Selector** : `/home/node/.n8n-files/{{ $('Limit').item.json.cv }}`
- **Options** → **Put Output File in Field** : `data`

Depuis n8n 2.0, ce nœud ne peut lire que dans `/home/node/.n8n-files`, le dossier relié à `fichiers/` par le compose (chapitre 08). C'est une protection : un workflow ne peut pas aller lire n'importe quel fichier du serveur.

Exécute : la sortie montre un onglet **Binary** avec ton PDF. Clique dessus pour l'ouvrir et vérifier que c'est le bon.

### Nœud 8 · Envoyer (Gmail)

- **Operation** : `Send`
- **To** : `{{ $('Limit').item.json.email }}`
- **Subject** : `{{ $('Limit').item.json.objet }}`
- **Email Type** : `Text`
- **Message** : `{{ $('Limit').item.json.corps }}`
- **Options** → **Attachments** → **Attachment Field Name** : `data` ; **Append n8n Attribution** : désactivé

La sortie du nœud contient l'`id` et le `threadId` du mail envoyé.

### Nœud 9 · Passer en « envoye » (Google Sheets)

`Update Row`, correspondance `entreprise` :

- `entreprise` = `{{ $('Limit').item.json.entreprise }}`
- `statut` = `envoye`
- `dateEnvoi` = `{{ $now.toFormat('yyyy-MM-dd') }}`
- `threadId` = `{{ $json.threadId }}`
- `majLe` = `{{ $now.toFormat('yyyy-MM-dd') }}`

C'est ce `dateEnvoi` qui déclenchera la relance du chapitre 15 sept jours plus tard. Les agents s'enchaînent par le suivi.

### Branche false de l'IF · Remettre en « afaire »

`Update Row`, `statut` = `afaire`, `notes` = `Envoi reporté le {{ $now.toFormat('yyyy-MM-dd') }}`.

## Tester

1. Ligne `TEST` : ton adresse personnelle, `statut` `pret`, un `objet`, un `corps`, `cv` = le nom exact d'un PDF présent dans `fichiers/`.
2. **Execute workflow** (le déclencheur horaire est ignoré en test manuel).
3. Clique sur **Envoyer** : le mail arrive avec le PDF, la ligne passe en `envoye` avec la date.
4. Recommence avec **Pas maintenant** : rien n'est envoyé, la ligne passe en `afaire`.
5. Recommence avec un nom de PDF erroné : le nœud 7 doit échouer (et le workflow d'erreur du chapitre 19 te préviendra).
6. Supprime la ligne `TEST`, puis **Publish**.

## Vérifie

- [ ] Le mail reçu contient la bonne pièce jointe, lisible.
- [ ] Le texte du mail ne contient pas de mention « Sent automatically with n8n ».
- [ ] La ligne passe en `envoye` avec `dateEnvoi` et `threadId`.
- [ ] Jamais plus de 10 propositions par matin.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `Access to the file is not allowed` | Le chemin n'est pas dans `/home/node/.n8n-files` | Vérifie le chemin et le volume du compose |
| `No such file or directory` | Nom de fichier différent (majuscules, espace, extension) | `ls fichiers/` sur le serveur et recopie le nom exact |
| `EACCES: permission denied` | Le PDF appartient à root | `sudo chown 1000:1000 fichiers/*.pdf` |
| Mail reçu sans pièce jointe | Mauvais nom de champ binaire | Le champ doit être `data` dans les deux nœuds |

## Exercice : refais-le seul

Ajoute une règle : ne jamais envoyer à une entreprise dont une autre ligne est déjà en `entretien` ou en `refus` (un Code ou un second Google Sheets suivi d'un Filter). Puis ajoute un second PDF en pièce jointe (une lettre de recommandation) : lis deux fichiers et indique `data,data_1` comme champs de pièces jointes, en vérifiant les noms dans la sortie.
