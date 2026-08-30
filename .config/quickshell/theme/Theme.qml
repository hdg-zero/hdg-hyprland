pragma Singleton
import QtQuick
import Quickshell

Singleton {
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

    // --- Typographie & Polices Augmentées ---
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSizeMicro: 11
    readonly property int fontSizeTiny: 12
    readonly property int fontSizeSmall: 13
    readonly property int fontSizeRegular: 14
    readonly property int fontSizeMedium: 16
    readonly property int fontSizeLarge: 18
    readonly property int fontSizeHeader: 20
    readonly property int fontSizeTitle: 24

    // --- Espacements & Marges Relatifs ---
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 22

    // --- Rayons de bordure Relatifs (Border Radius) ---
    readonly property real radiusSmall: 6
    readonly property real radiusMedium: 10
    readonly property real radiusLarge: 14
    readonly property real radiusXLarge: 18
    readonly property real radiusPill: 9999

    // --- Épaisseur des barres et jauges (Progress bars & Sliders) ---
    readonly property int progressBarHeight: 8
    readonly property int progressBarMiniHeight: 6

    // --- Ratios & Dimensions Relatifs d'Écran ---
    readonly property real barHeightRatio: 0.024       // ~25-26px sur 1080p, ~34px sur 1440p

    // Pourcentages de largeur pour modules de la barre
    readonly property real moduleWidthPercentMetrics: 0.038   // CPU, RAM, Réseau
    readonly property real moduleWidthPercentMpris: 0.12      // Musique

    // Pourcentages de largeur pour popups
    readonly property real popupWidthPercentNarrow: 0.11      // Power, Backlight
    readonly property real popupWidthPercentCompact: 0.125    // CPU, RAM, Volume, Battery
    readonly property real popupWidthPercentStandard: 0.14    // Network, Clock, App
    readonly property real popupWidthPercentWide: 0.16        // MPRIS

    // Dimensions fixes standardisées pour les panneaux d'overlay (indépendantes du ratio d'écran)
    readonly property int notificationPanelWidth: 380
    readonly property int notificationToastWidth: 360

    // Fonctions d'aide au dimensionnement relatif
    function relWidth(ratio, screen) {
        var w = (screen && screen.width > 0) ? screen.width : 1920;
        return Math.round(w * ratio);
    }

    function relHeight(ratio, screen) {
        var h = (screen && screen.height > 0) ? screen.height : 1080;
        return Math.round(h * ratio);
    }

    // Fonction de formatage des débits de transfert de données
    function formatSpeed(bytesPerSec) {
        if (bytesPerSec < 1024) {
            return Math.round(bytesPerSec) + " o/s";
        } else if (bytesPerSec < 1048576) {
            return (bytesPerSec / 1024).toFixed(1) + " Ko/s";
        } else if (bytesPerSec < 1073741824) {
            return (bytesPerSec / 1048576).toFixed(1) + " Mo/s";
        } else {
            return (bytesPerSec / 1073741824).toFixed(2) + " Go/s";
        }
    }

    // --- Animations & Transitions ---
    readonly property int animDurationFast: 150
    readonly property int animDurationNormal: 200
    readonly property int animDurationSlow: 300
    readonly property int easingType: Easing.OutCubic
}
