import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string title
    property string streamId

    SilicaListView {
        id: articlesListView

        property Item contextMenu

        anchors.fill: parent
        visible: !feedly.busy
        spacing: Theme.paddingSmall

        header: PageHeader {
            title: page.title
        }

        model: feedly.articlesListModel
        delegate: ListItem {
            id: articleItem

            property bool menuOpen: ((articlesListView.contextMenu != null) && (articlesListView.contextMenu.parent === articleItem))

            width: articlesListView.width
            contentHeight: menuOpen ? articlesListView.contextMenu.height + Theme.itemSizeExtraLarge : Theme.itemSizeExtraLarge

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
                if (unread) feedly.markEntryAsRead(id);
                feedly.getEntry(id);
                pageStack.push(Qt.resolvedUrl("ArticlePage.qml"));
            }

            onPressAndHold: {
                if (unread || contentUrl) {
                    if (!articlesListView.contextMenu) articlesListView.contextMenu = contextMenuComponent.createObject(articlesListView)
                    articlesListView.contextMenu.articleId = id;
                    articlesListView.contextMenu.articleUnread = unread;
                    articlesListView.contextMenu.articleUrl = contentUrl;
                    articlesListView.contextMenu.show(articleItem)
                }
            }
        }

        section.property: "updatedDate"
        section.delegate: SectionHeader { text: Format.formatDate(section, Formatter.TimepointSectionRelative) }

        Component {
            id: contextMenuComponent

            ContextMenu {
                property string articleId
                property bool articleUnread
                property string articleUrl

                MenuItem {
                    visible: parent.articleUnread
                    text: qsTr("Mark as read")
                    onClicked: feedly.markEntryAsRead(parent.articleId)
                }

                MenuItem {
                    visible: (parent.articleUrl != "")
                    text: qsTr("Open original link")
                    onClicked: Qt.openUrlExternally(parent.articleUrl)
                }
            }
        }

        PullDownMenu {
            MenuItem {
                visible: (articlesListView.count > 0)
                text: qsTr("Mark all as read")
                onClicked: remorsePopup.execute(qsTr("Marking all articles as read"))
            }

            MenuItem {
                text: qsTr("Refresh feed")
                onClicked: feedly.getStreamContent(streamId)
            }
        }

        PushUpMenu {
            visible: (feedly.continuation !== "")

            MenuItem {
                text: qsTr("More articles")
                onClicked: feedly.getStreamContent(streamId, true)
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

        onTriggered: feedly.markFeedAsRead(streamId, articlesListView.model.get(0).id)
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) feedly.acquireStatusIndicator(page);
    }

    Component.onCompleted: {
        feedly.getStreamContent(streamId)
    }

    Component.onDestruction: {
        feedly.articlesListModel.clear();
    }
}
