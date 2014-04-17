/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    Label {
        id: labelTitle

        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: Theme.paddingMedium; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        maximumLineCount: 8
        elide: Text.ElideRight
        text: (feedly.currentEntry !== null) ? "\"" + feedly.currentEntry.title + "\"" : qsTr("No article selected")
    }

    Label {
        id: labelFeedTitle

        anchors { bottom: parent.bottom; left: parent.left; right: parent.right; bottomMargin: Theme.paddingMedium; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
        wrapMode: Text.NoWrap
        truncationMode: TruncationMode.Fade
        color: Theme.highlightColor
        text: (feedly.currentEntry !== null) ? feedly.currentEntry.streamTitle : ""
    }
}
