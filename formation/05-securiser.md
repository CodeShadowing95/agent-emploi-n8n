# 05 · Sécuriser le serveur

**Objectif :** un serveur à jour, où seul l'utilisateur `patrick` peut se connecter, avec sa clé, et où seuls trois ports sont ouverts.

**Durée :** 1 heure.

> **Serveur AWS :** commence par `sudo -i` pour devenir root, et lis l'[annexe E, étape 5](annexe-e-aws.md#5-sécuriser-chapitre-05-avec-deux-différences) : deux commandes changent.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Paquet** | Un logiciel prêt à installer sous Linux. `apt` est le gestionnaire de paquets d'Ubuntu : il installe, met à jour et supprime les logiciels. |
| **`sudo`** (*superuser do*) | Placé devant une commande, il l'exécute avec les droits d'administrateur, après avoir demandé ton mot de passe. On travaille en utilisateur normal et on ne « monte » en administrateur que quand il le faut. |
| **Groupe `sudo`** | La liste des utilisateurs autorisés à utiliser `sudo`. |
| **Service** (ou démon) | Un programme qui tourne en arrière-plan en permanence, comme le serveur SSH. `systemctl` sert à les démarrer, arrêter, redémarrer. |
| **Fichier de configuration** | Un fichier texte qui règle le comportement d'un logiciel. Sous Linux, ils sont presque tous dans `/etc`. |
| **Port** | Un numéro de porte sur le serveur. Chaque service écoute derrière sa porte : 22 pour SSH, 80 pour le web (HTTP), 443 pour le web chiffré (HTTPS). |
| **Pare-feu** (*firewall*) | Le portier qui décide quelles portes sont ouvertes. Sur Ubuntu, on utilise **ufw** (*Uncomplicated Firewall*). |
| **fail2ban** | Un gardien qui lit les journaux de connexion et bannit temporairement les adresses IP qui ratent trop de tentatives. |
| **Mises à jour de sécurité** | Des correctifs publiés quand une faille est découverte. **unattended-upgrades** les installe automatiquement. |
| **`nano`** | Un éditeur de texte simple qui fonctionne dans le terminal. Ctrl + O enregistre, Entrée confirme, Ctrl + X quitte. |
| **Swap** | Un espace du disque utilisé comme mémoire de secours quand la RAM est pleine. Plus lent, mais évite qu'un programme soit tué faute de mémoire. |

## Pourquoi sécuriser avant d'installer

Un serveur neuf reçoit des tentatives de connexion automatiques dans l'heure qui suit sa mise en ligne. On ferme donc d'abord les portes, puis on installe. Chaque mesure a un rôle précis :

| Mesure | Ce qu'elle empêche |
|---|---|
| Utilisateur personnel + `sudo` | Qu'une faute de frappe en root casse tout ; qu'un attaquant vise le compte `root`, connu de tous |
| Connexion par clé seulement | Qu'on devine ton mot de passe |
| Pare-feu | Qu'un service oublié soit joignable depuis Internet |
| fail2ban | Les attaques répétées sur SSH |
| Mises à jour automatiques | Qu'une faille connue reste ouverte des semaines |

## Pas à pas

### 1. Mettre le système à jour

```bash
[PC] $ ssh agent
[VPS] # apt update
[VPS] # apt upgrade -y
```

- `apt update` : télécharge la liste à jour des paquets disponibles (n'installe rien) ;
- `apt upgrade -y` : installe les nouvelles versions ; `-y` répond « oui » d'avance.

Si un écran violet demande quels services redémarrer, garde la sélection et valide avec Entrée.

Puis règle le fuseau horaire, pour que les heures des journaux soient les tiennes :

```bash
[VPS] # timedatectl set-timezone Europe/Paris
[VPS] # date
```

### 2. Créer ton utilisateur

```bash
[VPS] # adduser patrick
```

Choisis un mot de passe (range-le dans ton gestionnaire : il servira pour `sudo`). Pour les questions « Full Name », « Room Number »…, appuie simplement sur Entrée.

```bash
[VPS] # usermod -aG sudo patrick
```

`usermod -aG sudo patrick` : ajoute (`-a`, *append*) l'utilisateur `patrick` au groupe (`-G`) `sudo`.

Donne-lui ta clé SSH, en copiant celle de root :

```bash
[VPS] # rsync --archive --chown=patrick:patrick ~/.ssh /home/patrick
```

Cette commande copie le dossier `.ssh` de root dans le dossier de `patrick`, en lui donnant la propriété des fichiers.

### 3. Tester ton utilisateur **avant** de fermer root

Ouvre un **second terminal** sur ton PC, sans fermer le premier :

```bash
[PC] $ ssh patrick@TON_IP
[VPS] $ sudo whoami
```

`sudo whoami` doit demander ton mot de passe puis répondre `root`. Le prompt finit maintenant par `$` : tu es un utilisateur normal. Si ça marche, tu peux continuer. Sinon, ne va pas plus loin et regarde « Si ça bloque ».

### 4. Interdire root et les mots de passe en SSH

Toujours dans le terminal où tu es root :

```bash
[VPS] # nano /etc/ssh/sshd_config.d/01-durcissement.conf
```

Écris ces deux lignes, puis Ctrl + O, Entrée, Ctrl + X :

```
PermitRootLogin no
PasswordAuthentication no
```

**Pourquoi « 01- » ?** SSH lit les fichiers de ce dossier par ordre alphabétique et **garde la première valeur trouvée** pour chaque réglage. Certains hébergeurs y déposent un fichier `50-cloud-init.conf` qui autorise les mots de passe. Avec `01-`, ton fichier passe en premier et gagne.

Vérifie la configuration réellement appliquée, puis redémarre SSH :

```bash
[VPS] # sshd -t
[VPS] # sshd -T | grep -E "permitrootlogin|passwordauthentication"
[VPS] # systemctl restart ssh
```

- `sshd -t` teste la configuration : s'il n'affiche rien, elle est valide ;
- `sshd -T` affiche les valeurs finales : tu dois lire `permitrootlogin no` et `passwordauthentication no`.

**Ne ferme aucun terminal** et teste depuis un troisième :

```bash
[PC] $ ssh patrick@TON_IP     → doit fonctionner
[PC] $ ssh root@TON_IP        → doit afficher « Permission denied »
```

Mets ensuite à jour ton raccourci dans `~/.ssh/config` sur ton PC : remplace `User root` par `User patrick`. À partir d'ici, tu te connectes toujours avec `ssh agent`, en tant que `patrick`.

### 5. Activer le pare-feu

```bash
[VPS] $ sudo ufw allow OpenSSH
[VPS] $ sudo ufw allow 80/tcp
[VPS] $ sudo ufw allow 443/tcp
[VPS] $ sudo ufw enable
[VPS] $ sudo ufw status verbose
```

**L'ordre compte** : on autorise SSH **avant** d'activer le pare-feu, sinon on se coupe soi-même la porte. `ufw enable` prévient que la connexion peut être interrompue : réponds `y`.

Pourquoi ces trois ports ? 22 (OpenSSH) pour toi, 80 et 443 pour Caddy, qui servira n8n en HTTPS. Le port 80 reste ouvert parce que Let's Encrypt l'utilise pour vérifier ton domaine, et parce que Caddy y redirige les visiteurs vers HTTPS.

### 6. Installer fail2ban et les mises à jour automatiques

```bash
[VPS] $ sudo apt install -y fail2ban unattended-upgrades
[VPS] $ sudo systemctl enable --now fail2ban
[VPS] $ sudo dpkg-reconfigure -plow unattended-upgrades
```

À la dernière commande, réponds **Yes** : les correctifs de sécurité s'installeront chaque jour, seuls.

Sur Ubuntu, fail2ban protège SSH dès son installation. Vérifie :

```bash
[VPS] $ sudo fail2ban-client status sshd
```

### 7. Ajouter un swap de 2 Go (recommandé)

```bash
[VPS] $ sudo fallocate -l 2G /swapfile
[VPS] $ sudo chmod 600 /swapfile
[VPS] $ sudo mkswap /swapfile
[VPS] $ sudo swapon /swapfile
[VPS] $ echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
[VPS] $ free -h
```

Les cinq premières lignes créent un fichier de 2 Go, le protègent, le formatent en swap, l'activent, puis l'inscrivent dans `/etc/fstab` pour qu'il soit réactivé à chaque démarrage. `free -h` doit afficher une ligne `Swap: 2.0Gi`.

## Vérifie

- [ ] `ssh agent` te connecte en `patrick`, sans mot de passe.
- [ ] `ssh root@TON_IP` est refusé.
- [ ] `sudo ufw status` liste OpenSSH, 80/tcp et 443/tcp, et rien d'autre.
- [ ] `sudo fail2ban-client status sshd` répond sans erreur.
- [ ] `free -h` montre 2 Go de swap.

Note dans `docs/journal.md` ce que tu as fait et ce qui t'a surpris.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| Tu ne peux plus te connecter du tout | Une erreur dans la configuration SSH ou le pare-feu | Ouvre la **console web** de l'hébergeur, connecte-toi en root avec le mot de passe, corrige le fichier ou lance `ufw disable` |
| `patrick is not in the sudoers file` | L'ajout au groupe a échoué | En root : `usermod -aG sudo patrick`, puis déconnecte et reconnecte `patrick` |
| `sshd -T` affiche encore `passwordauthentication yes` | Un autre fichier passe avant le tien | `ls /etc/ssh/sshd_config.d/` et vérifie que ton fichier est le premier par ordre alphabétique |
| `fail2ban-client` : erreur de connexion | Le service n'a pas démarré | `sudo systemctl status fail2ban` et lis les dernières lignes |

## Exercice : refais-le seul

1. Crée un utilisateur `test`, ajoute-le au groupe `sudo`, connecte-toi avec lui, puis supprime-le avec `sudo deluser --remove-home test`.
2. Ouvre le port 8080 dans ufw, constate-le avec `ufw status`, puis referme-le avec `sudo ufw delete allow 8080`.
3. Sans regarder, explique pourquoi on autorise OpenSSH avant `ufw enable`.
