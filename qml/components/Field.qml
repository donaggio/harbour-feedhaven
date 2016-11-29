/*
  Copyright (C) 2016 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias fieldName: labelFieldName.text
    property alias fieldValue: labelFieldValue.text

    width: childrenRect.width
    height: childrenRect.height

    Label {
        id: labelFieldName

        anchors { top: parent.top; left: parent.left; right: parent.right }
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.secondaryHighlightColor
        truncationMode: TruncationMode.Fade
    }

    Label {
        id: labelFieldValue

        anchors { top: labelFieldName.bottom; left: parent.left; right: parent.right }
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        wrapMode: Text.WordWrap
    }
}
