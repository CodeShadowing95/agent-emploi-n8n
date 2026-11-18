# Agent : Conseil du soir

1. Objectif : Donner une bonne pratique du jour et des actions à faire le lendemain.
2. Déclencheur : Schedule Trigger, cron « 0 20 * * * » (20 h, chaque jour).
3. Entrées : la date du jour ($now) ; mon profil, écrit en dur dans le prompt.
   Aucune donnée extérieure.
4. Règles (sans IA) : seulement l'heure. Pas de filtre, pas de condition.
5. Jugement IA : rédiger la bonne pratique et choisir une action à effectuer le lendemain.
   Claude Sonnet 5 (rapide, peu cher, suffisant pour un texte court).
6. Format de sortie : texte libre (champ text). Pas de JSON : le texte va tel
   quel dans Telegram, aucun nœud ne le relit.
7. Actions : envoyer le texte sur Telegram, à mon chat_id.
8. Validation humaine : aucune. Le message ne part que vers moi, il n'y a rien
   à valider.
9. Garde-fous et cas limites : le prompt interdit les emoji et demande de varier ;
   coût d'environ un appel Haiku par jour ; si Telegram ou Anthropic échoue,
   l'Alerte erreurs (99) me prévient. Limite : Claude ne se souvient pas des
   jours précédents et peut répéter une bonne pratique.
10. Test et mesure : Execute workflow, puis lecture du message sur Telegram.
    Mesure : est-ce que j'applique l'astuce ? Note dans docs/journal.md.

## Schéma des nœuds
Schedule Trigger → Basic LLM Chain (+ Anthropic Chat Model) → Telegram

## Prompt
Système : aucun (tout est dans le message utilisateur).
Utilisateur : le prompt « Nous sommes le … Bonne pratique du jour … » du nœud Basic LLM Chain.
