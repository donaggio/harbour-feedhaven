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

    readonly property string pageType: "about"

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: aboutFlickable

        anchors.fill: parent
        contentHeight: header.height + aboutContainer.height

        PageHeader {
            id: header

            title: qsTr("About Feed Haven")
        }

        Column {
            id: aboutContainer

            anchors { top: header.bottom; left: parent.left; leftMargin: Theme.horizontalPageMargin; right: parent.right; rightMargin: Theme.horizontalPageMargin }
            spacing: Theme.paddingSmall

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryHighlightColor
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: qsTr("Version %1<br/>&copy; 2016 by Luca Donaggio").arg(Qt.application.version)
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                textFormat: Text.StyledText
                text: qsTr("<p><i>Feed Haven</i> is a native client for Feedly.com on-line news reader service.</p>
    <p>You can search for and subscribe to new feeds, manage your feeds and access their content, save articles for later reference, add or remove custom categories and read articles by category.<br />
    As soon as you'll read an article, it will be marked as read on Feedly.com as well.</p>
    <p>Image thumbnails in article list are displayed in landscape mode only.</p>")
            }

            SectionHeader {
                text: qsTr("Sources & License")
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap

                text: qsTr("This is an open source project released under the MIT license.\nYou can find its source code, as well as report any issues and feature requests, on this project's page at GitHub.")
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingSmall

                Button {
                    text: qsTr("Source code")
                    onClicked: Qt.openUrlExternally("https://github.com/donaggio/harbour-feedhaven")
                }

                Button {
                    text: qsTr("Report issues")
                    onClicked: Qt.openUrlExternally("https://github.com/donaggio/harbour-feedhaven/issues")
                }

            }

            SectionHeader {
                text: qsTr("Credits")
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap

                text: qsTr("Launcher icon artwork courtesy by Nikita Balobanov.")
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap

                text: qsTr("Translations by %1.").arg("Carmen F. B.")
            }
        }

        VerticalScrollDecorator { flickable: aboutFlickable }
    }
}
