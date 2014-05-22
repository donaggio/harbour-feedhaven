/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: page

    property string title: ""
    property string author: ""
    property var updated: null
    property string streamTitle: ""
    readonly property string pageType: "articleInfo"

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: articleView

        anchors.fill: parent
        contentHeight: articleContainer.height

        Column {
            id: articleContainer

            width: page.width - (2 * Theme.paddingLarge)
            x: Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Article Info")
            }

            Label {
                id: articleTitle

                width: parent.width
                wrapMode: Text.WordWrap
                text: page.title
                color: Theme.highlightColor
            }

            Field {
                width: parent.width
                fieldName: qsTr("Via");
                fieldValue: page.streamTitle;
            }

            Field {
                width: parent.width
                fieldName: qsTr("Author");
                fieldValue: page.author;
            }

            Field {
                width: parent.width
                fieldName: qsTr("Published on");
                fieldValue: Qt.formatDateTime(page.updated);
            }
        }
    }
}
