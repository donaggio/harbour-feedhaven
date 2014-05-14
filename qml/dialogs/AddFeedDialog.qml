/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Dialog {
    id: dialog

    property string feedId: ""
    property alias title: titleTextField.text
    property string description: ""
    property string imgUrl: ""
    property int subscribers: 0
    property var categories: []

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    anchors.fill: parent
    acceptDestination: {
        pageStack.find(function (page) {
            return (page.pageType === "feedsList");
        });
    }
    acceptDestinationAction: PageStackAction.Pop
    canAccept: (feedId && title)

    SilicaFlickable {
        id: feedView

        anchors.fill: parent
        contentHeight: feedContainer.height

        Column {
            id: feedContainer

            width: dialog.width - (2 * Theme.paddingLarge)
            x: Theme.paddingLarge
            spacing: Theme.paddingLarge

            DialogHeader {
               title: qsTr("Add Feed")
               acceptText: qsTr("Subscribe")
            }

            TextField {
                id: titleTextField

                width: parent.width
                textMargin: 0
                label: qsTr("Title")
                placeholderText: qsTr("Title")
                text: dialog.title
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Categories")
                onClicked: {
                    var catDialog = pageStack.push(Qt.resolvedUrl("SelectCategoriesDialog.qml"), { "categories": dialog.categories });
                    catDialog.accepted.connect(function() {
                        dialog.categories = catDialog.categories;
                    });
                }
            }

            SectionHeader {
                text: qsTr("Additional Info")
            }

            Field {
                width: parent.width
                fieldName: qsTr("Description")
                fieldValue: (dialog.description ? dialog.description : qsTr("No description"))
            }

            Field {
                width: parent.width
                fieldName: qsTr("Subscribers")
                fieldValue: (dialog.subscribers ? dialog.subscribers : qsTr("None"))
            }
        }

        VerticalScrollDecorator {
            flickable: feedView
        }
    }

    onAccepted: {
        feedly.updateSubscription(feedId, title, categories);
    }
}
