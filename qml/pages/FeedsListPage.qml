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

    allowedOrientations: Orientation.All

    readonly property string pageType: "feedsList"

    SilicaListView {
        id: feedsListView

        property Item contextMenu

        anchors.fill: parent
        visible: !feedly.busy

        header: PageHeader {
            title: qsTr("Your feeds")
        }

        model: feedly.feedsListModel
        delegate: ListItem {
            id: feedItem

            property bool menuOpen: ((feedsListView.contextMenu != null) && (feedsListView.contextMenu.parent === feedItem))

            width: feedsListView.width
            contentHeight: menuOpen ? feedsListView.contextMenu.height + Theme.itemSizeSmall : Theme.itemSizeSmall
            enabled: !busy

            function deleteOrUnsubscribe() {
                remorseItem.execute(feedItem, feedly.streamIsCategory(id) ? qsTr("Deleting") : qsTr("Unsubscribing"));
            }

            Item {
                id: feedDataContainer

                anchors { top: parent.top; left: parent.left; leftMargin: Theme.horizontalPageMargin; right: parent.right; rightMargin: Theme.horizontalPageMargin }
                height: Theme.itemSizeSmall
                visible: (!feedly.streamIsCategory(id) || (id.indexOf("/global.all") >= 0)) && !busy

                Image {
                    id: feedVisual

                    readonly property string _defaultSource: ((feedly.streamIsCategory(id) || feedly.streamIsTag(id)) ? "../../icons/icon-s-feedly.png" : "../../icons/icon-s-rss.png")

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    width: Theme.iconSizeSmall
                    height: width
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    clip: true
                    source: (imgUrl ? imgUrl : _defaultSource)
                    opacity: 0

                    Behavior on opacity { FadeAnimator {} }

                    onStatusChanged: {
                        if (status === Image.Ready) opacity = 1;
                        if (status === Image.Error) source = _defaultSource;
                    }
                }

                Label {
                    anchors {
                        left: feedVisual.right
                        right: unreadCountLabel.left
                        leftMargin: Theme.paddingMedium
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    truncationMode: TruncationMode.Fade
                    text: title
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Label {
                    id: unreadCountLabel

                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    text: unreadCount
                    visible: (unreadCount > 0)
                    color: Theme.highlightColor
                }
            }

            Item {
                id: categoryDataContainer

                anchors { top: parent.top; left: parent.left; leftMargin: Theme.horizontalPageMargin; right: parent.right; rightMargin: Theme.horizontalPageMargin }
                height: Theme.itemSizeSmall
                visible: feedly.streamIsCategory(id) && (id.indexOf("/global.all") === -1) && !busy

                Label {
                    anchors {
                        left: parent.left
                        right: categoryActionVisual.left
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                    truncationMode: TruncationMode.Fade
                    horizontalAlignment: Text.AlignRight
                    text: title
                    color: highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                Image {
                    id: categoryActionVisual

                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    width: Theme.iconSizeMedium
                    height: width
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    clip: true
                    source: "image://theme/icon-m-right?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
                    visible: (unreadCount > 0)
                }
            }

            Rectangle {
                id: gradient

                anchors.fill: parent
                z: -1
                visible: categoryDataContainer.visible
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.3) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            RemorseItem {
                id: remorseItem

                onTriggered: {
                    if (feedly.streamIsCategory(id)) feedly.deleteCategory(id);
                    else feedly.unsubscribe(id);
                }
            }

            BusyIndicator {
                anchors.centerIn: parent

                visible: busy
                size: BusyIndicatorSize.Medium
                running: (visible && Qt.application.active)
            }

            ListView.onAdd: AddAnimation { target: feedItem }

            ListView.onRemove: RemoveAnimation { target: feedItem }

            onClicked: {
                if ((unreadCount > 0) || feedly.streamIsTag(id)) pageStack.push(Qt.resolvedUrl("ArticlesListPage.qml"), { "title": title, "streamId": id, "unreadCount": unreadCount });
            }

            onPressAndHold: {
                if (!busy && (!feedly.streamIsCategory(id) || (id.indexOf("/global.") === -1)) && !feedly.streamIsTag(id)) {
                    if (!feedsListView.contextMenu) feedsListView.contextMenu = contextMenuComponent.createObject(feedsListView);
                    feedsListView.contextMenu.feedId = id;
                    feedsListView.contextMenu.feedTitle = title;
                    feedsListView.contextMenu.feedImgUrl = imgUrl;
                    feedsListView.contextMenu.feedLang = lang;
                    // Convert categories from QQmlListModel back to an Array object
                    var tmpCategories = [];
                    for (var i = 0; i < categories.count; i++) tmpCategories.push({ "id": categories.get(i).id, "label": categories.get(i).label });
                    feedsListView.contextMenu.feedCategories = tmpCategories;
                    feedsListView.contextMenu.visualParent = feedItem;
                    feedsListView.contextMenu.show(feedItem);
                }
            }
        }

        Component {
            id: contextMenuComponent

            ContextMenu {
                id: contextMenu

                property Item visualParent
                property string feedId
                property string feedTitle
                property string feedImgUrl
                property string feedLang
                property var feedCategories

                MenuItem {
                    text: qsTr("Manage feed")
                    visible: !feedly.streamIsCategory(feedId)
                    onClicked: pageStack.push(Qt.resolvedUrl("../dialogs/UpdateFeedDialog.qml"), { "feedId": feedId, "title": feedTitle, "imgUrl": feedImgUrl, "lang": feedLang, "categories": feedCategories })
                }

                MenuItem {
                    text: feedly.streamIsCategory(feedId) ? qsTr("Delete category") : qsTr("Unsubscribe")
                    onClicked: visualParent.deleteOrUnsubscribe();
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }

            MenuItem {
                text: (feedly.signedIn ? qsTr("Sign out") : qsTr("Sign in"))
                onClicked: {
                    if (feedly.signedIn) feedly.revokeRefreshToken();
                    else pageStack.push(Qt.resolvedUrl("SignInPage.qml"));
                }
            }

            MenuItem {
                text: qsTr("Add feed")
                visible: feedly.signedIn
                onClicked: pageStack.push(Qt.resolvedUrl("FeedSearchPage.qml"))
            }

            MenuItem {
                text: qsTr("Refresh feeds")
                visible: feedly.signedIn
                onClicked: feedly.getSubscriptions()
            }
        }

        ViewPlaceholder {
            enabled: (feedsListView.count == 0)
            text: (feedly.signedIn ? qsTr("Feeds list not available") : qsTr("Please sign in"))
        }

        VerticalScrollDecorator {
            flickable: feedsListView
        }

    }
}


