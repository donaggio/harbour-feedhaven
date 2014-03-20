import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    Label {
        id: labelAppName

        anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: Theme.paddingSmall; leftMargin: Theme.paddingSmall; rightMargin: Theme.paddingSmall }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.NoWrap
        truncationMode: TruncationMode.Fade
        text: qsTr("Feed Haven")
    }

    Column {
        anchors.top: labelAppName.bottom
        anchors.topMargin: Theme.paddingMedium
        width: cover.width - (2 * Theme.paddingMedium)
        x: Theme.paddingMedium
        spacing: Theme.paddingSmall
        visible: !labelLoading.visible

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
                text: (feedly.feedsListModel !== null) ? feedly.feedsListModel.count: 0
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

    Label {
        id: labelLoading

        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: Theme.paddingSmall; rightMargin: Theme.paddingSmall }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.NoWrap
        truncationMode: TruncationMode.Fade
        text: qsTr("Updating ...")
        visible: feedly.busy

        SequentialAnimation on opacity {
            paused: !visible
            loops: Animation.Infinite

            NumberAnimation { to: 0; duration: 1000 }
            NumberAnimation { to: 1; duration: 1000 }
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: feedly.getSubscriptions();
        }
    }

}
