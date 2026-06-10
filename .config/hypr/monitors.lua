local INTERNAL_MONITOR = "eDP-1"
local INTERNAL_MODE = "2880x1800@90"
local INTERNAL_SCALE = 1.25
local INTERNAL_BITDEPTH = 10

-- Helper pour envoyer des notifications via swaync (en utilisant notify-send)
local function notify_send(text)
    hl.exec_cmd("notify-send -a 'Hyprland Monitor' '" .. text .. "'")
end

-- Helper pour lire l'état physique du capot du portable
local function is_lid_open()
    local f = io.popen("cat /proc/acpi/button/lid/*/state 2>/dev/null")
    if not f then return true end
    local content = f:read("*all")
    f:close()
    if content and string.find(content, "close") then
        return false
    end
    return true
end

-- Fonction principale d'ajustement des écrans
local function update_monitors()
    local monitors = hl.get_monitors()
    local external_count = 0
    for _, m in ipairs(monitors) do
        if m.name ~= INTERNAL_MONITOR then
            external_count = external_count + 1
        end
    end

    local lid_open = is_lid_open()

    if external_count > 0 then
        if lid_open then
            -- Écran externe branché + capot ouvert : l'écran externe est désactivé par défaut
            hl.monitor({
                output = INTERNAL_MONITOR,
                mode = INTERNAL_MODE,
                position = "auto",
                scale = INTERNAL_SCALE,
                bitdepth = INTERNAL_BITDEPTH,
            })
            hl.monitor({
                output = "",
                disabled = true,
            })
            notify_send("Écran externe branché et désactivé par défaut (capot ouvert).")
        else
            -- Écran externe branché + capot fermé (Clamshell) : externe activé, interne désactivé
            hl.monitor({
                output = INTERNAL_MONITOR,
                disabled = true,
            })
            hl.monitor({
                output = "",
                mode = "preferred",
                position = "auto",
                scale = "auto",
                bitdepth = 10,
            })
            notify_send("Écran externe actif en mode clamshell (écran interne désactivé).")
        end
    else
        -- Aucun écran externe connecté : écran interne activé
        hl.monitor({
            output = INTERNAL_MONITOR,
            mode = INTERNAL_MODE,
            position = "auto",
            scale = INTERNAL_SCALE,
            bitdepth = INTERNAL_BITDEPTH,
        })
        -- Réinitialiser la règle par défaut pour les écrans externes en "preferred" pour les branchements à chaud
        hl.monitor({
            output = "",
            mode = "preferred",
            position = "auto",
            scale = "auto",
            bitdepth = 10,
        })
    end
end

-- Initialisation au démarrage
update_monitors()

-- Écouteurs d'événements à chaud (hotplug)
hl.on("monitor.added", function()
    update_monitors()
end)

hl.on("monitor.removed", function()
    update_monitors()
end)

-- Liaisons sur les switchs matériels du capot (Lid Switch)
hl.bind("switch:off:Lid Switch", function()
    update_monitors()
end, { locked = true, description = "Gérer les écrans à l'ouverture du capot" })

hl.bind("switch:on:Lid Switch", function()
    update_monitors()
end, { locked = true, description = "Gérer les écrans à la fermeture du capot" })
