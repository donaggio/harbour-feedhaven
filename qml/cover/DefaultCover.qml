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

    /*
     * Cover background
     */
    Image {
        x: -Theme.paddingLarge
        y: x
        source: "../../icons/cover-background.png"
    }

    /*
     * Default cover
     */
    Column {
        id: allFeedsInfoContainer

        anchors { top: parent.top; topMargin: Theme.paddingLarge }
        width: cover.width - (2 * Theme.paddingLarge)
        x: Theme.paddingLarge
        spacing: Theme.paddingSmall
        visible: true

        Item {
            width: parent.width
            height: Theme.itemSizeSmall

            Label {
                id: labelUnreadNum

                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Theme.itemSizeSmall

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.NoWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                text: feedly.totalUnread
            }

            Label {
                id: labelUnreadText

                anchors.left: labelUnreadNum.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: Theme.paddingSmall

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Unread\narticles")
            }
        }

        Item {
            width: parent.width
            height: Theme.itemSizeSmall

            Label {
                id: labelFeedsNum

                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Theme.itemSizeSmall

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.NoWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                text: feedly.uniqueFeeds
            }

            Label {
                id: labelFeedsText

                anchors.left: labelFeedsNum.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: Theme.paddingSmall

                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Subscribed\nfeeds")
            }
        }
    }

    /*
     * Article list cover
     */
    Column {
        id: singleFeedInfoContainer

        anchors { top: parent.top; topMargin: Theme.paddingMedium }
        width: cover.width - (2 * Theme.paddingMedium)
        x: Theme.paddingMedium
        spacing: Theme.paddingMedium
        visible: false

        Label {
            id: labelFeedTitle

            width: parent.width
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 3
            elide: Text.ElideRight
            color: Theme.highlightColor
            text: (typeof pageStack.currentPage.title !== "undefined") ? pageStack.currentPage.title : ""
        }

        Row {
            anchors.leftMargin: Theme.paddingLarge - Theme.paddingMedium
            height: Theme.itemSizeSmall
            spacing: Theme.paddingSmall

            Label {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.itemSizeSmall

                horizontalAlignment: Text.AlignRight
                wrapMode: Text.NoWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                text: ((typeof pageStack.currentPage.streamId !== "undefined") ? (feedly.streamIsTag(pageStack.currentPage.streamId) ? feedly.articlesListModel.count : pageStack.currentPage.unreadCount) : "0") // (typeof pageStack.currentPage.unreadCount !== "undefined") ? pageStack.currentPage.unreadCount : "0"
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter

                font.pixelSize: Theme.fontSizeTiny
                text: ((typeof pageStack.currentPage.streamId !== "undefined") && feedly.streamIsTag(pageStack.currentPage.streamId)) ? qsTr("Saved\narticles") : qsTr("Unread\narticles")
            }
        }
    }

    /*
     * Article content cover
     */
    Item {
        id: articleContentContainer

        anchors { fill: parent; topMargin: Theme.paddingMedium; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium; bottomMargin: Theme.paddingMedium; }
        visible: false

        Label {
            anchors { top: parent.top; left: parent.left; right: parent.right; }
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            maximumLineCount: 8
            elide: Text.ElideRight
            text: (feedly.currentEntry !== null) ? "\"" + feedly.currentEntry.title + "\"" : qsTr("No article selected")
        }

        Label {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right; }
            wrapMode: Text.NoWrap
            truncationMode: TruncationMode.Fade
            color: Theme.highlightColor
            text: (feedly.currentEntry !== null) ? feedly.currentEntry.streamTitle : ""
        }
    }

    /*
     * Feedly component busy cover
     */
    Label {
        id: labelLoading

        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.NoWrap
        truncationMode: TruncationMode.Fade
        color: Theme.highlightColor
        text: qsTr("Updating ...")
        visible: false

        SequentialAnimation on opacity {
            running: (parent.visible && (cover.status === Cover.Active))
            loops: Animation.Infinite

            NumberAnimation { to: 0; duration: 1000 }
            NumberAnimation { to: 1; duration: 1000 }
        }
    }

    /*
     * Feedly component not signed in cover
     */
    Label {
        id: labelNotSignedIn

        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Theme.paddingMedium; rightMargin: Theme.paddingMedium }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.highlightColor
        text: qsTr("Not signed in")
        visible: false
    }

    /*
     * Feeds list actions
     */
    CoverActionList {
        id: actionsAllFeedList

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: feedly.getSubscriptions();
        }
    }

    /*
     * Article list actions
     */
    CoverActionList {
        id: actionsSingleFeedList

        enabled: false

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: feedly.getStreamContent(pageStack.currentPage.streamId)
        }
    }

    states: [
        State {
            name: "busy"
            when: feedly.busy

            PropertyChanges {
                target: allFeedsInfoContainer
                visible: false
            }

            PropertyChanges {
                target: singleFeedInfoContainer
                visible: false
            }

            PropertyChanges {
                target: articleContentContainer
                visible: false
            }

            PropertyChanges {
                target: labelNotSignedIn
                visible: false
            }

            PropertyChanges {
                target: actionsAllFeedList
                enabled: false
            }

            PropertyChanges {
                target: actionsSingleFeedList
                enabled: false
            }

            PropertyChanges {
                target: labelLoading
                visible: true
            }
        },

        State {
            name: "notSignedIn"
            when: (!feedly.signedIn && !feedly.busy)

            PropertyChanges {
                target: allFeedsInfoContainer
                visible: false
            }

            PropertyChanges {
                target: singleFeedInfoContainer
                visible: false
            }

            PropertyChanges {
                target: articleContentContainer
                visible: false
            }

            PropertyChanges {
                target: labelLoading
                visible: false
            }

            PropertyChanges {
                target: actionsAllFeedList
                enabled: false
            }

            PropertyChanges {
                target: actionsSingleFeedList
                enabled: false
            }

            PropertyChanges {
                target: labelNotSignedIn
                visible: true
            }
        },

        State {
            name: "articlesList"
            when: (pageStack.currentPage.pageType === "articlesList")

            PropertyChanges {
                target: allFeedsInfoContainer
                visible: false
            }

            PropertyChanges {
                target: singleFeedInfoContainer
                visible: true
            }

            PropertyChanges {
                target: articleContentContainer
                visible: false
            }

            PropertyChanges {
                target: labelLoading
                visible: false
            }

            PropertyChanges {
                target: labelNotSignedIn
                visible: false
            }

            PropertyChanges {
                target: actionsAllFeedList
                enabled: false
            }

            PropertyChanges {
                target: actionsSingleFeedList
                enabled: true
            }
        },

        State {
            name: "articleContent"
            when: ((pageStack.currentPage.pageType === "articleContent") || (pageStack.currentPage.pageType === "articleInfo") || (pageStack.currentPage.pageType === "articleShare"))

            PropertyChanges {
                target: allFeedsInfoContainer
                visible: false
            }

            PropertyChanges {
                target: singleFeedInfoContainer
                visible: false
            }

            PropertyChanges {
                target: articleContentContainer
                visible: true
            }

            PropertyChanges {
                target: labelLoading
                visible: false
            }

            PropertyChanges {
                target: labelNotSignedIn
                visible: false
            }

            PropertyChanges {
                target: actionsAllFeedList
                enabled: false
            }

            PropertyChanges {
                target: actionsSingleFeedList
                enabled: false
            }
        },

        State {
            name: "feedsList"
            when: ((pageStack.currentPage.pageType !== "articleContent") && (pageStack.currentPage.pageType !== "articleInfo") && (pageStack.currentPage.pageType !== "articleShare") && (pageStack.currentPage.pageType !== "articlesList"))

            PropertyChanges {
                target: allFeedsInfoContainer
                visible: true
            }

            PropertyChanges {
                target: singleFeedInfoContainer
                visible: false
            }

            PropertyChanges {
                target: articleContentContainer
                visible: false
            }

            PropertyChanges {
                target: labelLoading
                visible: false
            }

            PropertyChanges {
                target: labelNotSignedIn
                visible: false
            }

            PropertyChanges {
                target: actionsAllFeedList
                enabled: true
            }

            PropertyChanges {
                target: actionsSingleFeedList
                enabled: false
            }
        }
    ]
}
