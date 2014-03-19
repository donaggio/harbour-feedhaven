import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    Column {
        anchors.top: cover.top
        anchors.topMargin: Theme.paddingLarge
        width: cover.width - (2 * Theme.paddingLarge)
        x: Theme.paddingLarge
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

        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.NoWrap
        truncationMode: TruncationMode.Fade
        text: qsTr("Loading ...")
        visible: feedly.busy
    }
}
