/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: errorIndicator

    property string _defaultErrorMessage: qsTr("Feedly connection error")

    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
    width: parent.width
    height: labelErrorMessage.height
    color: Theme.highlightBackgroundColor
    opacity: 0.6
    visible: false

    /*
     * Show error indicator
     */
    function show(message) {
        labelErrorMessage.text = (message ? message : _defaultErrorMessage);
        errorIndicator.opacity = 0.6;
        errorIndicator.visible = true;
        errorTimer.restart();
    }

    Image {
        id: iconError

        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: Theme.paddingSmall }
        source: "image://theme/icon-system-warning"
    }

    Label {
        id: labelErrorMessage

        anchors { top: parent.top; left: iconError.right; right: parent.right; leftMargin: Theme.paddingSmall }
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
