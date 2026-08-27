pragma Singleton
import QtQuick

QtObject {
    id: root

    // --- Couleurs du Thème (Obsidian Glass & Glacier Blue) ---
    readonly property color background: Qt.rgba(0.043, 0.059, 0.078, 0.88)         // #0b0f14 @ 88%
    readonly property color backgroundSolid: "#0b0f14"
    readonly property color cardBackground: Qt.rgba(0.071, 0.098, 0.125, 0.94)     // #121920 @ 94%
    readonly property color cardBackgroundSolid: "#121920"
    readonly property color cardBackgroundHover: Qt.rgba(0.137, 0.184, 0.235, 0.98)// #232f3c @ 98%
    
    readonly property color glassHighlight: Qt.rgba(1.0, 1.0, 1.0, 0.05)
    readonly property color glassBorder: Qt.rgba(0.365, 0.678, 0.886, 0.25)        // Glacier blue 25%
    readonly property color glassBorderSubtle: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    
    readonly property color accent: "#5dade2"                                       // Glacier Blue
    readonly property color accentSecondary: "#85c1e9"                              // Glacier Light Blue
    readonly property color accentHover: "#7fc1eb"
    readonly property color accentLight: "#e0f2f1"
    
    readonly property color textPrimary: "#f8fafc"                                 // Blanc glacé
    readonly property color textSecondary: "#94a3b8"                               // Slate doux
    readonly property color textDisabled: "#64748b"                                // Slate atténué
    
    readonly property color warning: "#ffb86c"
    readonly property color destructive: "#ff6b6b"
    readonly property color success: "#2ecc71"

    // --- Typographie & Polices ---
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSizeMicro: 9
    readonly property int fontSizeTiny: 10
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeRegular: 12
    readonly property int fontSizeMedium: 13
    readonly property int fontSizeLarge: 15
    readonly property int fontSizeHeader: 17
    readonly property int fontSizeTitle: 20

    // --- Espacements & Marges Relatifs ---
    readonly property int spacingXs: 3
    readonly property int spacingSm: 6
    readonly property int spacingMd: 10
    readonly property int spacingLg: 14
    readonly property int spacingXl: 20

    // --- Rayons de bordure Relatifs (Border Radius) ---
    readonly property real radiusSmall: 5
    readonly property real radiusMedium: 8
    readonly property real radiusLarge: 12
    readonly property real radiusXLarge: 16
    readonly property real radiusPill: 9999

    // --- Ratios & Dimensions Relatifs d'Écran ---
    readonly property real barHeightRatio: 0.028       // ~30px sur 1080p, ~40px sur 1440p

    // Pourcentages de largeur pour modules de la barre
    readonly property real moduleWidthPercentMetrics: 0.03   // CPU, RAM, Réseau
    readonly property real moduleWidthPercentMpris: 0.10     // Musique

    // Pourcentages de largeur pour popups
    readonly property real popupWidthPercentNarrow: 0.09     // Power, Backlight
    readonly property real popupWidthPercentCompact: 0.10    // CPU, RAM, Volume, Battery
    readonly property real popupWidthPercentStandard: 0.115  // Network, Clock, App
    readonly property real popupWidthPercentWide: 0.13       // MPRIS

    // Fonctions d'aide au dimensionnement relatif
    function relWidth(ratio, screen) {
        var w = (screen && screen.width > 0) ? screen.width : 1920;
        return Math.round(w * ratio);
    }

    function relHeight(ratio, screen) {
        var h = (screen && screen.height > 0) ? screen.height : 1080;
        return Math.round(h * ratio);
    }

    // --- Animations & Transitions ---
    readonly property int animDurationFast: 150
    readonly property int animDurationNormal: 200
    readonly property int animDurationSlow: 300
    readonly property int easingType: Easing.OutCubic
}
