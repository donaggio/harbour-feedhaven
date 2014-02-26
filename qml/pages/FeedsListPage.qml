import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaListView {
        id: feedsListView
        anchors.fill: parent
        visible: !feedly.busy

        header: PageHeader {
            title: qsTr("Feeds list")
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset authorization")
                onClicked: pageStack.push(Qt.resolvedUrl("SignInPage.qml"))
            }
        }

        ViewPlaceholder {
            enabled: (feedsListView.count == 0)
            text: qsTr("Feeds list not available")
        }

        model: feedsListModel

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
                color: highlighted ? Theme.highlightColor : (parent.enabled ? Theme.primaryColor : Theme.secondaryColor)
            }

            Label {
                id: unreadCountLabel
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                text: unreadCount
                visible: parent.enabled
                color: Theme.highlightColor
            }

            enabled: (unreadCount > 0)
            onClicked: pageStack.push(Qt.resolvedUrl("ArticlesListPage.qml"), { "title": title, "streamId": id })
        }

        section.property: "category"
        section.delegate: SectionHeader { text: section }

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

    Component.onCompleted: {
        if (feedly.signedIn) {
            feedly.getSubscriptions();
        }
    }
}


