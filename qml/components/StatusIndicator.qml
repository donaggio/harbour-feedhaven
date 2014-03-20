import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: feedlyStatusIndicator

    property alias busyIndRunning: busyIndicator.running
    property alias errorIndVisible: errorIndicator.visible
    property string _defaultErrorMessage: qsTr("Feedly connection error")

    /*
     * Show error indicator
     */
    function showErrorIndicator(message) {
        labelErrorMessage.text = (message ? message : _defaultErrorMessage);
        errorIndicator.opacity = 0.6;
        errorIndicator.visible = true;
        errorTimer.restart();
    }

    anchors.fill: parent
    visible: (busyIndRunning || errorIndVisible)
    parent: null

    BusyIndicator {
        id: busyIndicator

        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: false
        visible: running
    }

    Rectangle {
        id: errorIndicator

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: labelErrorMessage.height
        color: Theme.highlightBackgroundColor
        opacity: 0.6
        visible: false

        Image {
            id: iconError

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall

            source: "image://theme/icon-system-warning"
        }

        Label {
            id: labelErrorMessage

            anchors.top: parent.top
            anchors.left: iconError.right
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingSmall

            font.pixelSize: Theme.fontSizeSmall
            color: Theme.highlightColor
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.NoWrap
            truncationMode: TruncationMode.Fade
            text: _defaultErrorMessage
        }

        Timer {
            id: errorTimer

            interval: 3000
            repeat: false

            onTriggered: SequentialAnimation {
                PropertyAnimation { target: errorIndicator; property: "opacity"; to: 0; duration: 300; }
                PropertyAction { target: errorIndicator; property: "visible"; value: false; }
            }
        }
    }
}
