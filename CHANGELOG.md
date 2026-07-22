# Changelog

Toutes les modifications notables apportées à ce projet seront consignées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au versionnage sémantique.

## [v0.1.1] - 2026-07-22

### Modifié
- Ajustement du sens de défilement de la molette pour le changement de workspace dans `binds.lua` et dans le module Waybar `workspace.jsonc`.
- Désactivation de l'autostart automatique de `monitor.sh` dans `programs.lua`.

## [v0.1.0] - 2026-07-22

### Ajouté
- Machine à états déterministe pour la gestion dynamique des écrans dans `monitors.lua` avec support de l'API Hyprland 0.56 (`hl.get_monitors({ all = true })`).
- Support du profil d'affichage matériel dans `profiles/default.lua`.
- Désactivation automatique de l'écran interne `eDP-1` et bascule exclusive sur l'écran externe lorsque branché (`EXTERNAL_ONLY`).
- Verrouillage de sécurité `SAFETY_FALLBACK` empêchant la perte d'affichage lorsque le capot est fermé sans écran externe.
- Activation native des gestes touchpad (`workspace_swipe = true`) dans `hyprland.lua`.
- Correction de l'erreur Lua `hl.window.resize: 'x' and 'y' are required` dans `binds.lua` en passant les clés `x` et `y` explicites pour le redimensionnement.
- Restauration et enrichissement des raccourcis de redimensionnement et déplacement (`SUPER + ALT_L` / `SUPER + Control_L` au touchpad ainsi que `SUPER + ALT + Flèches` au clavier).
- Option `inhibit_sleep = true` dans `hypridle.conf` pour s'assurer que le verrou `hyprlock` est acquis avant la mise en veille.
- Fichier `CHANGELOG.md` pour le suivi des versions et évolutions du projet.

### Modifié
- Sécurisation de l'action `suspend` dans Wlogout (`wlogout/layout`) avec `loginctl lock-session && systemctl suspend` pour éliminer la condition de course avec `hyprlock`.
- Refonte de `check-dependencies.sh` avec suivi des dépendances obligatoires/optionnelles et code de sortie non-nul (`exit 1`) en cas de manque.
- Nettoyage de `binds.lua` : dossier XDG des captures d'écran (`~/Pictures/Screenshots`), limitation du volume audio à 150%, suppression des drapeaux `locked` non sécurisés.
- Suppression du périphérique `amdgpu_bl1` codé en dur dans SwayNC (`swaync/config.json`) et conversion des commandes `sh -c` en syntaxe POSIX.
- Corrections dans Waybar (`battery.jsonc`, `memory.jsonc`, `network.jsonc`) : suppression d'attributs non standards et corrections typographiques.
- Mise à jour du `README.md` racine et interne pour refléter la compatibilité Hyprland >= 0.56.0.

### Supprimé
- Suppression du script Shell concurrent `monitor.sh`.
- Suppression du script obsolète `gesture.sh`.
