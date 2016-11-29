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

    readonly property string pageType: "feedSearch"

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaFlickable {
        id: searchFeedFlicakble

        anchors.fill: parent
        contentHeight: header.height + searchContainer.height

        PageHeader {
            id: header

            title: qsTr("Search Feed")
        }

        Column {
            id: searchContainer

            anchors.top: header.bottom
            width: parent.width - (2 * Theme.horizontalPageMargin)
            x: Theme.horizontalPageMargin
            spacing: Theme.paddingLarge

            SearchField {
                id: searchFeedString

                property int _prevTextLength: 0

                width: parent.width
                textMargin: 0
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: qsTr("Search or enter feed URL")
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                validator: RegExpValidator { regExp: /.{3,}/ }
                errorHighlight: ((text != "") ? !acceptableInput : false)
                EnterKey.enabled: acceptableInput
                EnterKey.iconSource: "image://theme/icon-m-search"
                EnterKey.onClicked: {
                    focus = false;
                    page.state = "searching";
                    resultsListModel.clear();
                    feedly.searchFeed(text);
                }

                onTextChanged: {
                    if ((text.length === 0) && (_prevTextLength > 1)) {
                        page.state = "";
                        resultsListModel.clear();
                    }
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
                    contentHeight: Theme.itemSizeSmall

                    Image {
                        id: resultVisual

                        readonly property string _defaultSource: "../../icons/icon-s-rss.png"

                        anchors {
                            left: parent.left
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

                    onClicked: pageStack.push(Qt.resolvedUrl("../dialogs/UpdateFeedDialog.qml"), { "feedId": id, "title": title, "description": description, "imgUrl": imgUrl, "lang": lang, "subscribers": subscribers, "addFeed": true })
                }

            }

            ViewPlaceholder {
                id: searchResultPlaceholder

                enabled: false
            }
        }

        VerticalScrollDecorator {
            flickable: searchFeedFlicakble
        }
    }

    Connections {
        target: feedly

        onError: { page.state = "searchCompleted" }

        onSearchFeedCompleted: {
            if (resultsListModel.count) resultsListModel.clear();
            for (var i = 0; i < results.length; i++) {
                resultsListModel.append(results[i]);
            }
            page.state = "searchCompleted"
        }
    }

    states: [
        State {
            name: "searching"
            PropertyChanges {
                target: searchFeedString
                enabled: false
            }
            PropertyChanges {
                target: searchResultPlaceholder
                text: qsTr("Searching ...")
                enabled: true
            }
        },
        State {
            name: "searchCompleted"
            PropertyChanges {
                target: searchFeedString
                enabled: true
            }
            PropertyChanges {
                target: searchResultPlaceholder
                text: (!resultsListModel.count ? qsTr("No results") : "")
                enabled: !resultsListModel.count
            }
        }
    ]
}
