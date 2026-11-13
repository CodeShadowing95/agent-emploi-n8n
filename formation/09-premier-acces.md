# 09 · Premier accès et sécurité de n8n

**Objectif :** ouvrir n8n en HTTPS, créer ton compte propriétaire et le protéger par la double authentification.

**Durée :** 20 minutes. **À faire juste après le chapitre 08, sans attendre.**

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Compte propriétaire** (*owner*) | Le premier compte créé dans n8n, qui a tous les droits. |
| **2FA** (double authentification, ou MFA) | En plus du mot de passe, un code à 6 chiffres qui change toutes les 30 secondes, généré par une application sur ton téléphone. Un voleur de mot de passe ne peut rien sans ton téléphone. |
| **Application d'authentification** | L'application qui génère ces codes : Google Authenticator, Microsoft Authenticator, ou celle de Bitwarden. |
| **Codes de secours** | Des codes à usage unique pour te connecter si tu perds ton téléphone. À ranger dans ton gestionnaire. |
| **Cadenas** | L'icône du navigateur qui confirme une connexion HTTPS avec un certificat valide. |

## Pourquoi tout de suite

Tant que le compte propriétaire n'existe pas, **la première personne qui ouvre l'adresse peut le créer** et prendre le contrôle de ton n8n. Les robots qui scannent Internet repèrent ce genre de page vite.

## Pas à pas

### 1. Ouvrir n8n

Dans ton navigateur : `https://TON_DOMAINE`. Vérifie le **cadenas** à gauche de l'adresse. Clique dessus : le certificat doit être délivré par Let's Encrypt.

Teste aussi `http://TON_DOMAINE` (sans le `s`) : Caddy doit te rediriger seul vers `https://`.

### 2. Créer le compte propriétaire

n8n affiche « Set up owner account ». Renseigne :

- ton adresse mail ;
- ton prénom et ton nom ;
- un mot de passe **long et unique**, généré par ton gestionnaire (au moins 8 caractères avec une majuscule et un chiffre, exigés par n8n ; vise 20).

Range-le dans ton gestionnaire, entrée « n8n agent-emploi ».

Au questionnaire qui suit (« What best describes your company… »), réponds ce que tu veux ou passe.

### 3. Activer la double authentification

*n8n* : en bas à gauche, ton nom → **Settings** → **Personal** → section **Security** → **Enable two-factor authentication**.

1. Scanne le QR code avec ton application d'authentification.
2. Entre le code à 6 chiffres affiché par l'application.
3. n8n affiche des **codes de secours** : copie-les dans ton gestionnaire.

Déconnecte-toi, puis reconnecte-toi : n8n doit te demander le code.

### 4. (Facultatif) Licence communautaire gratuite

n8n propose d'enregistrer gratuitement ton installation contre ton adresse mail, en échange de quelques fonctions en plus (par exemple les dossiers de workflows et la recherche dans l'historique). *n8n* : **Settings** → **Usage and plan** → **Unlock selected paid features for free**. Tu reçois une clé par mail, à coller au même endroit.

## Vérifie

- [ ] Le cadenas est présent et le certificat vient de Let's Encrypt.
- [ ] `http://` redirige vers `https://`.
- [ ] Ton compte propriétaire existe, son mot de passe et ses codes de secours sont dans ton gestionnaire.
- [ ] La connexion demande un code 2FA.

## Si ça bloque

| Symptôme | Cause | Solution |
|---|---|---|
| « Votre connexion n'est pas privée » | Le certificat n'a pas encore été obtenu | Chapitre 08, logs de Caddy |
| n8n affiche un écran de connexion au lieu de la création de compte | Un compte existe déjà | Si ce n'est pas toi : arrête tout (`docker compose down`), supprime les volumes (`docker compose down -v`) et recommence le chapitre 08 avec de nouveaux secrets |
| Le code 2FA est refusé | L'heure de ton téléphone est décalée | Active l'heure automatique sur ton téléphone |

## Exercice : refais-le seul

Explique en deux phrases pourquoi la création du compte propriétaire doit suivre immédiatement le démarrage de n8n. Puis teste la connexion avec un code de secours (il sera consommé : n8n t'en régénère sur demande dans **Settings** → **Personal**).
