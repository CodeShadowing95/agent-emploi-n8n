# 07 · Domaine et DNS

**Objectif :** une adresse du type `n8n.patrick-namegni.fr` (ou `n8n.TON-IP.sslip.io`) qui mène à ton serveur.

**Durée :** 30 minutes, plus le temps de propagation (de quelques minutes à quelques heures).

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Nom de domaine** | Une adresse lisible, comme `patrick-namegni.fr`, que tu loues à l'année auprès d'un registraire. |
| **Registraire** (*registrar*) | L'entreprise où l'on achète un nom de domaine (LWS, OVHcloud, Gandi…). |
| **Sous-domaine** | Une adresse dérivée d'un domaine : `n8n.patrick-namegni.fr` est un sous-domaine de `patrick-namegni.fr`. Tu peux en créer autant que tu veux, gratuitement. |
| **DNS** (*Domain Name System*) | L'annuaire d'Internet : il traduit un nom en adresse IP. Ton navigateur lui demande « où est `n8n.patrick-namegni.fr` ? » et le DNS répond « à `203.0.113.42` ». |
| **Zone DNS** | La page de réglages de ton domaine, chez le registraire, où tu écris les correspondances nom → adresse. |
| **Enregistrement A** | Une ligne de la zone DNS qui dit « ce nom pointe vers cette adresse IPv4 ». |
| **Propagation** | Le temps que la nouvelle correspondance soit connue partout. Souvent quelques minutes, parfois quelques heures. |
| **TTL** (*Time To Live*) | Combien de temps les annuaires gardent une réponse en mémoire avant de la redemander. |
| **HTTPS** | Le web chiffré. Le cadenas du navigateur garantit que personne ne lit ni ne modifie ce qui circule entre toi et le serveur. |
| **Certificat** | Le document numérique qui prouve qu'un serveur est bien le propriétaire du domaine. Indispensable au HTTPS. |
| **Let's Encrypt** | Une autorité qui délivre gratuitement des certificats, valables 90 jours. Caddy les demande et les renouvelle tout seul. |
| **sslip.io** | Un service gratuit qui fait pointer automatiquement `n8n.203-0-113-42.sslip.io` vers l'IP `203.0.113.42`. Pratique pour tester sans acheter de domaine. |

## Pourquoi il faut une adresse

Le HTTPS exige un nom de domaine : Let's Encrypt ne délivre pas de certificat pour une simple adresse IP. Et sans HTTPS, ni Telegram ni Google n'accepteront d'appeler ton n8n.

## Pas à pas

### Option A : sans acheter de domaine (sslip.io)

Remplace les points de ton IP par des tirets. Pour l'IP `203.0.113.42`, ton adresse est :

```
n8n.203-0-113-42.sslip.io
```

Rien à configurer : c'est déjà actif. Vérifie depuis ton PC :

```bash
[PC] $ nslookup n8n.203-0-113-42.sslip.io
```

La réponse doit contenir ton IP. Passe directement au chapitre 08.

Limite : si tu changes de serveur, l'adresse change, et il faudra reconfigurer Google et Telegram.

### Option B : ton propre domaine (recommandé)

1. Chez ton registraire, achète un domaine, par exemple `patrick-namegni.fr` (environ 10 € par an). Il servira aussi pour un portfolio ou une adresse mail professionnelle.
2. Ouvre la **zone DNS** du domaine.
3. Ajoute un enregistrement :

| Champ | Valeur |
|---|---|
| Type | `A` |
| Nom (ou sous-domaine) | `n8n` |
| Valeur (ou cible) | `TON_IP` |
| TTL | la valeur par défaut, ou 3600 |

4. Enregistre, puis attends quelques minutes et vérifie :

```bash
[PC] $ nslookup n8n.patrick-namegni.fr
```

Quand la réponse affiche ton IP, c'est propagé.

### Ce qui se passera au chapitre suivant

Au démarrage, Caddy lira ton adresse, contactera Let's Encrypt, qui viendra vérifier sur le **port 80** que tu contrôles bien ce domaine. Caddy recevra alors le certificat et activera le HTTPS. Tous les 60 jours environ, il le renouvellera tout seul. C'est pour ça que le port 80 doit rester ouvert dans ufw.

## Vérifie

- [ ] `nslookup` sur ton adresse renvoie l'IP de ton serveur.
- [ ] Tu as noté ton adresse finale (sans `https://`) dans ton gestionnaire : c'est ton `N8N_HOST`.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| `nslookup` ne trouve rien | Propagation en cours, ou faute de frappe dans la zone | Attends 15 minutes, relis l'enregistrement |
| `nslookup` renvoie une autre IP | Un ancien enregistrement existe déjà | Supprime-le, ou modifie-le |

## Exercice : refais-le seul

Crée un second sous-domaine `test` qui pointe vers la même IP, vérifie-le avec `nslookup`, puis supprime-le. Explique ensuite, avec l'image de l'annuaire, ce qui se passe quand tu tapes une adresse dans ton navigateur.
