import QtQuick
import Quickshell

// Un cadre identique pour CPU, RAM, réseau, luminosité, batterie et volume.
ModulePopup {
    cardWidth: PopupStyle.metricWidth
    cardHeight: PopupStyle.metricHeight
    keepAspectRatio: true
    contentPadding: 12
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.SlideY
}
