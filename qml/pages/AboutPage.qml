import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    Column {
        width: (parent.width - (2 * Theme.paddingMedium))
        x: Theme.paddingMedium
        spacing: Theme.paddingLarge

        PageHeader {
            title: qsTr("About Feed Haven")
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeSmall
            font.italic: true
            text: qsTr("Version %1").arg(version)
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("<p><i>Feed Haven</i> is a native client for Feedly news reader service.</p>
<p>You can access to your subscribed feeds content and to each article's original web page as well.</p>
<p>Subscribing to new feeds is currently not supported, you need to log in to Feedly itself using a web browser in order to do so.</p>")
        }
    }
}
