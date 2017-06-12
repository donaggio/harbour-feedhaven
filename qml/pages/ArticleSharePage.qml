/*
  Copyright (C) 2015 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    allowedOrientations: Orientation.All

    property string title: ""
    property string contentUrl: ""
    readonly property string bodySig: qsTr("Shared via Feed Haven for SailfishOS")
    readonly property string pageType: "articleShare"

    SilicaFlickable {
        id: shareOptionsView

        anchors.fill: parent
        contentHeight: header.height + optionsContainer.height

        PageHeader {
            id: header

            title: qsTr("Share Article")
        }

        Column {
            id: optionsContainer

            anchors.top: header.bottom
            width: page.width
            spacing: Theme.paddingMedium

            BackgroundItem {
                width: parent.width
                onClicked: {
                    sharing.email(page.title, page.contentUrl + "\n\n\n" + page.bodySig);
                    pageStack.navigateBack();
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }
                    text: qsTr("Email")
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }
        }
    }
}
