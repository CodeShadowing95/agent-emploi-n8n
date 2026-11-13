# 01 · Comprendre ce qu'on construit

**Objectif :** être capable d'expliquer, sans notes, le rôle de chaque pièce du système et le chemin d'une donnée de bout en bout.

**Durée :** 30 minutes. Pas de commande dans ce chapitre : on comprend avant de toucher.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Agent IA** | Un programme qui reçoit une information, la fait analyser par une IA, puis agit (écrire, classer, envoyer) selon le résultat. Ici, un agent = un workflow n8n qui appelle Claude. |
| **Automatisation** | Faire exécuter par une machine une suite de tâches qu'on faisait à la main, toujours de la même façon. |
| **Serveur** | Un ordinateur qui reste allumé en permanence pour rendre un service à d'autres (afficher un site, exécuter des tâches). |
| **VPS** (*Virtual Private Server*, serveur privé virtuel) | Un serveur que tu loues chez un hébergeur. Il est « virtuel » parce que plusieurs VPS se partagent la même machine physique, mais chacun a sa part réservée (processeur, mémoire, disque) et son propre système. Pour toi, il se comporte comme un ordinateur Linux à distance dont tu es le seul maître. |
| **n8n** | Un logiciel d'automatisation : on y dessine des chaînes d'étapes (les workflows) qui se déclenchent seules. Prononcé « n-eight-n », pour *nodemation*. |
| **Claude** | Le modèle d'IA d'Anthropic. Dans notre système, il ne fait que réfléchir : lire, classer, noter, rédiger. |
| **API** (*Application Programming Interface*) | Une porte d'entrée qu'un logiciel ouvre aux autres programmes. Au lieu de cliquer dans une interface, un programme envoie une requête et reçoit une réponse structurée. |
| **Webhook** | L'inverse d'un appel d'API : c'est une adresse web chez toi que **les autres** appellent pour te prévenir d'un événement. Comme une sonnette : tu n'as pas besoin de regarder par la fenêtre, on sonne quand quelqu'un arrive. |
| **Humain dans la boucle** | Un principe de conception : l'agent prépare, une personne valide, puis l'agent exécute. Toute action irréversible (envoyer un mail) passe par ta validation. |

## 1. Le problème qu'on résout

Ta recherche d'emploi, aujourd'hui, c'est une suite de tâches répétitives :

- chercher des offres sur plusieurs sites, tous les jours ;
- juger si chaque offre correspond à ton profil ;
- écrire un mail personnalisé, joindre le bon CV ;
- surveiller ta boîte mail pour ne rater aucune réponse ;
- relancer au bon moment ;
- tenir un tableau de suivi à jour.

Chaque tâche prend quelques minutes, mais multipliée par des dizaines de candidatures, elle mange tes journées. Et c'est exactement le genre de travail qu'une machine fait bien : **répétitif, régulier, avec des règles claires**. La partie qui demande du jugement (cette offre me correspond-elle ? ce mail est-il un refus ?) est confiée à Claude.

## 2. La règle d'or : Claude réfléchit, n8n exécute, toi tu valides

Retiens cette phrase, tout le système en découle.

| Qui | Son rôle | Exemples | Ce qu'il ne fait jamais |
|---|---|---|---|
| **n8n** | Les mains : déclencher, transporter les données, appeler les services | « Il est 7 h, je récupère les offres », « un mail est arrivé, je le lis » | Juger, rédiger |
| **Claude** | Le cerveau : analyser et rédiger | « Cette offre vaut 82/100 », « ce mail est un refus », « voici une relance » | Agir seul, envoyer quoi que ce soit |
| **Toi** | Le chef : décider | « Oui, envoie cette relance » | Les tâches répétitives |

Pourquoi séparer ainsi ? Parce qu'une IA peut se tromper ou être manipulée (chapitre 20). En lui retirant le pouvoir d'agir, une erreur de Claude reste une erreur de brouillon, jamais un mail envoyé par erreur à un recruteur.

## 3. Les pièces du système

```
                    ┌──────────────── VPS Ubuntu (ton serveur) ────────────────┐
                    │                                                            │
  Internet ───────► │  Caddy        la porte d'entrée, gère le HTTPS             │
                    │    │                                                       │
                    │    ▼                                                       │
                    │  n8n          exécute les workflows (les agents)           │
                    │    │                                                       │
                    │    ▼                                                       │
                    │  Postgres     la mémoire de n8n (workflows, historique)    │
                    │                                                            │
                    │  Les trois tournent dans Docker, décrits par docker-compose │
                    └────────────────────────────────────────────────────────────┘
                              │                 ▲
           n8n appelle ───────┘                 └─────── certains services rappellent n8n
           (API)                                         (webhooks, via Caddy)

  Gmail · Apify (LinkedIn) · France Travail · API Claude · Google Sheets · Telegram
```

Chaque pièce, une par une :

- **Le VPS** : l'ordinateur loué qui tourne jour et nuit (chapitre 3).
- **Ubuntu** : le système d'exploitation du serveur, comme Windows sur ton PC, mais sans interface graphique : tout se fait en tapant des commandes.
- **Docker** : un outil qui fait tourner chaque logiciel dans sa propre boîte isolée, appelée conteneur. Avantage : on installe n8n en une commande, et on le supprime sans laisser de traces (chapitre 6).
- **Caddy** : le seul logiciel visible depuis Internet. Il reçoit les visiteurs, chiffre la connexion (HTTPS) et les transmet à n8n (chapitre 7).
- **n8n** : le chef d'orchestre des agents (chapitre 10).
- **Postgres** : une base de données. n8n y range ses workflows, tes identifiants chiffrés et l'historique de chaque exécution.
- **Les services extérieurs** : Gmail (lire et envoyer tes mails), Google Sheets (le tableau de suivi), Telegram (te prévenir et te demander ta validation), l'API Claude (réfléchir), Apify et France Travail (trouver des offres).

## 4. Le trajet d'une donnée : un exemple complet

Suivons un mail de refus, du moment où il arrive jusqu'à ton téléphone.

1. **10 h 02** : un recruteur de la société X te répond « Nous ne donnerons pas suite ».
2. **10 h 05** : n8n, qui consulte Gmail toutes les 5 minutes, trouve ce nouveau mail.
3. n8n cherche l'expéditeur dans ton Google Sheet : c'est bien la société X, à qui tu as écrit le 26 octobre.
4. n8n envoie le texte du mail à Claude avec une consigne : « Classe ce mail dans une de ces catégories : refus, entretien, demande d'informations, accusé de réception, autre. Réponds en JSON. »
5. Claude répond : `{"categorie": "refus", "resume": "Refus poli, profil gardé en vivier"}`.
6. n8n lit la catégorie, passe la ligne de X à « refus » dans le Google Sheet et ajoute le résumé dans les notes.
7. n8n t'envoie sur Telegram : « Refus de X. Profil gardé en vivier. »
8. n8n pose une étiquette « agent-traite » sur le mail pour ne jamais le traiter deux fois.

Tu n'as rien fait, et ton suivi est à jour en 3 minutes. Si le mail avait été une proposition d'entretien, tu aurais reçu une alerte prioritaire.

## 5. Pourquoi un serveur, et pas ton PC ?

Tout peut tourner sur ton PC (annexe A), et c'est une bonne façon de tester. Mais :

- un agent sur ton PC s'arrête quand tu l'éteins ;
- certains services (les boutons Telegram) doivent pouvoir joindre n8n depuis Internet, ce qui est compliqué et risqué sur une box personnelle ;
- savoir installer et sécuriser un serveur Linux est une compétence recherchée, qui valorise ton CV.

## Vérifie

Tu as compris ce chapitre si tu peux répondre, sans relire, à ces cinq questions :

1. Pourquoi Claude n'a-t-il jamais le droit d'envoyer un mail lui-même ?
2. Quelle est la différence entre une API et un webhook ?
3. Quel est le seul logiciel visible depuis Internet, et pourquoi ?
4. Où n8n range-t-il ses workflows ?
5. Dans l'exemple du mail de refus, à quelle étape intervient Claude, et pour faire quoi exactement ?

## Exercice : refais-le seul

Sur une feuille, dessine le schéma de la section 3 de mémoire. Puis décris, comme dans la section 4, le trajet d'une **proposition d'entretien**, du mail reçu jusqu'à ton téléphone. Compare ensuite avec le chapitre 14.
