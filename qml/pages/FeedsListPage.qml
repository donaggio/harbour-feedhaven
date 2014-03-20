import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

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

            Label {
                anchors.left: parent.left
                anchors.right: unreadCountLabel.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingSmall
                anchors.verticalCenter: parent.verticalCenter
                truncationMode: TruncationMode.Fade
                text: title
                color: highlighted ? Theme.highlightColor : ((unreadCount > 0) ? Theme.primaryColor : Theme.secondaryColor)
            }

            Label {
                id: unreadCountLabel
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                text: unreadCount
                visible: (unreadCount > 0)
                color: Theme.highlightColor
            }

            enabled: (unreadCount > 0)
            onClicked: pageStack.push(Qt.resolvedUrl("ArticlesListPage.qml"), { "title": title, "streamId": id })
        }

        section.property: "category"
        section.delegate: SectionHeader { text: section }

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: (feedly.signedIn ? qsTr("Reset authorization") : qsTr("Sign in"))
                onClicked: {
                    feedly.resetAuthorization();
                    pageStack.push(Qt.resolvedUrl("SignInPage.qml"));
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

    Connections {
        target: feedly

        onSignedInChanged: {
            if (feedly.signedIn && (feedsListView.count == 0)) {
                feedly.getSubscriptions();
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) feedly.acquireStatusIndicator(page);
    }

    Component.onCompleted: {
        if (feedly.signedIn) {
            feedly.getSubscriptions();
        }
    }
}


