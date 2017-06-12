/*
  Copyright (C) 2017 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    readonly property string pageType: "settings"

    SilicaFlickable {
        id: settingsFlickable

        anchors.fill: parent
        contentHeight: header.height + settingsContainer.height

        PageHeader {
            id: header

            title: qsTr("Settings")
        }

        Column {
            id: settingsContainer

            anchors { top: header.bottom; left: parent.left; leftMargin: Theme.horizontalPageMargin; right: parent.right; rightMargin: Theme.horizontalPageMargin }
            spacing: Theme.paddingSmall

            SectionHeader {
                text: qsTr("Articles list")
            }

            ComboBox {
                width: parent.width

                label: qsTr("Sorting")
                description: qsTr("Choose articles list sorting method")
                currentIndex: settings.articlesOrder
                menu: ContextMenu {
                    MenuItem { text: qsTr("Newest first") }
                    MenuItem { text: qsTr("Oldest first") }
                }

                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        settings.articlesOrder = currentIndex;
                    }
                }
            }

            TextSwitch {
                width: parent.width

                text: qsTr("Don't show images")
                description: qsTr("Help reduce bandwith usage by not loading any article's images")
                checked: !settings.loadImages

                onCheckedChanged: {
                    settings.loadImages = !checked;
                }
            }

        }

        VerticalScrollDecorator { flickable: settingsFlickable }
    }
}
