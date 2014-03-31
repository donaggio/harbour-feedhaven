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
    property string imgUrl: ""
    property string content: ""
    property string contentUrl: ""
    property ListModel galleryModel

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: articleView

        anchors.fill: parent
        contentHeight: articleContainer.height
        visible: (feedly.currentEntry !== null)

        Column {
            id: articleContainer

            width: page.width - (2 * Theme.paddingLarge)
            x: Theme.paddingLarge
            spacing: Theme.paddingSmall

            PageHeader {
                title: page.title
            }

            Label {
                id: articleTitle

                width: parent.width
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
                text: page.title
            }

            Label {
                id: articleAuthorDate

                width: parent.width
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("by %1, published on: %2").arg(page.author).arg(Qt.formatDateTime(page.updated))
            }

            SlideshowView {
                id: articleGalleryView
                width: parent.width
                height: (Theme.itemSizeExtraLarge * 2)
                itemWidth: width
                itemHeight: height
                clip: true
                visible: (count > 0)

                model: page.galleryModel
                delegate: Image {
                    id: articleVisual

                    width: articleGalleryView.width
                    height: articleGalleryView.height
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    clip: true
                    source: ((typeof model.imgUrl !== "undefined") ? model.imgUrl : "")
                    visible: (source != "")

                    onPaintedWidthChanged: {
                        if (paintedWidth < width) {
                            width = paintedWidth;
                            fillMode = Image.Pad;
                        }
                    }

                    onPaintedHeightChanged: {
                        if (paintedHeight < height) {
                            height = paintedHeight;
                            fillMode = Image.Pad;
                        }
                    }

                    onStatusChanged: { if (status === Image.Error) articleGalleryView.model.remove(index); }
                }
            }

            Label {
                id: articleContent

                width: parent.width
                horizontalAlignment: Text.AlignJustify
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: "<style>a:link { color: " + Theme.highlightColor + "; }</style>" + page.content;

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }

        PullDownMenu {
            property bool showMenu: (page.contentUrl !== "")

            visible: showMenu

            MenuItem {
                text: qsTr("Open original link")
                onClicked: Qt.openUrlExternally(page.contentUrl);
            }
        }

        VerticalScrollDecorator { flickable: articleView }
    }

    Connections {
        target: feedly

        onCurrentEntryChanged: {
            if (feedly.currentEntry !== null) {
                title = feedly.currentEntry.title;
                author = feedly.currentEntry.author;
                updated = new Date(feedly.currentEntry.updated);
                imgUrl = feedly.currentEntry.imgUrl;
                content = feedly.currentEntry.content;
                contentUrl = feedly.currentEntry.contentUrl;
                galleryModel = feedly.currentEntry.gallery;
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) feedly.acquireStatusIndicator(page);
    }

    Component.onCompleted: {
        if (feedly.currentEntry !== null) {
            title = feedly.currentEntry.title;
            author = feedly.currentEntry.author;
            updated = new Date(feedly.currentEntry.updated);
            imgUrl = feedly.currentEntry.imgUrl;
            content = feedly.currentEntry.content;
            contentUrl = feedly.currentEntry.contentUrl;
            galleryModel = feedly.currentEntry.gallery;
        }
    }
}
