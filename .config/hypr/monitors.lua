-- Machine à états de gestion des écrans (DÉSACTIVÉE / COMMENTÉE)
-- Le script shell originel `.config/hypr/scripts/monitor.sh` est restauré et utilisé manuellement.

--[[
local ok, profile = pcall(require, "profiles.default")
if not ok or not profile then
    profile = {
        internal_monitor = "eDP-1",
        internal_mode = "2880x1800@90",
        internal_scale = 1.25,
        internal_bitdepth = 10,
        external_fallback = { mode = "preferred", position = "auto", scale = "auto", bitdepth = 10 }
    }
end

local INTERNAL_MONITOR = profile.internal_monitor
local INTERNAL_MODE = profile.internal_mode
local INTERNAL_SCALE = profile.internal_scale
local INTERNAL_BITDEPTH = profile.internal_bitdepth

local last_profile_applied = nil

local function notify_send(text)
    hl.exec_cmd("notify-send -a 'Hyprland Monitor' '" .. text .. "'")
end

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

local function get_hardware_inventory()
    local all_monitors = hl.get_monitors({ all = true })
    local external_monitors = {}
    local has_internal = false

    for _, m in ipairs(all_monitors) do
        if m.name == INTERNAL_MONITOR then
            has_internal = true
        else
            table.insert(external_monitors, m)
        end
    end

    return external_monitors, has_internal
end

local function determine_target_profile(external_monitors, has_internal, lid_open)
    local has_external = #external_monitors > 0

    if has_external then
        return "EXTERNAL_ONLY"
    else
        if lid_open then
            return "INTERNAL_ONLY"
        else
            return "SAFETY_FALLBACK"
        end
    end
end

local function apply_profile(target_profile)
    if target_profile == last_profile_applied then
        return
    end

    if target_profile == "EXTERNAL_ONLY" then
        hl.monitor({
            output = INTERNAL_MONITOR,
            disabled = true,
        })
        hl.monitor({
            output = "",
            mode = profile.external_fallback.mode,
            position = profile.external_fallback.position,
            scale = profile.external_fallback.scale,
            bitdepth = profile.external_fallback.bitdepth,
            disabled = false,
        })
        notify_send("Écran externe connecté : écran interne désactivé, écran externe actif.")

    elseif target_profile == "INTERNAL_ONLY" then
        hl.monitor({
            output = INTERNAL_MONITOR,
            mode = INTERNAL_MODE,
            position = "auto",
            scale = INTERNAL_SCALE,
            bitdepth = INTERNAL_BITDEPTH,
            disabled = false,
        })
        hl.monitor({
            output = "",
            disabled = true,
        })
        notify_send("Écran interne seul actif.")

    elseif target_profile == "SAFETY_FALLBACK" then
        hl.monitor({
            output = INTERNAL_MONITOR,
            mode = INTERNAL_MODE,
            position = "auto",
            scale = INTERNAL_SCALE,
            bitdepth = INTERNAL_BITDEPTH,
            disabled = false,
        })
        notify_send("Avertissement : capot fermé sans écran externe. Écran interne maintenu actif par sécurité.")
    end

    last_profile_applied = target_profile
end

local function update_monitors()
    local external_monitors, has_internal = get_hardware_inventory()
    local lid_open = is_lid_open()
    local target_profile = determine_target_profile(external_monitors, has_internal, lid_open)
    apply_profile(target_profile)
end

update_monitors()

hl.on("monitor.added", function()
    update_monitors()
end)

hl.on("monitor.removed", function()
    update_monitors()
end)

hl.bind("switch:off:Lid Switch", function()
    update_monitors()
end, { locked = true, description = "Ajuster l'affichage à l'ouverture du capot" })

hl.bind("switch:on:Lid Switch", function()
    update_monitors()
end, { locked = true, description = "Ajuster l'affichage à la fermeture du capot" })
--]]
