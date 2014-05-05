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

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaListView {
        id: feedsListView
        anchors.fill: parent
        visible: !feedly.busy

        header: PageHeader {
            title: qsTr("Your feeds")
        }

        model: feedly.feedsListModel
        delegate: ListItem {
            id: feedItem

            width: feedsListView.width
            contentHeight: Theme.itemSizeSmall

            Image {
                id: feedVisual

                readonly property string _defaultSource: "../../icons/icon-s-rss.png" // "image://theme/icon-s-sailfish"

                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                width: Theme.iconSizeSmall
                height: width
                fillMode: Image.PreserveAspectFit
                smooth: true
                clip: true
                source: (imgUrl ? imgUrl : _defaultSource)

                onStatusChanged: {
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
                color: highlighted ? Theme.highlightColor : ((unreadCount > 0) ? Theme.primaryColor : Theme.secondaryColor)
            }

            Label {
                id: unreadCountLabel

                anchors { right: parent.right; rightMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
                text: unreadCount
                visible: (unreadCount > 0)
                color: Theme.highlightColor
            }

            enabled: (unreadCount > 0)
            onClicked: pageStack.push(Qt.resolvedUrl("ArticlesListPage.qml"), { "title": title, "streamId": id, "unreadCount": unreadCount })
        }

        section.property: "category"
        section.delegate: SectionHeader { text: section }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: (feedly.signedIn ? qsTr("Sign out") : qsTr("Sign in"))
                onClicked: {
                    if (feedly.signedIn) feedly.revokeRefreshToken();
                    else pageStack.push(Qt.resolvedUrl("SignInPage.qml"));
                }
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

    onStatusChanged: {
        if (status === PageStatus.Activating) feedly.acquireStatusIndicator(page);
    }
}


