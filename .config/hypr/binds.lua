return function(programs)
    local main_mod = "SUPER"

    hl.bind(main_mod .. " + Q", hl.dsp.exec_cmd(programs.terminal), { description = "Ouvrir le terminal" })
    hl.bind(main_mod .. " + C", hl.dsp.window.close(), { description = "Fermer la fenêtre active" })
    hl.bind(main_mod .. " + M", hl.dsp.exec_cmd("quickshell ipc call session toggle || qs ipc call session toggle"), { description = "Ouvrir le menu de session" })
    hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(programs.file_manager), { description = "Ouvrir le gestionnaire de fichiers" })
    hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Basculer la fenêtre en flottant" })
    hl.bind(main_mod .. " + SPACE", hl.dsp.exec_cmd(programs.menu), { description = "Ouvrir le lanceur d'applications" })
    hl.bind(main_mod .. " + P", hl.dsp.window.pseudo(), { description = "Basculer le pseudo-tiling" })
    hl.bind(main_mod .. " + B", hl.dsp.exec_cmd("bitwarden-desktop"), { description = "Ouvrir Bitwarden" })
    hl.bind(main_mod .. " + R", hl.dsp.exec_cmd("command -v mullvad-gui >/dev/null 2>&1 && mullvad-gui || notify-send -a Hyprland 'Dépendance manquante' 'mullvad-gui est introuvable'"), { description = "Ouvrir Mullvad" })

    hl.bind(main_mod .. " + left", hl.dsp.focus({ direction = "left" }), { description = "Focus fenêtre gauche" })
    hl.bind(main_mod .. " + right", hl.dsp.focus({ direction = "right" }), { description = "Focus fenêtre droite" })
    hl.bind(main_mod .. " + up", hl.dsp.focus({ direction = "up" }), { description = "Focus fenêtre haut" })
    hl.bind(main_mod .. " + down", hl.dsp.focus({ direction = "down" }), { description = "Focus fenêtre bas" })

    hl.bind(main_mod .. " + SHIFT + left", hl.dsp.focus({ workspace = "e-1" }), { description = "Workspace précédent" })
    hl.bind(main_mod .. " + SHIFT + right", hl.dsp.focus({ workspace = "e+1" }), { description = "Workspace suivant" })

    local workspace_keys = {
        { key = "ampersand", workspace = 1 },
        { key = "eacute", workspace = 2 },
        { key = "quotedbl", workspace = 3 },
        { key = "apostrophe", workspace = 4 },
        { key = "parenleft", workspace = 5 },
        { key = "egrave", workspace = 6 },
        { key = "minus", workspace = 7 },
        { key = "underscore", workspace = 8 },
        { key = "ccedilla", workspace = 9 },
        { key = "agrave", workspace = 10 },
    }

    for _, item in ipairs(workspace_keys) do
        hl.bind(main_mod .. " + " .. item.key, hl.dsp.focus({ workspace = item.workspace }), {
            description = "Aller au workspace " .. item.workspace,
        })
        hl.bind(main_mod .. " + SHIFT + " .. item.key, hl.dsp.window.move({ workspace = item.workspace }), {
            description = "Déplacer la fenêtre au workspace " .. item.workspace,
        })
    end

    hl.bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"), { description = "Basculer le scratchpad" })
    hl.bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), {
        description = "Déplacer la fenêtre au scratchpad",
    })

    hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Workspace précédent via molette" })
    hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }), { description = "Workspace suivant via molette" })

    hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Déplacer une fenêtre à la souris" })
    hl.bind(main_mod .. " + Control_L", hl.dsp.window.drag(), { mouse = true, description = "Déplacer une fenêtre au touchpad" })
    hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Redimensionner une fenêtre à la souris" })
    hl.bind(main_mod .. " + ALT_L", hl.dsp.window.resize(), { mouse = true, description = "Redimensionner une fenêtre au touchpad" })

    hl.bind(main_mod .. " + ALT + left", hl.dsp.window.resize({ x = -20, y = 0 }), { repeating = true, description = "Redimensionner fenêtre vers la gauche" })
    hl.bind(main_mod .. " + ALT + right", hl.dsp.window.resize({ x = 20, y = 0 }), { repeating = true, description = "Redimensionner fenêtre vers la droite" })
    hl.bind(main_mod .. " + ALT + up", hl.dsp.window.resize({ x = 0, y = -20 }), { repeating = true, description = "Redimensionner fenêtre vers le haut" })
    hl.bind(main_mod .. " + ALT + down", hl.dsp.window.resize({ x = 0, y = 20 }), { repeating = true, description = "Redimensionner fenêtre vers le bas" })

    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), {
        locked = true,
        repeating = true,
        description = "Augmenter le volume (max 150%)",
    })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), {
        locked = true,
        repeating = true,
        description = "Baisser le volume",
    })
    hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
        locked = true,
        repeating = true,
        description = "Couper/rétablir la sortie audio",
    })
    hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
        locked = true,
        repeating = true,
        description = "Couper/rétablir le micro",
    })
    hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), {
        locked = true,
        repeating = true,
        description = "Augmenter la luminosité",
    })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%- -n 1%"), {
        locked = true,
        repeating = true,
        description = "Baisser la luminosité",
    })

    hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Media suivant" })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Pause media" })
    hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Lecture/pause media" })
    hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Media précédent" })

    hl.bind(main_mod .. " + SHIFT + l", hl.dsp.exec_cmd("hyprlock"), { locked = true, description = "Verrouiller la session" })

    local SCREENSHOT_DIR = "$HOME/Pictures/Screenshots"

    hl.bind(main_mod .. " + i", hl.dsp.exec_cmd('mkdir -p "' .. SCREENSHOT_DIR .. '" && hyprshot -m output -o "' .. SCREENSHOT_DIR .. '"'), {
        description = "Capture écran de la sortie",
    })
    hl.bind(main_mod .. " + y", hl.dsp.exec_cmd('mkdir -p "' .. SCREENSHOT_DIR .. '" && hyprshot -m window -o "' .. SCREENSHOT_DIR .. '"'), {
        description = "Capture écran de la fenêtre",
    })
    hl.bind(main_mod .. " + u", hl.dsp.exec_cmd('mkdir -p "' .. SCREENSHOT_DIR .. '" && hyprshot -m region -o "' .. SCREENSHOT_DIR .. '"'), {
        description = "Capture écran d'une région",
    })

    hl.bind(main_mod .. " + f", hl.dsp.exec_cmd("quickshell ipc call notifications toggle || qs ipc call notifications toggle"), {
        description = "Basculer le centre de contrôle et notifications",
    })

    hl.bind(main_mod .. " + a", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"), {
        locked = true,
        description = "Basculer le layout clavier",
    })
end
