# Configuration Hyprland

Ce dépôt documente la configuration Hyprland locale placée dans `~/.config/hypr`.

Règle de maintenance : toute modification fonctionnelle doit mettre à jour ce README dans la même intervention.

## État

- Date de mise à jour : 2026-06-03.
- Hyprland local : `0.55.2`, tag `v0.55.2`, commit `39d7e209c79d451efab1b21151d5938289da838d`.
- Source active : `hyprland.lua`.
- Session détectée : `hyprland-uwsm`.
- Démarrage vérifié : le process Hyprland est lancé avec `--config /home/hdg/.config/hypr/hyprland.lua`.
- Fallback Hyprlang : supprimé.

## Architecture

| Fichier | Rôle |
| --- | --- |
| `hyprland.lua` | Configuration principale Lua : moniteurs, apparence, animations, input et règles fenêtres. |
| `programs.lua` | Applications par défaut et autostart UWSM-aware. |
| `binds.lua` | Raccourcis via `hl.bind` et dispatchers `hl.dsp.*`. |
| `hypridle.conf` | Idle, verrouillage, DPMS et suspension. |
| `hyprlock.conf` | Écran de verrouillage. |
| `hyprpaper.conf` | Fond d’écran. |
| `scripts/monitor.sh` | Gestion écran interne/externe avec `hyprctl monitors -j`, `jq` et `hyprctl eval`. |
| `scripts/battery-level.sh` | Notifications batterie appelées par un daemon systemd externe, pas par Hyprland. |
| `scripts/gesture.sh` | Wrapper des gestes `libinput-gestures` vers les dispatchers Lua Hyprland. |
| `scripts/check-dependencies.sh` | Vérification des dépendances requises et optionnelles. |

## Configuration Active

- Moniteurs : `eDP-1` configuré en `2880x1800@60`, scale `1.5`, bitdepth `10`; fallback sortie externe en `preferred`.
- Autostart Hyprland : `hyprpaper`, `hypridle`, `udiskie`, `rfkill`, `monitor.sh`, `hyprland-monitor-attached`, watchers `wl-paste`.
- Gestes : `libinput-gestures` est lancé par l’autostart XDG `~/.config/autostart/libinput-gestures.desktop`, pas par `programs.lua`.
- Optionnel : `hyprsunset` est lancé seulement s’il est installé.
- Batterie : non lancée par Hyprland ; `scripts/battery-level.sh` est conservé pour le daemon systemd existant.
- Idle : luminosité à `150s`, verrouillage à `300s`, DPMS à `330s`, suspension à `3600s`.
- Lock : fond `picture/wd_4.jpg`, mot de passe masqué.
- Wallpaper : `hyprpaper.conf` utilise `picture/wd_4.jpg` en `cover`.

## Correctifs Réalisés

- Migration Lua confirmée après redémarrage.
- Suppression des fichiers legacy Hyprlang et du shim de fallback.
- Suppression de tout lancement batterie depuis `programs.lua`.
- `monitor.sh` corrigé pour le provider Lua : remplacement de `hyprctl keyword monitor` par `hyprctl eval`.
- `monitor.sh` lancé une fois au démarrage, puis relancé par `hyprland-monitor-attached`.
- `hypridle.conf` corrigé pour dispatch DPMS compatible Lua.
- `hyprlock.conf` nettoyé : suppression de bloc profil inutile et masquage du mot de passe.
- `hyprpaper.conf` nettoyé : suppression des anciennes lignes commentées.
- `libinput-gestures` corrigé : suppression du doublon d’autostart Hyprland et routage des commandes via `scripts/gesture.sh` pour éviter l’ancienne syntaxe `hyprctl dispatch workspace e±1` incompatible avec le provider Lua.

## Validation

Commandes exécutées :

```sh
Hyprland --verify-config -c /home/hdg/.config/hypr/hyprland.lua
bash -n scripts/monitor.sh
sh -n scripts/battery-level.sh
sh -n scripts/gesture.sh
bash -n scripts/check-dependencies.sh
./scripts/check-dependencies.sh
hyprctl reload
hyprctl configerrors
hyprctl binds
hyprctl monitors -j
```

Résultats :

- `hyprland.lua` : `config ok`.
- `hyprctl configerrors` : aucune erreur.
- Binds Lua vérifiés : `SUPER+M`, `SUPER+R`, `XF86AudioMute`, workspaces FR.
- Process vérifiés : `Hyprland --config hyprland.lua`, `hyprpaper`, `hypridle`, `hyprland-monitor-attached`, `wl-paste`.
- `monitor.sh` réel : avec `DP-3` connecté, `eDP-1` est désactivé.
- Aucun process `battery-level` / `battery-watch` lancé par Hyprland.
- `libinput-gestures` : binaire installé ; process actif vérifié avec groupe supplémentaire `input`; l’instance courante vient d’un scope `kitty`, tandis que le démarrage automatique au prochain login reste porté par `~/.config/autostart/libinput-gestures.desktop`.
- `libinput-gestures -l` depuis le shell Codex sandbox ne voit pas les devices car ce shell n’a pas le groupe `input`; ce n’est pas représentatif du process réel.

## Dépendances

Requises et présentes lors de la validation :

- `acpi`
- `bitwarden-desktop`
- `brightnessctl`
- `cliphist`
- `hypridle`
- `hyprland-monitor-attached`
- `hyprlock`
- `hyprpaper`
- `hyprshot`
- `jq`
- `kitty`
- `libinput-gestures`
- `nautilus`
- `notify-send`
- `playerctl`
- `rfkill`
- `rofi`
- `swaync-client`
- `udiskie`
- `uwsm`
- `wlogout`
- `wl-copy`
- `wl-paste`
- `wpctl`

Optionnelles :

- `hyprsunset`
- `mullvad-gui`

## Notes

- `hyprctl reload` recharge la configuration, mais ne relance pas forcément les processus d’autostart déjà terminés ; après un reload manuel, vérifier `pgrep -a hypridle`.
- L’override UWSM utilisateur reste dans `~/.local/share/wayland-sessions/hyprland.desktop` pour démarrer explicitement Hyprland avec `hyprland.lua`.
- Les variables curseur UWSM sont dans `~/.config/uwsm/env-hyprland`.
- Pour `libinput-gestures`, le compte `hdg` doit être dans le groupe `input` et la session active doit avoir été ouverte après cette appartenance ; `id` doit afficher `input`.

## Sources

- Wiki Hyprland : https://wiki.hypr.land/
- Démarrage et Lua : https://wiki.hypr.land/Configuring/Start/
- Binds : https://wiki.hypr.land/Configuring/Basics/Binds/
- Dispatchers : https://wiki.hypr.land/Configuring/Basics/Dispatchers/
- Moniteurs : https://wiki.hypr.land/Configuring/Basics/Monitors/
- Environnement : https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
- Systemd / UWSM : https://wiki.hypr.land/Useful-Utilities/Systemd-start/
- Annonce Hyprland 0.55 : https://hypr.land/news/update55/
