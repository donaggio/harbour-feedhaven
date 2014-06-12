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

    readonly property string pageType: "about"

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: aboutFlickable

        anchors.fill: parent
        contentHeight: aboutContainer.height

        Column {
            id: aboutContainer

            width: (parent.width - (2 * Theme.paddingLarge))
            x: Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About Feed Haven")
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeSmall
                font.italic: true
                wrapMode: Text.WordWrap
                text: qsTr("Version %1\n(C) 2014 by Luca Donaggio").arg(Qt.application.version)
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                linkColor: Theme.highlightColor
                text: qsTr("<p><i>Feed Haven</i> is a native client for Feedly.com on-line news reader service.</p>
    <p>You can search for and subscribe to new feeds, manage your feeds and access their content: as soon as you'll read an article, it will be marked as read on Feedly.com as well.</p>
    <p>Image thumbnails in article list are displayed in landscape mode only.</p>
    <p>This is an open source project released under the MIT license, source code is available <a href=\"https://code.google.com/p/harbour-feedhaven/source/\">here</a>.</p>
    <p>Issues or feature requests can be reported <a href=\"https://code.google.com/p/harbour-feedhaven/issues/\">here</a>.</p>
    <p>Launcher icon artwork courtesy by Nikita Balobanov.</p>")

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }

        VerticalScrollDecorator { flickable: aboutFlickable }
    }
}
