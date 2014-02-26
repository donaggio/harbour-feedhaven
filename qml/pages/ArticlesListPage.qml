import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string title
    property string streamId

    SilicaListView {
        id: articlesListView
        anchors.fill: parent
        visible: !feedly.busy

        header: PageHeader {
            title: page.title
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh feed")
                onClicked: feedly.getStreamContent(streamId)
            }
        }

        ViewPlaceholder {
            enabled: (articlesListView.count == 0)
            text: qsTr("No unread articles in this feed")
        }

        spacing: Theme.paddingSmall

        model: articlesListModel
        delegate: ListItem {
            id: articleItem

            width: articlesListView.width
            contentHeight: Theme.itemSizeExtraLarge

            GlassItem {
                id: unreadIndicator

                width: Theme.itemSizeExtraSmall
                height: width
                x: -(width / 2)
                anchors.verticalCenter: articleTitle.verticalCenter
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                visible: unread
            }

            Label {
                id: articleTitle

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                text: title
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            Label {
                id: articleSummary

                anchors.top: articleTitle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraSmall
                elide: Text.ElideRight
                maximumLineCount: 3
                wrapMode: Text.WordWrap

                text: summary
                color: highlighted ? (unread ? Theme.highlightColor : Theme.secondaryHighlightColor) : (unread ? Theme.primaryColor : Theme.secondaryColor)
            }

//            Label {
//                id: articleTitle

//                anchors.top: parent.top
//                anchors.left: parent.left
//                anchors.leftMargin: (articleVisual.width ? (articleVisual.width + Theme.paddingSmall) : 0)
//                anchors.right: parent.right
//                elide: Text.ElideRight
//                maximumLineCount: 3
//                wrapMode: Text.WordWrap
//                font.pixelSize: Theme.fontSizeSmall
//                text: title
//                color: highlighted ? Theme.highlightColor : Theme.primaryColor

//                Image {
//                    id: articleVisual

//                    x: (width ? -(width + Theme.paddingSmall) : 0)
//                    width: height
//                    height: (source ? articleItem.height : 0)
//                    sourceSize.width: articleItem.height * 2
//                    sourceSize.height: articleItem.height * 2
//                    fillMode: Image.PreserveAspectCrop
//                    smooth: true
//                    clip: true
//                    source: imgUrl
//                }
//            }

            onClicked: {
                feedly.markEntryAsRead(id);
                feedly.getEntry(id);
                pageStack.push(Qt.resolvedUrl("ArticlePage.qml"));
            }
        }

        section.property: "updatedDate"
        section.delegate: SectionHeader { text: Format.formatDate(section, Formatter.TimepointSectionRelative) }

        VerticalScrollDecorator { flickable: articlesListView }

    }

    Component.onCompleted: {
        feedly.getStreamContent(streamId)
    }
}
