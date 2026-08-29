local programs = {
    terminal = "kitty",
    file_manager = "nautilus",
    menu = "rofi -show drun || pkill rofi",
}

local autostart_commands = {
    { check = "command -v hyprpaper >/dev/null 2>&1", name = "hyprpaper", command = "uwsm app -- hyprpaper" },
    { check = "command -v hypridle >/dev/null 2>&1", name = "hypridle", command = "uwsm app -- hypridle" },
    { check = "command -v quickshell >/dev/null 2>&1", name = "quickshell", command = "uwsm app -- quickshell" },
    { check = "command -v hyprsunset >/dev/null 2>&1", name = "hyprsunset", command = "uwsm app -- hyprsunset", optional = true },
    { check = "command -v udiskie >/dev/null 2>&1", name = "udiskie", command = "uwsm app -- udiskie" },
    { check = "command -v rfkill >/dev/null 2>&1", name = "rfkill", command = "rfkill unblock bluetooth" },
    { check = "command -v wl-paste >/dev/null 2>&1", name = "wl-paste", command = "uwsm app -- wl-paste --type text --watch cliphist store" },
    { check = "command -v wl-paste >/dev/null 2>&1", name = "wl-paste", command = "uwsm app -- wl-paste --type image --watch cliphist store" },
}

hl.on("hyprland.start", function()
    for _, entry in ipairs(autostart_commands) do
        local command
        if entry.optional then
            command = entry.check .. " && " .. entry.command
        else
            command = "if " .. entry.check .. "; then " .. entry.command .. "; else notify-send -a Hyprland 'Dépendance manquante' '" .. entry.name .. " est introuvable'; fi"
        end

        hl.exec_cmd(command)
    end
end)

return programs
