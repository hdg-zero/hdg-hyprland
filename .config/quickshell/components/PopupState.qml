pragma Singleton
import QtQuick

QtObject {
    property var currentPopup: null

    function registerPopup(popup) {
        var previous = currentPopup;
        currentPopup = popup;
        if (previous && previous !== popup) previous.close();
    }
    function unregisterPopup(popup) {
        if (currentPopup === popup) currentPopup = null;
    }
}
