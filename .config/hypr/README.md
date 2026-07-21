# Configuration Hyprland (0.56+)

Ce dossier `~/.config/hypr` contient la configuration principale de la session Hyprland en Lua.

---

## État & Architecture

- **Date de mise à jour** : Juillet 2026
- **Version cible** : Hyprland `>= 0.56.0` (Lua provider native)
- **Session** : `hyprland-uwsm`

### Structure des Fichiers

| Fichier / Dossier | Rôle |
| --- | --- |
| `hyprland.lua` | Configuration principale Lua : règles de fenêtres, imports et événements. |
| `monitors.lua` | Machine à états de gestion dynamique des écrans (0.56) : inventaire `all = true`, priorisation écran externe, fallback capot. |
| `profiles/default.lua` | Profil matériel par défaut (écran interne `eDP-1`, résolutions, rafraîchissement 90Hz, 10 bits/VRR). |
| `programs.lua` | Applications par défaut et autostart. |
| `binds.lua` | Raccourcis clavier/souris via `hl.bind` et `hl.dsp.*`. |
| `hypridle.conf` | Gestionnaire d'inactivité avec `inhibit_sleep = true` pour sécuriser le verrouillage avant suspension. |
| `hyprlock.conf` | Écran de verrouillage. |
| `hyprpaper.conf` | Fond d'écran. |
| `scripts/battery-level.sh` | Notification de batterie faible. |
| `scripts/check-dependencies.sh` | Validation des dépendances obligatoires et optionnelles (retourne un code d'erreur non-nul en cas de manque). |

---

## Fonctionnement de la Gestion des Écrans (`monitors.lua`)

1. **Inventaire complet** : `hl.get_monitors({ all = true })` interroge les sorties connectées (actives ou désactivées).
2. **Priorité externe** :
   - Écran externe connecté + capot ouvert : Écran externe prioritaire et actif (`EXTERNAL_PRIORITY_LID_OPEN`).
   - Écran externe connecté + capot fermé : Écran externe actif seul (`EXTERNAL_CLAMSHELL`), écran interne désactivé.
   - Aucun écran externe + capot ouvert : Écran interne actif (`INTERNAL_ONLY`).
   - Aucun écran externe + capot fermé : Protection de sécurité (`SAFETY_FALLBACK`), écran interne maintenu actif.
3. **Idempotence** : Évite les notifications ou applications récursives si l'état des écrans est inchangé.

---

## Diagnostic & Validation

```bash
# Vérifier la syntaxe et les dépendances
.config/hypr/scripts/check-dependencies.sh

# Recharger Hyprland et vérifier les erreurs
hyprctl reload
hyprctl configerrors

# Inspecter les moniteurs reconnus par 0.56
hyprctl monitors all
```

---

## Documentation Amont (Hyprland 0.56)

- Release Hyprland 0.56 : https://github.com/hyprwm/Hyprland/releases/tag/v0.56.0
- Dispatchers et Binds : https://wiki.hypr.land/Configuring/Basics/Binds/
- API Moniteurs : https://wiki.hypr.land/Configuring/Basics/Monitors/
- Hypridle & Inhibit Sleep : https://wiki.hypr.land/Hypr-Ecosystem/hypridle/
