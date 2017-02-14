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

    property string title: ""
    property string author: ""
    property var updated: null
    property string streamTitle: ""
    readonly property string pageType: "articleInfo"

    SilicaFlickable {
        id: articleView

        anchors.fill: parent
        contentHeight: header.height + articleContainer.height

        PageHeader {
            id: header

            title: qsTr("Article Info")
        }

        Column {
            id: articleContainer

            anchors.top: header.bottom
            width: parent.width
            spacing: Theme.paddingLarge

            Label {
                id: articleTitle

                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                wrapMode: Text.WordWrap
                text: page.title
                color: Theme.highlightColor
            }

            DetailItem {
                width: parent.width
                label: qsTr("Via")
                value: page.streamTitle
            }

            DetailItem {
                width: parent.width
                label: qsTr("Author");
                value: page.author;
            }

            DetailItem {
                width: parent.width
                label: qsTr("Published on");
                value: Qt.formatDateTime(page.updated);
            }
        }
    }
}
