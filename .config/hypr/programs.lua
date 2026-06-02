local programs = {
    terminal = "kitty",
    file_manager = "nautilus",
    menu = "rofi -show drun || pkill rofi",
}

local autostart_commands = {
    { check = "command -v hyprpaper >/dev/null 2>&1", name = "hyprpaper", command = "uwsm app -- hyprpaper" },
    { check = "command -v hypridle >/dev/null 2>&1", name = "hypridle", command = "uwsm app -- hypridle" },
    { check = "command -v hyprsunset >/dev/null 2>&1", name = "hyprsunset", command = "uwsm app -- hyprsunset", optional = true },
    { check = "command -v udiskie >/dev/null 2>&1", name = "udiskie", command = "uwsm app -- udiskie" },
    { check = "command -v rfkill >/dev/null 2>&1", name = "rfkill", command = "rfkill unblock bluetooth" },
    {
        check = "test -x /home/hdg/.config/hypr/scripts/monitor.sh",
        name = "monitor.sh",
        command = "uwsm app -- /home/hdg/.config/hypr/scripts/monitor.sh",
    },
    {
        check = "command -v hyprland-monitor-attached >/dev/null 2>&1",
        name = "hyprland-monitor-attached",
        command = "uwsm app -- /usr/bin/hyprland-monitor-attached ~/.config/hypr/scripts/monitor.sh ~/.config/hypr/scripts/monitor.sh",
    },
    { check = "command -v wl-paste >/dev/null 2>&1", name = "wl-paste", command = "uwsm app -- wl-paste --type text --watch cliphist store" },
    { check = "command -v wl-paste >/dev/null 2>&1", name = "wl-paste", command = "uwsm app -- wl-paste --type image --watch cliphist store" },
}

hl.on("hyprland.start", function()
    for _, entry in ipairs(autostart_commands) do
        local command = entry.check .. " && " .. entry.command

        if not entry.optional then
            command = command .. " || notify-send -a Hyprland 'Dépendance manquante' '" .. entry.name .. " est introuvable'"
        end

        hl.exec_cmd(command)
    end
end)

return programs
