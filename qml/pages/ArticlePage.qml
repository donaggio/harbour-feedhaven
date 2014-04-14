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
    property string content: ""
    property string contentUrl: ""
    property ListModel galleryModel

    function update() {
        if (feedly.currentEntry !== null) {
            title = feedly.currentEntry.title;
            content = feedly.currentEntry.content;
            contentUrl = feedly.currentEntry.contentUrl;
            galleryModel = feedly.currentEntry.gallery;
            var articleInfoProp = { "title": feedly.currentEntry.title,
                                    "author": feedly.currentEntry.author,
                                    "updated": new Date(feedly.currentEntry.updated),
                                    "streamTitle": feedly.currentEntry.streamTitle };
            pageContainer.pushAttached(Qt.resolvedUrl("ArticleInfoPage.qml"), articleInfoProp);
        }
    }

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: articleView

        anchors.fill: parent
        contentHeight: articleContainer.height
        visible: (feedly.currentEntry !== null)

        Column {
            id: articleContainer

            width: parent.width - (2 * Theme.paddingLarge)
            x: Theme.paddingLarge
            spacing: Theme.paddingSmall

            PageHeader {
                title: page.title
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

                    property bool _removed: false

                    width: articleGalleryView.width
                    height: articleGalleryView.height
                    fillMode: Image.Pad
                    smooth: true
                    clip: true
                    source: ((typeof model.imgUrl !== "undefined") ? model.imgUrl : "")

                    function removeFromModel() {
                        if (!_removed) {
                            _removed = true;
                            parent.model.remove(index);
                        }
                    }

                    BusyIndicator {
                        anchors.centerIn: parent
                        size: BusyIndicatorSize.Medium
                        running: (parent.status === Image.Loading)
                        visible: running
                    }

                    onStatusChanged: { if (status === Image.Error) removeFromModel(); }

                    onPaintedWidthChanged: {
                        if (paintedWidth > width) fillMode = Image.PreserveAspectFit;
                        if ((paintedWidth > 0) && (paintedWidth <= Theme.iconSizeSmall)) removeFromModel();
                    }

                    onPaintedHeightChanged: {
                        if (paintedHeight > height) fillMode = Image.PreserveAspectFit;
                        if ((paintedWidth > 0) && (paintedHeight <= Theme.iconSizeSmall)) removeFromModel();
                    }
                }
            }

            Label {
                id: articleContent

                readonly property string _linkStyle: "<style>a:link { color: " + Theme.highlightColor + "; }</style>"

                width: parent.width
                horizontalAlignment: Text.AlignJustify
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: _linkStyle + page.content;

                onLinkActivated: Qt.openUrlExternally(link)

                onWidthChanged: {
                    // This is needed as a workaround for the following bug:
                    // if textFormat === Text.RichText text does not reflow when width changes
                    if (text) {
                        var tmpText = text;
                        text = "";
                        text = tmpText;
                    }
                }
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

        onCurrentEntryChanged: update();
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) feedly.acquireStatusIndicator(page);
        if (status === PageStatus.Active) update();
    }

}
