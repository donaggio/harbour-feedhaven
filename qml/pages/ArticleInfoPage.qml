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

            Loader {
                width: parent.width
                sourceComponent: fieldComponent

                onLoaded: {
                    item.fieldName = qsTr("Via");
                    item.fieldValue = page.streamTitle;
                }
            }

            Loader {
                width: parent.width
                sourceComponent: fieldComponent

                onLoaded: {
                    item.fieldName = qsTr("Author");
                    item.fieldValue = page.author;
                }
            }

            Loader {
                width: parent.width
                sourceComponent: fieldComponent

                onLoaded: {
                    item.fieldName = qsTr("Published on");
                    item.fieldValue = Qt.formatDateTime(page.updated);
                }
            }
        }
    }

    Component {
        id: fieldComponent

        Item {
            property alias fieldName: labelFieldName.text
            property alias fieldValue: labelFieldValue.text

            width: childrenRect.width
            height: childrenRect.height

            Label {
                id: labelFieldName

                anchors { top: parent.top; left: parent.left; right: parent.right }
                truncationMode: TruncationMode.Fade
            }

            Label {
                id: labelFieldValue

                anchors { top: labelFieldName.bottom; left: parent.left; right: parent.right }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }
        }
    }
}
