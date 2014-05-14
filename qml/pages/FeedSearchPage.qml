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

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: searchFeedFlicakble

        anchors.fill: parent
        contentHeight: searchContainer.height

        Column {
            id: searchContainer

            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Search Feed")
            }

            SearchField {
                id: searchFeedString

                readonly property int _minTextLength: 4
                property int _prevTextLength: 0

                width: parent.width
                placeholderText: qsTr("Search or enter feed URL")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                EnterKey.enabled: (text.length > _minTextLength)
                EnterKey.iconSource: "image://theme/icon-m-search"
                EnterKey.onClicked: {
                    focus = false;
                    feedly.searchFeed(text);
                }

                onTextChanged: {
                    if ((text.length === 0) && (_prevTextLength > 1)) resultsListModel.clear();
                    _prevTextLength = text.length;
                }
            }

            Repeater {
                model: ListModel {
                    id: resultsListModel
                }

                ListItem {
                    id: resultItem

                    width: searchContainer.width
                    anchors { leftMargin: Theme.paddingLarge; rightMargin: Theme.paddingLarge }
                    contentHeight: Theme.itemSizeSmall

                    Image {
                        id: resultVisual

                        readonly property string _defaultSource: "../../icons/icon-s-rss.png"

                        anchors {
                            left: parent.left
                            leftMargin: Theme.paddingLarge
                            verticalCenter: parent.verticalCenter
                        }
                        width: Theme.iconSizeSmall
                        height: width
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        clip: true
                        source: (imgUrl ? imgUrl : _defaultSource)

                        onStatusChanged: {
                            if (status === Image.Error) source = _defaultSource;
                        }
                    }

                    Label {
                        anchors {
                            left: resultVisual.right
                            right: parent.right
                            leftMargin: Theme.paddingMedium
                            verticalCenter: parent.verticalCenter
                        }
                        truncationMode: TruncationMode.Fade
                        text: title
                        color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    }

                    onClicked: pageStack.push(Qt.resolvedUrl("../dialogs/AddFeedDialog.qml"), { "feedId": id, "title": title, "description": description, "imgUrl": imgUrl, "subscribers": subscribers })
                }

            }
        }

        VerticalScrollDecorator {
            flickable: searchFeedFlicakble
        }
    }

    Connections {
        target: feedly

        onSearchFeedCompleted: {
            resultsListModel.clear();
            for (var i = 0; i < results.length; i++) {
                resultsListModel.append(results[i]);
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) feedly.acquireStatusIndicator(page);
    }
}
