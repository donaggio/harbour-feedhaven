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

    property string title
    property string streamId
    property int unreadCount
    readonly property string pageType: "articlesList"

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaListView {
        id: articlesListView

        property Item contextMenu

        anchors.fill: parent
        visible: !feedly.busy
        spacing: Theme.paddingMedium

        header: PageHeader {
            title: page.title
        }

        model: feedly.articlesListModel
        delegate: ListItem {
            id: articleItem

            property bool menuOpen: ((articlesListView.contextMenu != null) && (articlesListView.contextMenu.parent === articleItem))

            width: articlesListView.width
            contentHeight: menuOpen ? articlesListView.contextMenu.height + Theme.itemSizeExtraLarge : Theme.itemSizeExtraLarge

            Item {
                id: articleText

                anchors { top: parent.top; left: parent.left; right: articleVisual.left; leftMargin: Theme.paddingLarge; rightMargin: (articleVisual.width ? Theme.paddingSmall : 0) }

                GlassItem {
                    id: unreadIndicator

                    width: Theme.itemSizeExtraSmall
                    height: width
                    x: -(Theme.paddingLarge + (width / 2))
                    anchors.verticalCenter: articleTitle.verticalCenter
                    color: Theme.highlightColor
                    visible: (unread || unreadIndBusyAnimation.running)

                    ParallelAnimation {
                        id: unreadIndBusyAnimation

                        running: (busy && Qt.application.active)

                        SequentialAnimation {
                            loops: Animation.Infinite

                            NumberAnimation { target: unreadIndicator; property: "brightness"; to: 0.4; duration: 750 }
                            NumberAnimation { target: unreadIndicator; property: "brightness"; to: 1.0; duration: 750 }
                        }

                        SequentialAnimation {
                            loops: Animation.Infinite

                            NumberAnimation { target: unreadIndicator; property: "falloffRadius"; to: 0.075; duration: 750 }
                            NumberAnimation { target: unreadIndicator; property: "falloffRadius"; to: unreadIndicator.defaultFalloffRadius; duration: 750 }
                        }

                        onRunningChanged: {
                            if (!running) {
                                unreadIndicator.brightness = 1.0;
                                unreadIndicator.falloffRadius = unreadIndicator.defaultFalloffRadius;
                            }
                        }
                    }
                }

                Label {
                    id: articleTitle

                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                    text: title
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    id: articleSummary

                    anchors { top: articleTitle.bottom; left: parent.left; right: parent.right; }
                    clip: true
                    font.pixelSize: Theme.fontSizeExtraSmall
                    elide: Text.ElideRight
                    maximumLineCount: 3
                    wrapMode: Text.WordWrap
                    text: summary
                    color: highlighted ? (unread ? Theme.highlightColor : Theme.secondaryHighlightColor) : (unread ? Theme.primaryColor : Theme.secondaryColor)
                }
            }

            Image {
                id: articleVisual

                anchors { top: parent.top; right: parent.right; rightMargin: Theme.paddingLarge }
                width: 0
                height: parent.height
                sourceSize.width: parent.height * 2
                sourceSize.height: parent.height * 2
                fillMode: Image.PreserveAspectCrop
                smooth: true
                clip: true
                source: imgUrl

                Behavior on width {
                    NumberAnimation { duration: 500 }
                }

                Connections {
                    target: page

                    onIsLandscapeChanged: {
                        if (page.isLandscape && (articleVisual.status === Image.Ready)) articleVisual.width = height;
                        else articleVisual.width = 0;
                    }
                }

                onStatusChanged: { if (page.isLandscape && (status === Image.Ready)) width = height; }
            }

            onClicked: {
                if (unread) {
                    feedly.markEntryAsReadUnread(id);
                    page.unreadCount--;
                }
                feedly.currentEntry = articlesListView.model.get(index);
                pageStack.push(Qt.resolvedUrl("ArticlePage.qml"));
            }

            onPressAndHold: {
                if (!articlesListView.contextMenu) articlesListView.contextMenu = contextMenuComponent.createObject(articlesListView);
                articlesListView.contextMenu.modelIndex = index;
                articlesListView.contextMenu.articleId = id;
                articlesListView.contextMenu.articleUnread = unread;
                articlesListView.contextMenu.articleUrl = contentUrl;
                articlesListView.contextMenu.show(articleItem)
            }
        }

        section.property: "sectionLabel"
        section.delegate: SectionHeader { text: section }

        Component {
            id: contextMenuComponent

            ContextMenu {
                id: contextMenu

                property int modelIndex
                property string articleId
                property bool articleUnread
                property string articleUrl

                MenuItem {
                    text: (contextMenu.articleUnread ? qsTr("Mark as read") : qsTr("Keep unread"))
                    onClicked: {
                        feedly.markEntryAsReadUnread(contextMenu.articleId, !contextMenu.articleUnread);
                        if (contextMenu.articleUnread) page.unreadCount--;
                        else page.unreadCount++;
                    }
                }

                MenuItem {
                    visible: (articlesListView.count && page.unreadCount && (contextMenu.modelIndex < (articlesListView.count - 1)))
                    text: qsTr("Mark older as read")
                    onClicked: remorsePopup.execute(qsTr("Marking older articles as read"), function() { feedly.markFeedAsRead(streamId, contextMenu.articleId); })
                }

                MenuItem {
                    visible: (contextMenu.articleUrl ? true : false)
                    text: qsTr("Open original link")
                    onClicked: Qt.openUrlExternally(contextMenu.articleUrl)
                }
            }
        }

        PullDownMenu {
            MenuItem {
                visible: (articlesListView.count > 0)
                text: qsTr("Mark all as read")
                onClicked: remorsePopup.execute(qsTr("Marking all articles as read"), function() { feedly.markFeedAsRead(streamId, articlesListView.model.get(0).id); })
            }

            MenuItem {
                text: qsTr("Refresh feed")
                onClicked: feedly.getStreamContent(streamId)
            }
        }

        PushUpMenu {
            visible: (articlesListView.count > 0)

            MenuItem {
                visible: (feedly.continuation !== "")
                text: qsTr("More articles")
                onClicked: feedly.getStreamContent(streamId, true)
            }

            MenuItem {
                text: qsTr("Mark all as read")
                onClicked: remorsePopup.execute(qsTr("Marking all articles as read"), function() { feedly.markFeedAsRead(streamId, articlesListView.model.get(0).id); })
            }

            MenuItem {
                visible: ((typeof articlesListView.quickScroll === "undefined") && (articlesListView.count > 10))
                text: qsTr("Back to the top")
                onClicked: articlesListView.scrollToTop();
            }
        }

        ViewPlaceholder {
            enabled: (articlesListView.count == 0)
            text: qsTr("No unread articles in this feed")
        }

        VerticalScrollDecorator { flickable: articlesListView }
    }

    RemorsePopup {
        id: remorsePopup
    }

    Component.onCompleted: {
        feedly.getStreamContent(streamId)
    }

    Component.onDestruction: {
        feedly.articlesListModel.clear();
    }
}
