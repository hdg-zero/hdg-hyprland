import QtQuick
import "../theme"

Text {
    font.family: PopupStyle.fontFamily
    font.pixelSize: Theme.fontSizeSmall
    color: Theme.textPrimary
    textFormat: Text.PlainText
    elide: Text.ElideRight
}
