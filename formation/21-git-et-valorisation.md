# 21 · Git, GitHub et valorisation

**Objectif :** travailler dans le dépôt comme en entreprise (branches, pull requests, CI), et transformer ce projet en argument d'entretien.

**Durée :** 1 heure.

## Mots nouveaux de ce chapitre

| Mot | Définition simple |
|---|---|
| **Branche** | Une ligne de travail parallèle. `main` est la version stable ; chaque nouveauté se fait sur une branche à part, puis rejoint `main`. |
| **Pull request** (PR) | Une demande de fusion d'une branche dans `main`, sur GitHub. On y voit les changements, la CI s'y exécute, et on valide avant de fusionner. |
| **Fusion** (*merge*) | L'intégration des changements d'une branche dans une autre. |
| **CI** (intégration continue) | Des vérifications automatiques lancées par GitHub Actions à chaque push et chaque PR. |
| **GitHub Actions** | Le service de GitHub qui exécute la CI, décrite dans `.github/workflows/ci.yml`. |
| **Conventional Commits** | Une convention pour les messages de commit : un type (`feat`, `fix`, `docs`, `chore`), deux-points, puis une description courte. |
| **README** | La page d'accueil du dépôt : ce que fait le projet, comment l'installer. C'est ce qu'un recruteur lit en premier. |

## 1. Le cycle de travail

Pour chaque nouveauté (un agent, une correction, un chapitre) :

```bash
[VPS] $ cd ~/agent-emploi-n8n
[VPS] $ git checkout main && git pull           # partir de la dernière version
[VPS] $ git checkout -b agent-02-relances        # nouvelle branche
# … travail dans n8n …
[VPS] $ ./scripts/export-workflows.sh            # exporter les workflows
[VPS] $ git status                               # voir ce qui a changé
[VPS] $ git diff                                 # voir le détail
[VPS] $ git add workflows/ prompts/
[VPS] $ git commit -m "feat: agent relances J+7 et J+14 avec validation Telegram"
[VPS] $ git push -u origin agent-02-relances
```

Puis sur GitHub :

1. Bandeau jaune **Compare & pull request** → titre clair, description : ce que fait l'agent, comment tu l'as testé.
2. Attends la coche verte de la CI.
3. **Merge pull request** → **Confirm** → **Delete branch**.
4. Sur le serveur : `git checkout main && git pull`.

### Les types de commit

| Type | Pour | Exemple |
|---|---|---|
| `feat` | Une nouvelle fonctionnalité | `feat: agent veille offres France Travail` |
| `fix` | Une correction | `fix: fuseau horaire du rapport du vendredi` |
| `docs` | Documentation, journal | `docs: journal module 5` |
| `chore` | Entretien sans effet visible | `chore: montée de version n8n` |

## 2. Ce que vérifie la CI

À chaque push, `.github/workflows/ci.yml` lance quatre contrôles :

| Contrôle | Ce qu'il attrape |
|---|---|
| `docker compose config -q` | Une erreur de syntaxe dans `docker-compose.yml` |
| `shellcheck scripts/*.sh` | Les erreurs classiques dans les scripts Bash |
| `jq` sur `workflows/*.json` | Un export JSON cassé, ou des `pinData` oubliées |
| gitleaks | Un secret (clé d'API, jeton) glissé dans le code |

Si une coche est rouge : clique dessus, lis le message, corrige sur la même branche, repousse.

## 3. Le README : ta vitrine

Le README du dépôt doit répondre en une minute à quatre questions : **quoi**, **comment**, **pourquoi ces choix**, **comment l'installer**. Au fil des modules, mets à jour :

- le tableau des agents (colonne **État** : « En service ») ;
- une capture d'écran de chaque workflow, dans `docs/captures/` ;
- un GIF de 20 secondes : un mail de refus arrive, la feuille se met à jour, la notification tombe. **Données fictives uniquement.**

## 4. La ligne de CV

> **Agent d'automatisation de recherche d'emploi** (projet personnel, 2026) : n8n auto-hébergé sur VPS Ubuntu sécurisé (Docker Compose, PostgreSQL, Caddy et HTTPS), cinq workflows intégrant l'API Claude (classification des réponses, notation d'offres, rédaction de relances) avec validation humaine sur Telegram ; sauvegardes, supervision et CI GitHub Actions.

Ajoute des chiffres réels quand tu les as mesurés : « 150 offres notées en un mois », « réponses traitées en moins de 5 minutes ».

## 5. Le pitch d'entretien (30 secondes)

> « Pour ma recherche d'emploi, j'ai construit un agent auto-hébergé. n8n tourne sous Docker sur un VPS que j'ai installé et sécurisé moi-même. Claude classe les réponses des recruteurs, note les offres et rédige les relances, mais rien ne part sans ma validation sur Telegram. Le point le plus intéressant a été la sécurité : un mail reçu ne doit jamais pouvoir donner d'ordres à l'agent. »

Prépare-toi aux questions de suite : pourquoi Postgres plutôt que SQLite (chapitre 08), comment tu gères les secrets (chapitre 11), ce qui se passe si le serveur tombe (chapitre 19), comment tu empêches l'injection de prompt (chapitre 20).

## Vérifie

- [ ] Chaque agent est arrivé dans `main` par une pull request, avec la CI verte.
- [ ] Le README est à jour, avec captures.
- [ ] Tu as dit le pitch à voix haute, sans notes, en moins de 40 secondes.

## Exercice : refais-le seul

Fais une pull request qui ne contient qu'une entrée de ton journal (`docs: journal module X`). Puis fais volontairement échouer la CI (par exemple une faute d'indentation dans `docker-compose.yml` sur une branche d'essai), observe l'erreur, corrige-la, et supprime la branche.
