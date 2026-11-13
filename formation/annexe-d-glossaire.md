# Annexe D · Glossaire de A à Z

Tous les mots de la formation, rangés par ordre alphabétique, avec une définition simple et le chapitre où ils sont expliqués en situation. Il y en a 220.

**Comment t'en servir :**

- Un mot te bloque dans un chapitre ? Cherche-le ici (Ctrl + F dans ton navigateur ou dans VS Code).
- Le lien en fin de définition t'emmène là où le mot est utilisé pour de vrai : relis ce passage, c'est là que le sens se fixe.
- Quand un mot a deux sens selon le contexte (par exemple **Branche** dans n8n et dans Git), les deux sont numérotés **(1)** et **(2)**.
- Exercice régulier : prends cinq mots au hasard, cache la définition, et explique-les à voix haute comme à un ami qui n'y connaît rien. Si tu bloques, relis le chapitre indiqué.

[0-9](#0-9) · [A](#a) · [B](#b) · [C](#c) · [D](#d) · [E](#e) · [F](#f) · [G](#g) · [H](#h) · [I](#i) · [J](#j) · [K](#k) · [L](#l) · [M](#m) · [N](#n) · [O](#o) · [P](#p) · [R](#r) · [S](#s) · [T](#t) · [U](#u) · [V](#v) · [W](#w) · [Y](#y) · [Z](#z)

## 0-9

**2FA** (double authentification, ou MFA) · En plus du mot de passe, un code à 6 chiffres qui change toutes les 30 secondes, généré par une application sur ton téléphone. Un voleur de mot de passe ne peut rien sans ton téléphone. *(voir [09](09-premier-acces.md))*


## A

**Actor Apify** · Un scraper prêt à l'emploi sur Apify. On utilise `valig/linkedin-jobs-scraper`, déjà testé pour ce projet. *(voir [17](17-agent-veille-offres.md))*

**Adresse IP** · Le numéro qui identifie ton serveur sur Internet, par exemple `203.0.113.42`. C'est son adresse postale. *(voir [03](03-louer-le-vps.md))*

**Agent IA** · Un programme qui reçoit une information, la fait analyser par une IA, puis agit (écrire, classer, envoyer) selon le résultat. Ici, un agent = un workflow n8n qui appelle Claude. *(voir [01](01-comprendre.md))*

**Agrégation** · Regrouper des lignes pour en tirer des totaux : compter, additionner, faire des moyennes. *(voir [18](18-agent-rapport.md))*

**AMI** (*Amazon Machine Image*) · L'image du système installé sur l'instance. Ici : Ubuntu 24.04 LTS. *(voir [annexe E](annexe-e-aws.md))*

**Anthropic** · L'entreprise qui crée Claude. Sa console (console.anthropic.com) sert à créer ta clé d'API, suivre ta consommation et fixer une limite de dépense. *(voir [01](01-comprendre.md), [11](11-connecter-les-services.md))*

**API** (*Application Programming Interface*) · Une porte d'entrée qu'un logiciel ouvre aux autres programmes. Au lieu de cliquer dans une interface, un programme envoie une requête et reçoit une réponse structurée. *(voir [01](01-comprendre.md))*

**Apify** · Une plateforme qui fait tourner des robots de collecte (les *Actors*). On s'en sert pour récupérer les offres LinkedIn sans les copier à la main. *(voir [11](11-connecter-les-services.md), [17](17-agent-veille-offres.md))*

**Application d'authentification** · L'application qui génère ces codes : Google Authenticator, Microsoft Authenticator, ou celle de Bitwarden. *(voir [09](09-premier-acces.md))*

**Approval** (approbation) · Le type de réponse le plus simple : un bouton « Approuver » et, si tu veux, un bouton « Refuser ». *(voir [15](15-agent-relances.md))*

**ATS** (*Applicant Tracking System*) · Le logiciel de recrutement des entreprises (Welcome to the Jungle, Teamtailor, Workday…). Beaucoup de réponses arrivent depuis leur adresse, pas celle du recruteur. *(voir [14](14-agent-boite-reception.md))*

**`authorized_keys`** · Le fichier du serveur qui liste les clés publiques autorisées à se connecter. *(voir [04](04-ssh.md))*

**Automatisation** · Faire exécuter par une machine une suite de tâches qu'on faisait à la main, toujours de la même façon. *(voir [01](01-comprendre.md))*

**AWS** (*Amazon Web Services*) · Le service d'hébergement d'Amazon. Il loue des serveurs, du stockage et des centaines d'autres services, facturés à l'usage. *(voir [annexe E](annexe-e-aws.md))*


## B

**Base de données** · Un logiciel spécialisé dans le rangement et la recherche de données. **Postgres** (ou PostgreSQL) est l'une des plus fiables. *(voir [08](08-deployer-la-stack.md))*

**Bash** · Le langage du terminal Linux. Un fichier `.sh` contient une suite de commandes Bash, lancées d'un coup. *(voir [19](19-exploitation.md))*

**Bot Telegram** · Un compte Telegram piloté par un programme. Le tien enverra les messages de tes agents. *(voir [11](11-connecter-les-services.md))*

**Branche** · **(1)** Un chemin du workflow après un nœud qui aiguille les items (IF, Switch). **(2)** Une ligne de travail parallèle. `main` est la version stable ; chaque nouveauté se fait sur une branche à part, puis rejoint `main`. *(voir [10](10-decouvrir-n8n.md), [21](21-git-et-valorisation.md))*

**Brouillon** · Les modifications non publiées. n8n enregistre tout automatiquement, mais la production n'utilise que la version publiée. *(voir [10](10-decouvrir-n8n.md))*

**Budget** · Une alerte AWS qui t'écrit quand tes dépenses dépassent un montant. *(voir [annexe E](annexe-e-aws.md))*


## C

**Caddy** · Le *reverse proxy* de notre stack : il reçoit les visites sur les ports 80 et 443, obtient seul le certificat HTTPS, et transmet à n8n. *(voir [08](08-deployer-la-stack.md))*

**Cadenas** · L'icône du navigateur qui confirme une connexion HTTPS avec un certificat valide. *(voir [09](09-premier-acces.md))*

**Canal** · Le chemin d'une candidature : `spontanee`, `offre` (job board), `cabinet`. *(voir [18](18-agent-rapport.md))*

**Canevas** · Un modèle à remplir, case par case, pour ne rien oublier. *(voir [13](13-canevas-agent.md))*

**Canevas** (*canvas*) · La grande surface où tu poses et relies les nœuds. *(voir [10](10-decouvrir-n8n.md))*

**Cas limite** · Une situation rare mais possible, qui casse souvent un agent mal pensé : un mail vide, une offre sans entreprise, un recruteur qui répond deux fois. *(voir [13](13-canevas-agent.md))*

**Cause** · La raison réelle du problème. Une même cause peut donner plusieurs symptômes. *(voir [annexe B](annexe-b-depannage.md))*

**Certificat** · Le document numérique qui prouve qu'un serveur est bien le propriétaire du domaine. Indispensable au HTTPS. *(voir [07](07-domaine-dns.md))*

**Chaîne** (*chain*) · Dans n8n, un nœud qui envoie un prompt à un modèle et récupère sa réponse. La **Basic LLM Chain** fait un aller-retour simple. *(voir [12](12-premier-agent.md))*

**Champ** (*field*) · Une clé d'un item, comme `entreprise` ou `score`. *(voir [10](10-decouvrir-n8n.md))*

**chat_id** · Le numéro de la conversation Telegram entre toi et ton bot. n8n en a besoin pour savoir à qui écrire. *(voir [11](11-connecter-les-services.md))*

**Chemin de fichier** · L'adresse d'un fichier dans un système, par exemple `/home/node/.n8n-files/CV_Patrick_NAMEGNI_java.pdf`. *(voir [16](16-agent-envoi-valide.md))*

**CI** (intégration continue) · Des vérifications automatiques lancées par GitHub Actions à chaque push et chaque PR. *(voir [21](21-git-et-valorisation.md))*

**Claude** · Le modèle d'IA d'Anthropic. Dans notre système, il ne fait que réfléchir : lire, classer, noter, rédiger. *(voir [01](01-comprendre.md))*

**Clé d'API** · Un long mot de passe qu'un service te donne pour que tes programmes l'utilisent. Elle se garde secrète comme un mot de passe. *(voir [11](11-connecter-les-services.md))*

**Clé de chiffrement** · Une longue suite de caractères aléatoires qui sert à chiffrer les identifiants enregistrés dans n8n. Sans elle, ils sont illisibles. *(voir [08](08-deployer-la-stack.md))*

**Clé de déploiement** (*deploy key*) · Une clé SSH qui donne accès à **un seul** dépôt GitHub. On la pose sur le serveur pour qu'il puisse pousser dans le dépôt, sans lui confier ton compte entier. *(voir [12](12-premier-agent.md))*

**Clé privée** · Fichier `id_ed25519`, sans extension. Elle ne quitte **jamais** ton PC, ne s'envoie à personne, ne se colle nulle part. *(voir [04](04-ssh.md))*

**Clé publique** · Fichier `id_ed25519.pub`. On peut la donner à n'importe qui sans risque : elle ne permet que de vérifier. *(voir [04](04-ssh.md))*

**Client credentials** · Une variante d'OAuth2 sans fenêtre de connexion : l'application s'identifie seule avec son Client ID et son Secret. France Travail l'utilise. *(voir [11](11-connecter-les-services.md))*

**Client ID / Client Secret** · L'identifiant et le mot de passe de **ton application** chez Google (ou France Travail), pas de ton compte. *(voir [11](11-connecter-les-services.md))*

**Cloner** · Télécharger une copie complète d'un dépôt GitHub sur ton ordinateur. *(voir [02](02-preparer-son-poste.md))*

**Code commune INSEE** · Le numéro officiel d'une commune française. Strasbourg : `67482`. France Travail l'utilise pour la localisation. *(voir [17](17-agent-veille-offres.md))*

**Code HTTP** · Le nombre à trois chiffres que renvoie un service web : `200` = OK, `401`/`403` = accès refusé, `404` = introuvable, `429` = trop de demandes, `5xx` = le service a planté. *(voir [annexe B](annexe-b-depannage.md))*

**Code** (nœud) · Un nœud n8n où tu écris quelques lignes de JavaScript quand aucun nœud tout fait ne convient : calculer une date, comparer deux listes. *(voir [10](10-decouvrir-n8n.md), [14](14-agent-boite-reception.md))*

**Codes de secours** · Des codes à usage unique pour te connecter si tu perds ton téléphone. À ranger dans ton gestionnaire. *(voir [09](09-premier-acces.md))*

**Commande** · Une instruction tapée dans le terminal, validée par la touche Entrée. Exemple : `git --version` demande à Git d'afficher sa version. *(voir [02](02-preparer-son-poste.md))*

**Commit** · Une photo de l'état de tes fichiers à un instant, avec un message qui explique le changement. *(voir [02](02-preparer-son-poste.md))*

**Compte propriétaire** (*owner*) · Le premier compte créé dans n8n, qui a tous les droits. *(voir [09](09-premier-acces.md))*

**Conteneur** · Une image en cours d'exécution. Comme le plat cuisiné d'après la recette. On peut lancer plusieurs conteneurs depuis la même image. *(voir [06](06-docker.md))*

**Contenu non fiable** · Tout ce qui vient de l'extérieur et que tu n'as pas écrit : mails reçus, offres, pages web. *(voir [20](20-securite-agents.md))*

**Conventional Commits** · Une convention pour les messages de commit : un type (`feat`, `fix`, `docs`, `chore`), deux-points, puis une description courte. *(voir [21](21-git-et-valorisation.md))*

**Credentials** (identifiants n8n) · Les accès enregistrés une fois dans n8n (clé d'API, compte Google, bot Telegram), chiffrés dans la base, puis réutilisés par tous les nœuds. *(voir [11](11-connecter-les-services.md))*

**cron** / **crontab** · Le planificateur de Linux. La crontab est la liste de tes tâches planifiées, avec la même syntaxe en 5 champs que le Schedule de n8n. *(voir [19](19-exploitation.md))*


## D

**Déclencheur** (*trigger*) · Le premier nœud, celui qui démarre le workflow : une heure (Schedule), un nouveau mail (Gmail Trigger), un clic (Manual Trigger), un appel extérieur (Webhook). *(voir [10](10-decouvrir-n8n.md))*

**Dédoublonner** · Retirer les éléments présents plusieurs fois. *(voir [17](17-agent-veille-offres.md))*

**Délivrabilité** · La capacité de tes mails à arriver en boîte de réception plutôt qu'en spam. Envoyer trop, trop vite, la dégrade. *(voir [16](16-agent-envoi-valide.md))*

**Dépôt** (*repository*, « repo ») · Un dossier de projet suivi par Git, avec tout son historique. *(voir [02](02-preparer-son-poste.md))*

**Distribution Linux** · Une version de Linux préparée par un éditeur. **Ubuntu** est la plus répandue sur les serveurs. *(voir [03](03-louer-le-vps.md))*

**DNS** (*Domain Name System*) · L'annuaire d'Internet : il traduit un nom en adresse IP. Ton navigateur lui demande « où est `n8n.patrick-namegni.fr` ? » et le DNS répond « à `203.0.113.42` ». *(voir [07](07-domaine-dns.md))*

**Docker** · Un outil qui fait tourner des logiciels dans des boîtes isolées, les conteneurs. Chaque boîte contient le logiciel et tout ce dont il a besoin, sans rien installer sur le serveur lui-même. *(voir [06](06-docker.md))*

**Docker Compose** · Un outil qui décrit plusieurs conteneurs, leurs volumes et leur réseau dans un seul fichier, `docker-compose.yml`, et les lance d'une commande. *(voir [06](06-docker.md))*

**Docker Desktop** · L'application qui installe Docker sur Windows ou Mac, avec une petite fenêtre pour voir tes conteneurs. *(voir [annexe A](annexe-a-mode-local.md))*

**Domaine d'une adresse** · Ce qui suit le `@` : dans `rh@sfeir.com`, le domaine est `sfeir.com`. *(voir [14](14-agent-boite-reception.md))*

**Données binaires** (*binary data*) · Dans n8n, un fichier (PDF, image) qui voyage avec un item, à côté de son JSON. Il est rangé dans un champ binaire, souvent nommé `data`. *(voir [16](16-agent-envoi-valide.md))*

**Données personnelles** · Toute information liée à une personne identifiable : nom, adresse mail, échanges. Protégées par le **RGPD** en Europe. *(voir [20](20-securite-agents.md))*

**Dump** · Un export complet d'une base de données dans un fichier texte. `pg_dump` le fait pour Postgres. *(voir [19](19-exploitation.md))*


## E

**EBS** · Le disque d'une instance EC2. Sa taille se choisit à la création (8 Go par défaut, trop peu pour nous). *(voir [annexe E](annexe-e-aws.md))*

**EC2** (*Elastic Compute Cloud*) · Le service de serveurs « à la carte » d'AWS. Très souple, mais chaque option (disque, IP, trafic) se règle et se paie à part. *(voir [annexe E](annexe-e-aws.md))*

**Écran de consentement** · La page Google qui te demande d'autoriser l'accès. Tu dois la configurer toi-même dans la console Google Cloud. *(voir [11](11-connecter-les-services.md))*

**ed25519** · Le type de clé moderne recommandé : courte, rapide, très sûre. *(voir [04](04-ssh.md))*

**Elastic IP / Static IP** · Une adresse IP fixe que tu attaches à ton instance. Sans elle, l'IP publique change à chaque arrêt et redémarrage. *(voir [annexe E](annexe-e-aws.md))*

**Empreinte** (*fingerprint*) · Une sorte de carte d'identité du serveur. À la première connexion, SSH te la montre pour que tu confirmes que c'est bien ton serveur. *(voir [04](04-ssh.md))*

**Enregistrement A** · Une ligne de la zone DNS qui dit « ce nom pointe vers cette adresse IPv4 ». *(voir [07](07-domaine-dns.md))*

**Entrée / sortie** · Ce qui entre dans l'agent (un mail, une liste d'offres) et ce qui en sort (une ligne mise à jour, un message). *(voir [13](13-canevas-agent.md))*

**`enum`** · Dans un JSON Schema, la liste fermée des valeurs autorisées pour un champ. *(voir [14](14-agent-boite-reception.md))*

**Épingler des données** (*pin data*) · Figer la sortie d'un nœud pour tester la suite sans le relancer. Pratique pour ne pas rappeler Claude ou Gmail à chaque essai. *(voir [10](10-decouvrir-n8n.md))*

**Error Trigger** · Un déclencheur n8n qui démarre un workflow quand un **autre** workflow échoue. *(voir [19](19-exploitation.md))*

**Étiquette Gmail** (*label*) · Un marqueur posé sur un mail, comme un dossier. Ici, `agent-traite` signale « déjà traité ». *(voir [14](14-agent-boite-reception.md))*

**Execute Once** · Un réglage de nœud : il ne s'exécute qu'une fois, même s'il reçoit plusieurs items. *(voir [14](14-agent-boite-reception.md))*

**Exécution** · Un passage complet du workflow. Chacune est enregistrée et consultable, avec les données de chaque nœud. *(voir [10](10-decouvrir-n8n.md))*

**Exécution en attente** (*waiting*) · Une exécution en pause, qui reprendra quand tu répondras. Tu la vois dans **Executions** avec le statut *Waiting*. *(voir [15](15-agent-relances.md))*

**Exfiltration** · Faire sortir des données vers quelqu'un qui ne devrait pas les avoir. *(voir [20](20-securite-agents.md))*

**Exploitation** (*ops*) · Tout ce qui fait qu'un système continue de marcher après son installation : sauvegardes, mises à jour, surveillance. *(voir [19](19-exploitation.md))*

**Expression** · Un petit morceau de code entre `{{ }}` qui va chercher une valeur dans les données. `{{ $json.entreprise }}` = « le champ entreprise de l'item en cours ». *(voir [10](10-decouvrir-n8n.md))*

**Expression cron** · Une façon d'écrire un horaire répétitif en 5 champs : minute, heure, jour du mois, mois, jour de la semaine. `0 8 * * 1-5` = 8 h 00, du lundi au vendredi. *(voir [12](12-premier-agent.md))*


## F

**fail2ban** · Un gardien qui lit les journaux de connexion et bannit temporairement les adresses IP qui ratent trop de tentatives. *(voir [05](05-securiser.md))*

**Fichier `.env`** · Le fichier où l'on écrit ces variables, notamment les secrets. Docker Compose le lit automatiquement. Il n'est **jamais** versionné dans Git. *(voir [08](08-deployer-la-stack.md))*

**Fichier de configuration** · Un fichier texte qui règle le comportement d'un logiciel. Sous Linux, ils sont presque tous dans `/etc`. *(voir [05](05-securiser.md))*

**Fichier de surcharge** (*override*) · Un second fichier Compose qui modifie le premier sans le recopier. Ici, `docker-compose.local.yml` change seulement ce qui diffère en local. *(voir [annexe A](annexe-a-mode-local.md))*

**Filter** (nœud) · Un nœud qui ne laisse passer que les items qui respectent une condition, et jette les autres. *(voir [10](10-decouvrir-n8n.md), [16](16-agent-envoi-valide.md), [17](17-agent-veille-offres.md))*

**France Travail** (API) · L'interface officielle des offres d'emploi publiées sur France Travail, gratuite après inscription sur francetravail.io. *(voir [11](11-connecter-les-services.md), [17](17-agent-veille-offres.md))*

**Fusion** (*merge*) · L'intégration des changements d'une branche dans une autre. *(voir [21](21-git-et-valorisation.md))*


## G

**Garde-fou** · Une limite qui empêche une erreur de faire des dégâts : un plafond d'envois, une validation humaine, une limite de dépense. *(voir [13](13-canevas-agent.md))*

**Gestionnaire de mots de passe** · Un coffre-fort chiffré pour tes mots de passe et secrets. Tu ne retiens qu'un seul mot de passe : celui du coffre. *(voir [02](02-preparer-son-poste.md))*

**Git** · Un logiciel qui enregistre l'historique de tes fichiers : qui a changé quoi, quand, et pourquoi. On peut revenir en arrière à tout moment. *(voir [02](02-preparer-son-poste.md))*

**GitHub** · Un site qui héberge des dépôts Git en ligne, pour les sauvegarder, les partager et les montrer. *(voir [02](02-preparer-son-poste.md))*

**GitHub Actions** · Le service de GitHub qui exécute la CI, décrite dans `.github/workflows/ci.yml`. *(voir [21](21-git-et-valorisation.md))*

**Gmail Trigger** · Un déclencheur qui vérifie la boîte Gmail à intervalle régulier et démarre le workflow pour chaque nouveau mail. *(voir [14](14-agent-boite-reception.md))*

**Google Sheets** · Le tableur en ligne de Google. Il sert de suivi des candidatures : une ligne par candidature, que les agents lisent et mettent à jour. *(voir [11](11-connecter-les-services.md), [14](14-agent-boite-reception.md))*

**Grille de notation** · Les critères et leurs points, pour que la note soit cohérente d'une offre à l'autre. *(voir [17](17-agent-veille-offres.md))*

**Groupe `sudo`** · La liste des utilisateurs autorisés à utiliser `sudo`. *(voir [05](05-securiser.md))*


## H

**Haiku, Sonnet** · Deux modèles de Claude. Haiku est rapide et peu cher : idéal pour classer ou noter. Sonnet écrit mieux : réservé à la rédaction. *(voir [12](12-premier-agent.md), [14](14-agent-boite-reception.md), [15](15-agent-relances.md))*

**Healthcheck** · Un test régulier qui vérifie qu'un service répond vraiment, pas seulement qu'il est lancé. *(voir [08](08-deployer-la-stack.md))*

**Hébergeur** · L'entreprise qui loue des serveurs (LWS, Hetzner, OVHcloud…). Elle s'occupe du matériel, de l'électricité et du réseau. *(voir [03](03-louer-le-vps.md))*

**Hors site** (*off-site*) · Une copie conservée ailleurs que sur le serveur qu'elle protège. *(voir [19](19-exploitation.md))*

**HTTP Request** (nœud) · Le nœud n8n qui appelle n'importe quelle API, même sans nœud dédié. On l'utilise pour Apify et France Travail. *(voir [11](11-connecter-les-services.md), [17](17-agent-veille-offres.md))*

**HTTPS** · Le web chiffré. Le cadenas du navigateur garantit que personne ne lit ni ne modifie ce qui circule entre toi et le serveur. *(voir [07](07-domaine-dns.md))*

**Humain dans la boucle** · Un principe de conception : l'agent prépare, une personne valide, puis l'agent exécute. Toute action irréversible (envoyer un mail) passe par ta validation. *(voir [01](01-comprendre.md))*


## I

**Idempotence** · Qualité d'un agent qui, relancé deux fois sur la même donnée, ne fait pas deux fois l'action. Exemple : ne pas classer deux fois le même mail. *(voir [13](13-canevas-agent.md))*

**Identifiant** (*credential*) · Dans n8n, une connexion enregistrée à un service (clé, jeton…). Tu la crées une fois, puis tous tes nœuds peuvent l'utiliser. Elle est chiffrée avec ta `N8N_ENCRYPTION_KEY`. *(voir [11](11-connecter-les-services.md))*

**IF** (nœud) · Un nœud qui sépare les items en deux sorties, *true* et *false*, selon une condition. *(voir [10](10-decouvrir-n8n.md), [14](14-agent-boite-reception.md))*

**Image** · Le modèle figé d'un logiciel prêt à tourner, par exemple `postgres:17`. Comme une recette de cuisine : elle ne fait rien seule. *(voir [06](06-docker.md))*

**Image** (d'un VPS) · Le système installé d'office sur le serveur à sa création. *(voir [03](03-louer-le-vps.md))*

**Indicateur** (KPI) · Un chiffre suivi dans le temps pour savoir si une action marche. Ici, le taux de réponse. *(voir [18](18-agent-rapport.md))*

**Injection de prompt** · Une attaque où un texte extérieur (un mail, une page web, une offre) contient des instructions destinées à l'IA, pour lui faire faire autre chose que sa tâche. *(voir [20](20-securite-agents.md))*

**Instance** · Le nom qu'AWS donne à un serveur. « Lancer une instance » = créer un serveur. *(voir [annexe E](annexe-e-aws.md))*

**IPv4 / IPv6** · Deux formats d'adresse IP. IPv4 : quatre nombres séparés par des points. IPv6 : plus long, avec des `:`. On utilisera l'IPv4. *(voir [03](03-louer-le-vps.md))*

**Item** · Une unité de donnée qui passe d'un nœud à l'autre. Si Gmail trouve 3 mails, il produit 3 items, et le nœud suivant s'exécute **une fois par item**. *(voir [10](10-decouvrir-n8n.md))*


## J

**Jeton** (*token*) · Même idée qu'une clé d'API, souvent à durée limitée. *(voir [11](11-connecter-les-services.md))*

**JSON** · Le format des données dans n8n : des paires `"clé": valeur` entre accolades. Exemple : `{"entreprise": "SFEIR", "score": 84}`. *(voir [10](10-decouvrir-n8n.md))*

**JSON Schema** · Une description du JSON attendu : quels champs, de quel type, quelles valeurs permises. *(voir [13](13-canevas-agent.md))*

**Jugement** · Une décision qui demande de comprendre un texte : « ce mail est-il un refus ? ». Elle va à Claude. *(voir [13](13-canevas-agent.md))*


## K

**Key pair** (paire de clés) · La paire de clés SSH qu'AWS associe à l'instance. AWS garde la clé publique sur le serveur ; toi, tu gardes la clé privée (un fichier `.pem`). *(voir [annexe E](annexe-e-aws.md))*


## L

**Let's Encrypt** · Une autorité qui délivre gratuitement des certificats, valables 90 jours. Caddy les demande et les renouvelle tout seul. *(voir [07](07-domaine-dns.md))*

**Lightsail** · La version simplifiée d'EC2 : un prix fixe par mois qui inclut disque, IP et trafic. C'est l'équivalent AWS d'un VPS classique. *(voir [annexe E](annexe-e-aws.md))*

**Limit** · Un nœud qui ne laisse passer que les N premiers items. *(voir [16](16-agent-envoi-valide.md))*

**Linux** · Une famille de systèmes d'exploitation gratuits, comme Windows ou macOS, qui fait tourner l'immense majorité des serveurs. *(voir [01](01-comprendre.md), [03](03-louer-le-vps.md))*

**LLM** (*Large Language Model*) · Grand modèle de langage : une IA entraînée sur du texte, comme Claude. *(voir [12](12-premier-agent.md))*

**localhost** · Le nom qui veut dire « cet ordinateur-ci ». `http://localhost:5678` ouvre le n8n qui tourne sur ta propre machine, et personne d'autre ne peut l'ouvrir. *(voir [annexe A](annexe-a-mode-local.md))*

**Logs** (journaux) · Les messages qu'écrit un logiciel pendant qu'il tourne. Le premier endroit où chercher quand quelque chose ne marche pas. *(voir [06](06-docker.md))*

**LTS** (*Long Term Support*) · Une version maintenue longtemps (5 ans pour Ubuntu). 24.04 veut dire avril 2024. On prend toujours une LTS pour un serveur. *(voir [03](03-louer-le-vps.md))*

**Luxon / `DateTime`** · La bibliothèque de dates disponible dans les nœuds Code et les expressions de n8n. `DateTime.now()` = maintenant. *(voir [15](15-agent-relances.md))*


## M

**Merge** (nœud) · Un nœud qui réunit deux flux d'items en un seul, par exemple les offres d'Apify et celles de France Travail. *(voir [17](17-agent-veille-offres.md))*

**Message d'erreur** · Le texte qu'affiche le programme quand il échoue. Il contient presque toujours la réponse, à condition de le lire jusqu'au bout. *(voir [annexe B](annexe-b-depannage.md))*

**Message système** · La partie du prompt qui fixe le rôle et les règles permanentes de Claude (« Tu es un assistant de recherche d'emploi… »). *(voir [12](12-premier-agent.md))*

**Message utilisateur** · La partie du prompt qui contient la demande et les données du moment. *(voir [12](12-premier-agent.md))*

**Mises à jour de sécurité** · Des correctifs publiés quand une faille est découverte. **unattended-upgrades** les installe automatiquement. *(voir [05](05-securiser.md))*

**Modèle** · Une version de Claude. **Haiku** : rapide et économique. **Sonnet** : meilleur en rédaction. **Opus** : le plus puissant, le plus cher. *(voir [11](11-connecter-les-services.md))*

**Moindre privilège** · Ne donner à chaque composant que les droits strictement nécessaires à sa tâche. *(voir [20](20-securite-agents.md))*


## N

**n8n** · Un logiciel d'automatisation : on y dessine des chaînes d'étapes (les workflows) qui se déclenchent seules. Prononcé « n-eight-n », pour *nodemation*. *(voir [01](01-comprendre.md))*

**`nano`** · Un éditeur de texte simple qui fonctionne dans le terminal. Ctrl + O enregistre, Entrée confirme, Ctrl + X quitte. *(voir [05](05-securiser.md))*

**Nom de domaine** · Une adresse lisible, comme `patrick-namegni.fr`, que tu loues à l'année auprès d'un registraire. *(voir [07](07-domaine-dns.md))*

**Normaliser** · Mettre des données de sources différentes au même format, avec les mêmes noms de champs. *(voir [17](17-agent-veille-offres.md))*

**Notes de version** (*release notes*) · La liste des changements d'une nouvelle version, dont les *breaking changes* (changements qui peuvent casser l'existant). *(voir [19](19-exploitation.md))*

**Nœud** (*node*) · Une étape du workflow : lire Gmail, appeler Claude, filtrer, envoyer un message… *(voir [10](10-decouvrir-n8n.md))*


## O

**OAuth2** · Une façon de donner à une application un accès limité à ton compte (Gmail, Sheets) **sans lui donner ton mot de passe**. Google te montre une page « Autoriser n8n à lire tes mails ? » ; si tu acceptes, il remet un jeton à n8n. Tu peux le révoquer à tout moment. *(voir [11](11-connecter-les-services.md))*

**`openssl rand -hex 32`** · Une commande qui génère 32 octets aléatoires, écrits en hexadécimal (64 caractères de 0 à 9 et de a à f). Parfait pour un mot de passe ou une clé. *(voir [08](08-deployer-la-stack.md))*


## P

**Paire de clés SSH** · Deux fichiers liés mathématiquement. La **clé publique** se pose sur le serveur, comme une serrure. La **clé privée** reste sur ton PC, c'est la clé qui ouvre cette serrure. Ce que l'une ferme, seule l'autre peut l'ouvrir. *(voir [04](04-ssh.md))*

**Paquet** · Un logiciel prêt à installer sous Linux. `apt` est le gestionnaire de paquets d'Ubuntu : il installe, met à jour et supprime les logiciels. *(voir [05](05-securiser.md))*

**Paramètres de requête** (*query parameters*) · Les filtres ajoutés à une adresse après `?`, par exemple `?motsCles=java&distance=30`. *(voir [17](17-agent-veille-offres.md))*

**Pare-feu** (*firewall*) · Le portier qui décide quelles portes sont ouvertes. Sur Ubuntu, on utilise **ufw** (*Uncomplicated Firewall*). *(voir [05](05-securiser.md))*

**Phrase de passe** (*passphrase*) · Un mot de passe qui protège ta clé privée. Si on te vole ton PC, la clé reste inutilisable sans elle. *(voir [04](04-ssh.md))*

**Pièce jointe** · Un fichier envoyé avec un mail. Le nœud Gmail la prend dans un champ binaire. *(voir [16](16-agent-envoi-valide.md))*

**Polling** (interrogation) · Vérifier régulièrement s'il y a du nouveau. Le Gmail Trigger interroge Gmail toutes les X minutes. *(voir [14](14-agent-boite-reception.md))*

**Port** · Un numéro de porte sur le serveur. Chaque service écoute derrière sa porte : 22 pour SSH, 80 pour le web (HTTP), 443 pour le web chiffré (HTTPS). *(voir [05](05-securiser.md))*

**Port publié** · Un pont entre un port du serveur et un port du conteneur : `8080:80` veut dire « ce qui arrive sur le port 8080 du serveur va au port 80 du conteneur ». *(voir [06](06-docker.md))*

**PostgreSQL** (Postgres) · La base de données de notre stack. n8n y range workflows, identifiants chiffrés et historique des exécutions. *(voir [08](08-deployer-la-stack.md))*

**Prompt** · La consigne écrite que tu donnes à Claude. Sa qualité fait la qualité de la réponse. *(voir [12](12-premier-agent.md))*

**Prompt** (invite) · Le texte affiché avant le curseur, par exemple `root@agent-emploi:~#`. Il te dit qui tu es et où tu es. *(voir [04](04-ssh.md))*

**Propagation** · Le temps que la nouvelle correspondance soit connue partout. Souvent quelques minutes, parfois quelques heures. *(voir [07](07-domaine-dns.md))*

**Publier** (*publish*) · Mettre un workflow en production : il se déclenche alors tout seul. Avant, il ne tourne que quand tu cliques sur « Execute ». (Avant n8n 2.0, on disait « activer ».) *(voir [10](10-decouvrir-n8n.md))*

**Pull request** (PR) · Une demande de fusion d'une branche dans `main`, sur GitHub. On y voit les changements, la CI s'y exécute, et on valide avant de fusionner. *(voir [21](21-git-et-valorisation.md))*


## R

**RAM** (mémoire vive) · La mémoire de travail. Les logiciels en cours d'exécution y vivent. n8n, Postgres et Caddy ensemble utilisent environ 1 à 1,5 Go ; on prend 4 Go pour être à l'aise. *(voir [03](03-louer-le-vps.md))*

**README** · La page d'accueil du dépôt : ce que fait le projet, comment l'installer. C'est ce qu'un recruteur lit en premier. *(voir [21](21-git-et-valorisation.md))*

**Région** · La ville où se trouve physiquement ton serveur. Choisis `eu-west-3` (Paris). *(voir [annexe E](annexe-e-aws.md))*

**Registraire** (*registrar*) · L'entreprise où l'on achète un nom de domaine (LWS, OVHcloud, Gandi…). *(voir [07](07-domaine-dns.md))*

**Registre** · Le magasin d'images en ligne. Le principal est Docker Hub. `docker pull` y télécharge une image. *(voir [06](06-docker.md))*

**Règle** (déterministe) · Une décision qu'on peut écrire sans ambiguïté : « si la date d'envoi a plus de 7 jours ». Une règle donne toujours le même résultat. Elle va dans un nœud IF, Filter ou Code. *(voir [13](13-canevas-agent.md))*

**Reproduire** · Refaire exprès l'action qui échoue, pour vérifier une hypothèse ou une correction. *(voir [annexe B](annexe-b-depannage.md))*

**Requête HTTP** · Un message envoyé à une adresse web : une **méthode** (`GET` pour lire, `POST` pour envoyer des données), une **adresse**, des **en-têtes** (dont l'authentification) et parfois un **corps** en JSON. *(voir [17](17-agent-veille-offres.md))*

**Réseau Docker** · Un réseau privé entre conteneurs. Ils s'y joignent par leur nom, comme `postgres` ou `n8n`. *(voir [06](06-docker.md))*

**Restauration** · Remettre en place une sauvegarde. Une sauvegarde jamais restaurée n'est qu'un espoir. *(voir [19](19-exploitation.md))*

**Retour arrière** (*rollback*) · Revenir à la version précédente quand une mise à jour pose problème. *(voir [19](19-exploitation.md))*

**Reverse proxy** · Un intermédiaire placé devant une application : il reçoit les visiteurs, gère le HTTPS, et transmet les requêtes à l'application cachée derrière. **Caddy** joue ce rôle. *(voir [08](08-deployer-la-stack.md))*

**Root** · Le compte administrateur de Linux, qui a tous les droits. *(voir [03](03-louer-le-vps.md))*

**Rotation d'un secret** · Remplacer une clé ou un mot de passe par un nouveau, et révoquer l'ancien. *(voir [20](20-securite-agents.md))*


## S

**Sauvegarde** (*backup*) · Une copie des données, faite régulièrement, pour les récupérer après une panne ou une erreur. *(voir [19](19-exploitation.md))*

**Schedule Trigger** · Un déclencheur qui lance le workflow à heure fixe, décrite par une expression cron. *(voir [12](12-premier-agent.md))*

**Scope** (portée) · La liste des droits demandés, par exemple « lire les offres ». *(voir [11](11-connecter-les-services.md))*

**Scraper** · Un programme qui lit des pages web pour en extraire des données. Apify en héberge des milliers, appelés *actors*. *(voir [17](17-agent-veille-offres.md))*

**Script** · Un fichier qui contient une suite de commandes à lancer d'un coup, comme `scripts/backup.sh`. *(voir [19](19-exploitation.md))*

**Secret** · Toute information qui donne un accès : mot de passe, clé d'API, jeton. Un secret ne s'écrit jamais dans le code ni dans un message. *(voir [02](02-preparer-son-poste.md))*

**Security Group** (groupe de sécurité) · Le pare-feu d'AWS, **devant** le serveur. Il bloque tout ce que tu n'as pas autorisé, avant même que ufw soit consulté. *(voir [annexe E](annexe-e-aws.md))*

**Send and Wait for Response** · Une opération des nœuds Telegram et Gmail : envoyer un message, puis **mettre le workflow en pause** jusqu'à ta réponse. C'est l'humain dans la boucle. *(voir [15](15-agent-relances.md))*

**Serveur** · Un ordinateur qui reste allumé en permanence pour rendre un service à d'autres (afficher un site, exécuter des tâches). *(voir [01](01-comprendre.md))*

**Service** (ou démon) · Un programme qui tourne en arrière-plan en permanence, comme le serveur SSH. `systemctl` sert à les démarrer, arrêter, redémarrer. *(voir [05](05-securiser.md))*

**Sortie structurée** · Imposer à Claude une réponse en JSON, avec des champs et des valeurs prévus d'avance, pour que n8n puisse s'en servir sans ambiguïté. *(voir [13](13-canevas-agent.md))*

**Sous-domaine** · Une adresse dérivée d'un domaine : `n8n.patrick-namegni.fr` est un sous-domaine de `patrick-namegni.fr`. Tu peux en créer autant que tu veux, gratuitement. *(voir [07](07-domaine-dns.md))*

**Sous-nœud** · Un nœud branché **sous** un autre pour lui fournir une capacité : le modèle (Anthropic Chat Model), le format de sortie (Structured Output Parser)… *(voir [12](12-premier-agent.md))*

**SSD NVMe** · Le disque de stockage, rapide. 40 Go suffisent largement ici. *(voir [03](03-louer-le-vps.md))*

**SSH** (*Secure Shell*) · Le moyen de piloter un serveur à distance : tu tapes des commandes sur ton PC, elles s'exécutent sur le serveur. Tout le trafic est chiffré. *(voir [04](04-ssh.md))*

**sslip.io** · Un service gratuit qui fait pointer automatiquement `n8n.203-0-113-42.sslip.io` vers l'IP `203.0.113.42`. Pratique pour tester sans acheter de domaine. *(voir [07](07-domaine-dns.md))*

**Stack** · L'ensemble des logiciels qui fonctionnent ensemble pour rendre un service. Ici : Caddy + n8n + Postgres. *(voir [08](08-deployer-la-stack.md))*

**`sudo`** (*superuser do*) · Placé devant une commande, il l'exécute avec les droits d'administrateur, après avoir demandé ton mot de passe. On travaille en utilisateur normal et on ne « monte » en administrateur que quand il le faut. *(voir [05](05-securiser.md))*

**Supervision** (*monitoring*) · Un service extérieur qui vérifie régulièrement que ton serveur répond, et te prévient sinon. *(voir [19](19-exploitation.md))*

**Surface d'attaque** · L'ensemble des points par lesquels un attaquant peut tenter d'entrer. *(voir [20](20-securite-agents.md))*

**Swap** · Un espace du disque utilisé comme mémoire de secours quand la RAM est pleine. Plus lent, mais évite qu'un programme soit tué faute de mémoire. *(voir [05](05-securiser.md))*

**Switch** (nœud) · Comme IF, mais avec autant de sorties que de cas : une par catégorie de mail, par exemple. *(voir [10](10-decouvrir-n8n.md), [14](14-agent-boite-reception.md))*

**Symptôme** · Ce que tu vois : une page qui ne s'ouvre pas, un message rouge. Ce n'est pas encore la cause. *(voir [annexe B](annexe-b-depannage.md))*


## T

**Tag** · La version d'une image, après les deux-points : dans `postgres:17`, le tag est `17`. *(voir [06](06-docker.md))*

**Taux de réponse** · Réponses reçues ÷ candidatures envoyées. Un taux de 15 % veut dire environ 1 réponse pour 7 envois. *(voir [18](18-agent-rapport.md))*

**Telegram** · Une messagerie gratuite. Ton bot t'y envoie les notifications et les demandes de validation avec boutons. *(voir [11](11-connecter-les-services.md), [12](12-premier-agent.md))*

**Température** · Un réglage du modèle : à 0, ses réponses sont stables et prévisibles ; vers 1, plus variées. Pour classer : 0. Pour rédiger : environ 0,7. *(voir [15](15-agent-relances.md))*

**Terminal** (ou console, invite de commandes) · Une fenêtre où l'on tape des commandes au lieu de cliquer. Sous Windows : PowerShell. Sous Mac : l'application Terminal. *(voir [02](02-preparer-son-poste.md))*

**Thread / fil** · Une conversation Gmail : le mail d'origine et toutes ses réponses. Son identifiant, `threadId`, permet de répondre dans le même fil. *(voir [14](14-agent-boite-reception.md))*

**Token** (pour un modèle d'IA) · À ne pas confondre avec un jeton d'accès : c'est aussi l'unité de mesure du texte pour Claude, environ trois quarts de mot. L'API Claude est facturée au nombre de tokens lus et écrits. *(voir [11](11-connecter-les-services.md))*

**TTL** (*Time To Live*) · Combien de temps les annuaires gardent une réponse en mémoire avant de la redemander. *(voir [07](07-domaine-dns.md))*

**Tunnel** · Un passage qui rend accessible sur Internet un service de ton PC, sans ouvrir de port sur ta box. Cloudflare en fournit un gratuit. *(voir [annexe A](annexe-a-mode-local.md))*


## U

**Ubuntu** · La distribution Linux choisie pour le serveur, en version 24.04 LTS. *(voir [03](03-louer-le-vps.md))*

**URL de redirection** (*redirect URI*) · L'adresse de n8n où Google renvoie le jeton après ton accord. Elle doit être déclarée à l'identique chez Google. *(voir [11](11-connecter-les-services.md))*


## V

**Variable d'environnement** · Un réglage donné à un programme au moment de son lancement, sous la forme `NOM=valeur`. *(voir [08](08-deployer-la-stack.md))*

**vCPU** (processeur virtuel) · La part de processeur réservée à ton VPS. 2 vCPU = ton serveur peut faire deux calculs vraiment en parallèle. *(voir [03](03-louer-le-vps.md))*

**Volume** · Un espace de stockage géré par Docker, qui survit à la suppression du conteneur. Un conteneur est jetable, ses données ne doivent pas l'être : elles vont dans un volume. *(voir [06](06-docker.md))*

**VPS** (*Virtual Private Server*, serveur privé virtuel) · Un serveur que tu loues chez un hébergeur. Il est « virtuel » parce que plusieurs VPS se partagent la même machine physique, mais chacun a sa part réservée (processeur, mémoire, disque) et son propre système. Pour toi, il se comporte comme un ordinateur Linux à distance dont tu es le seul maître. *(voir [01](01-comprendre.md))*


## W

**Webhook** · L'inverse d'un appel d'API : c'est une adresse web chez toi que **les autres** appellent pour te prévenir d'un événement. Comme une sonnette : tu n'as pas besoin de regarder par la fenêtre, on sonne quand quelqu'un arrive. *(voir [01](01-comprendre.md))*

**Workflow** · Une chaîne de nœuds reliés par des flèches. Chaque agent est un workflow. *(voir [10](10-decouvrir-n8n.md))*


## Y

**YAML** · Le format du fichier Compose : des paires `clé: valeur`, organisées par **indentation** (les espaces en début de ligne). Une indentation fausse = un fichier invalide. *(voir [06](06-docker.md))*


## Z

**Zone DNS** · La page de réglages de ton domaine, chez le registraire, où tu écris les correspondances nom → adresse. *(voir [07](07-domaine-dns.md))*

