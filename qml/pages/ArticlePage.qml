import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    property string title: (feedly.currentEntry !== null) ? feedly.currentEntry.title : ""
    property string author: (feedly.currentEntry !== null) ? feedly.currentEntry.author : ""
    property date updated: (feedly.currentEntry !== null) ? new Date(feedly.currentEntry.updated) : ""
    property string content: (feedly.currentEntry !== null) ? feedly.currentEntry.content : ""

    SilicaFlickable {
        id: articleView

        anchors.fill: parent
        contentHeight: articleContainer.height

        Column {
            id: articleContainer

            width: page.width - (2 * Theme.paddingLarge)
            x: Theme.paddingLarge
            spacing: Theme.paddingSmall

            PageHeader {
                title: page.title
            }

            Label {
                id: articleTitle

                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
                text: page.title
            }

            Label {
                id: articleAuthor

                width: parent.width
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("by %1, published on: %2").arg(page.author).arg(Qt.formatDateTime(page.updated))
            }

            Label {
                id: articleContent

                width: parent.width
                horizontalAlignment: Text.AlignJustify
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: page.content
            }
        }

        VerticalScrollDecorator { flickable: articleView }
    }

}
