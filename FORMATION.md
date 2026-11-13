# Formation : construire ses agents IA avec n8n et Claude

Cette formation t'apprend à installer, de zéro, un serveur qui fait tourner tes propres agents IA, puis à concevoir ces agents toi-même. Le fil rouge est l'agent de recherche d'emploi de ce dépôt. La méthode, elle, sert pour n'importe quel agent : facturation, veille, prospection, réseaux sociaux…

## Pour qui, et comment l'utiliser

Elle est écrite pour quelqu'un qui apprend **en faisant, puis en refaisant**. Chaque chapitre suit toujours le même déroulé :

1. **Objectif** : ce que tu sauras faire à la fin, en une phrase.
2. **Pourquoi** : la raison de chaque étape. Si tu comprends le pourquoi, tu retrouveras le comment seul.
3. **Pas à pas** : les commandes et les clics, dans l'ordre, sans en sauter un seul.
4. **Vérifie** : comment savoir, sans doute possible, que ça a marché.
5. **Si ça bloque** : les erreurs les plus fréquentes et leur solution.
6. **Exercice : refais-le seul** : la même chose sans regarder, ou une variante. C'est là que ça rentre.

Trois règles pour en tirer le maximum :

- **Ne copie pas une commande sans lire son explication.** Le but n'est pas que ça marche une fois, c'est que tu saches le refaire.
- **Fais les exercices.** Un chapitre sans son exercice est à moitié appris.
- **Note tout dans [`docs/journal.md`](docs/journal.md)** : ce que tu as fait, compris, et ce qui t'a bloqué. Ce journal deviendra ta propre documentation.

### Conventions de lecture

| Ce que tu vois | Ce que ça veut dire |
|---|---|
| `[PC] $ commande` | À taper dans le terminal **de ton ordinateur** (PowerShell sous Windows, Terminal sous Mac) |
| `[VPS] $ commande` | À taper dans le terminal **connecté au serveur** (après `ssh`) |
| `[VPS] # commande` | Sur le serveur, en tant que `root` (administrateur) |
| `TON_IP`, `TON_DOMAINE` | À remplacer par ta propre valeur, sans garder les majuscules |
| Bloc *n8n* | Des clics dans l'interface de n8n, dans ton navigateur |

Ne tape jamais le `$`, le `#` ni le `[PC]` : ils indiquent seulement où tu es.

## Le parcours

| Partie | Chapitre | Ce que tu sauras faire | Durée |
|---|---|---|---|
| **1. Les bases** | [01 · Comprendre ce qu'on construit](formation/01-comprendre.md) | Expliquer le rôle de chaque pièce | 30 min |
| | [02 · Préparer ton ordinateur](formation/02-preparer-son-poste.md) | Avoir les bons outils et les bons comptes | 45 min |
| **2. Le serveur** | [03 · Louer le VPS](formation/03-louer-le-vps.md) | Commander un serveur Ubuntu adapté | 20 min |
| | [04 · Clé SSH et première connexion](formation/04-ssh.md) | Se connecter au serveur sans mot de passe | 45 min |
| | [05 · Sécuriser le serveur](formation/05-securiser.md) | Fermer les portes avant d'installer quoi que ce soit | 1 h |
| | [06 · Installer et comprendre Docker](formation/06-docker.md) | Lancer, arrêter et inspecter des conteneurs | 1 h |
| | [07 · Domaine et DNS](formation/07-domaine-dns.md) | Donner une adresse à ton serveur | 30 min |
| | [08 · Déployer la stack](formation/08-deployer-la-stack.md) | Lancer n8n, Postgres et Caddy depuis le dépôt | 1 h |
| | [09 · Premier accès et sécurité de n8n](formation/09-premier-acces.md) | Ouvrir n8n en HTTPS et le verrouiller | 20 min |
| **3. n8n** | [10 · Découvrir n8n](formation/10-decouvrir-n8n.md) | Comprendre nœuds, données, expressions, exécutions | 1 h 30 |
| | [11 · Connecter les services](formation/11-connecter-les-services.md) | Brancher Telegram, Claude, Google, Apify, France Travail | 2 h |
| | [12 · Ton premier agent](formation/12-premier-agent.md) | Un message de Claude sur Telegram chaque matin | 1 h |
| **4. La méthode** | [13 · Concevoir un agent : le canevas](formation/13-canevas-agent.md) | Concevoir n'importe quel agent, sur papier puis dans n8n | 1 h |
| **5. Les agents emploi** | [14 · Agent Boîte de réception](formation/14-agent-boite-reception.md) | Classer les réponses des recruteurs | 2 h |
| | [15 · Agent Relances](formation/15-agent-relances.md) | Relancer à J+7 et J+14 avec ta validation | 2 h |
| | [16 · Agent Envoi validé](formation/16-agent-envoi-valide.md) | Envoyer une candidature avec le CV en pièce jointe | 1 h 30 |
| | [17 · Agent Veille offres](formation/17-agent-veille-offres.md) | Recevoir chaque matin les meilleures offres notées | 2 h |
| | [18 · Agent Rapport du vendredi](formation/18-agent-rapport.md) | Mesurer ce qui marche | 45 min |
| **6. Durer et montrer** | [19 · Exploiter le serveur](formation/19-exploitation.md) | Sauvegarder, restaurer, mettre à jour, être alerté | 1 h 30 |
| | [20 · Sécurité des agents IA](formation/20-securite-agents.md) | Se protéger de l'injection de prompt | 45 min |
| | [21 · Git, GitHub et valorisation](formation/21-git-et-valorisation.md) | Travailler proprement et présenter le projet | 1 h |
| **Annexes** | [A · Mode local (sans VPS)](formation/annexe-a-mode-local.md) | Tester sur ton PC avant le serveur | |
| | [B · Dépannage](formation/annexe-b-depannage.md) | Retrouver la cause d'une erreur | |
| | [C · Aide-mémoire des commandes](formation/annexe-c-aide-memoire.md) | Toutes les commandes sur une page | |
| | [D · Glossaire](formation/annexe-d-glossaire.md) | Chaque mot technique en une phrase | |
| | [E · Ton VPS sur AWS](formation/annexe-e-aws.md) | Adapter les chapitres 03 à 07 à EC2 ou Lightsail | 30 min |

Total : environ 24 heures, soit quatre semaines à raison d'une heure par jour.

## Ce que tu auras à la fin

- Un serveur sécurisé que tu sais reconstruire de zéro en une heure.
- Cinq agents en production qui travaillent pour ta recherche d'emploi.
- Une méthode (le canevas du chapitre 13) pour créer tes propres agents.
- Un dépôt GitHub propre, avec CI, que tu peux présenter en entretien.
