/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.Portrait || Orientation.Landscape

    Column {
        width: (parent.width - (2 * Theme.paddingMedium))
        x: Theme.paddingMedium
        spacing: Theme.paddingLarge

        PageHeader {
            title: qsTr("About Feed Haven")
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
            font.italic: true
            text: qsTr("Version %1").arg(Qt.application.version)
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            textFormat: Text.StyledText
            linkColor: Theme.highlightColor
            text: qsTr("<p><i>Feed Haven</i> is a native client for Feedly news reader service.</p>
<p>You can access to your subscribed feeds content and to each article's original web page as well.</p>
<p>Subscribing to new feeds is currently not supported, you need to log in to Feedly.com using a web browser in order to manage your feeds.</p>
<p>This is an open source project released under the MIT license, you can find its source code <a href=\"https://code.google.com/p/harbour-feedhaven/source/\">here</a>.</p>")

            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
