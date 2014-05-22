/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: busyIndicator

    anchors.fill: parent
    visible: false

    Column {
        id: busyContainer

        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: Theme.paddingSmall

        Label {
            id: labelBusyMessage

            width: parent.width
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.highlightColor
            wrapMode: Text.NoWrap
            truncationMode: TruncationMode.Fade
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Updating ...")
        }

        BusyIndicator {
            id: indicator

            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            running: busyIndicator.visible
        }
    }
}

