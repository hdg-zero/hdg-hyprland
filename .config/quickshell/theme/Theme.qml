pragma Singleton
import QtQuick

QtObject {
    id: root

    // --- Couleurs du Thème (Obsidian Glass & Glacier Blue) ---
    readonly property color background: Qt.rgba(0.043, 0.059, 0.078, 0.85)         // #0b0f14 @ 85%
    readonly property color backgroundSolid: "#0b0f14"
    readonly property color cardBackground: Qt.rgba(0.071, 0.098, 0.125, 0.92)     // #121920 @ 92%
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
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeRegular: 13
    readonly property int fontSizeMedium: 14
    readonly property int fontSizeLarge: 16
    readonly property int fontSizeHeader: 18
    readonly property int fontSizeTitle: 22

    // --- Espacements & Paddings ---
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 24

    // --- Rayons de bordure (Border Radius) ---
    readonly property real radiusSmall: 8
    readonly property real radiusMedium: 12
    readonly property real radiusLarge: 16
    readonly property real radiusXLarge: 20
    readonly property real radiusPill: 9999

    // --- Animations & Transitions ---
    readonly property int animDurationFast: 150
    readonly property int animDurationNormal: 200
    readonly property int animDurationSlow: 300
    readonly property int easingType: Easing.OutCubic
}
