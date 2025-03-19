```
██╗  ██╗██████╗  ██████╗       ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ██╗      █████╗ ███╗   ██╗██████╗ 
██║  ██║██╔══██╗██╔════╝       ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗
███████║██║  ██║██║  ███╗█████╗███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║     ███████║██╔██╗ ██║██║  ██║
██╔══██║██║  ██║██║   ██║╚════╝██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║
██║  ██║██████╔╝╚██████╔╝      ██║  ██║   ██║   ██║     ███████╗██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝
╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝                                                                                
```
This repository contains my personal configuration files for setting up Hyprland. It includes configurations for various components such as Hyprland, Hyprlock, Rofi, SwayNC, Waybar, and Wlogout.

## Showcase

Here are some screenshots of my configuration:

![Empty Configuration](/media/empty.png)

![Full Configuration](/media/full.png)

![Logout Screen](/media/wlogout.png)

## Directory Structure

The configuration files are organized as follows:

```
.config
├── hypr
│   ├── binds.conf                  # Key bindings configuration for Hyprland
│   ├── hypridle.conf               # Idle settings for Hyprland
│   ├── hyprland.conf               # Main configuration file for Hyprland
│   ├── hyprlock.conf               # Lock screen configuration
│   ├── hyprpaper.conf              # Wallpaper settings
│   ├── picture                     # Directory containing wallpaper images
│   │   └── w2.jpg                  # Wallpaper image
│   ├── programs.conf               # Program configurations
│   └── scripts                     # Custom scripts
│       ├── battery-level.sh        # Script to check battery level
│       └── monitor.sh              # Script to manage monitors
├── rofi
│   ├── config.rasi                 # Rofi configuration file
│   └── themes                      # Rofi themes
│       └── theme.rasi              # My theme for Rofi
├── swaync
│   ├── config.json                 # Config for SwayNC
│   └── style.css                   # CSS for SwayNC
├── waybar
│   ├── config                      # Main configuration file for Waybar
│   ├── modules                     # Directory containing Waybar module configurations
│   │   ├── backlight.jsonc         # Backlight config
│   │   ├── battery.jsonc           # Battery config
│   │   ├── clock.jsonc             # Clock config
│   │   ├── cpu.jsonc               # CPU config
│   │   ├── custom-launcher.jsonc   # Custom launcher config
│   │   ├── custom-power.jsonc      # Custom power config
│   │   ├── custom-swaync.jsonc     # Custom SwayNC config
│   │   ├── hyprland-window.jsonc   # Hyprland window config
│   │   ├── memory.jsonc            # Memory config
│   │   ├── mpris.jsonc             # MPRIS config
│   │   ├── network.jsonc           # Network config
│   │   ├── pulseaudio.jsonc        # PulseAudio config
│   │   ├── wlr-taskbar.jsonc       # WLR taskbar config
│   │   └── workspace.jsonc         # Workspace config
│   └── style.css                   # Styling for Waybar
└── wlogout
    ├── icons                       # Directory containing icons for Wlogout
    │   ├── boot.svg                # Reboot icon
    │   ├── hibernate.svg           # Hibernate icon
    │   ├── lock.svg                # Lock icon
    │   ├── logout.svg              # Logout icon
    │   ├── power-off.svg           # Power off icon
    │   └── sleep.svg               # Sleep icon
    ├── layout                      # Layout configuration for Wlogout
    └── style.css                   # Styling for Wlogout
```

## Installation

To use this configuration, clone the repository and place the contents in your `~/.config` directory.  
You can use `grep` to find specific actions within the configuration files and follow the instructions for completing the installation. 

```bash
git clone https://github.com/hdg-zero/hdg-hyprland.git
cp -r hdg-hyprland/.config/* ~/.config/
```

After copying the files, you can run the following command to search for specific actions:

```bash
grep -r "ACTION" ~/.config/
```

Replace `"ACTION"` with the specific term you are looking for to find relevant instructions in the configuration files. Make sure to adjust any paths or settings according to your personal preferences and system setup.

## Customization

Feel free to modify the configuration files to suit your needs. Each component has its own configuration file, and you can refer to the respective documentation for more details on customization options.

## Dependencies

Make sure you have the following packages installed on your NixOS system:

- Hyprland
- Rofi
- SwayNC
- Waybar
- Wlogout

## Acknowledgments

A special thanks to the following repositories for their inspiration :

- [HyprNova](https://github.com/zDyanTB/HyprNova)
- [eispalast's dotfiles](https://github.com/eispalast/dotfiles)
- [elifouts' Dotfiles](https://github.com/elifouts/Dotfiles)
- [Anik200's dotfiles](https://github.com/Anik200/dotfiles)
- [Seme4eg's dotfiles](https://github.com/Seme4eg/dotfiles)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

Feel free to open issues or submit pull requests if you have suggestions or improvements! Enjoy customizing your Hyprland experience on NixOS!