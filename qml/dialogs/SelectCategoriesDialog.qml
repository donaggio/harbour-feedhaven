/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    property var categories: []
    property var _selectedCategories: []

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    anchors.fill: parent

    SilicaFlickable {
        id: categoriesView

        anchors.fill: parent
        contentHeight: header.height + categoriesContainer.height

        DialogHeader {
           id: header

           title: qsTr("Choose categories")
           acceptText: qsTr("Accept")
        }

        Column {
            id: categoriesContainer

            anchors.top: header.bottom
            width: dialog.width - (2 * Theme.paddingLarge)
            x: Theme.paddingLarge
            spacing: Theme.paddingLarge

            Repeater {
                id: categoriesList

                model: ListModel {
                    id: categoriesListModel
                }

                TextSwitch {
                    text: label
                    checked: {
                        var tmpChecked = false;
                        for (var i = 0; i < dialog._selectedCategories.length; i++) {
                            if (id === dialog._selectedCategories[i].id) tmpChecked = true;
                        }
                        return tmpChecked;
                    }

                    onCheckedChanged: {
                        var tmpIndex = -1;
                        for (var i = 0; i < dialog._selectedCategories.length; i++) {
                            if (id === dialog._selectedCategories[i].id) tmpIndex = i;
                        }
                        if (checked) {
                            if (tmpIndex === -1) {
                                var tmpObj = categoriesListModel.get(index);
                                dialog._selectedCategories.push({ "id": tmpObj.id, "label": tmpObj.label });
                            }
                        } else {
                            if (tmpIndex >= 0) dialog._selectedCategories.splice(tmpIndex, 1);
                        }
                    }
                }
            }

            TextField {
                id: newCategoryLabel

                width: parent.width
                textMargin: 0
                font.pixelSize: Theme.fontSizeSmall
                placeholderText: qsTr("Add new category")
                label: acceptableInput ? qsTr("Add") : qsTr("Min. 3 plain chars or digits")
                inputMethodHints: Qt.ImhNoPredictiveText
                validator: RegExpValidator { regExp: /[a-z0-9]{3}[a-z0-9 ]*/i }
                errorHighlight: ((text != "") ? !acceptableInput : false)
                EnterKey.enabled: acceptableInput
                EnterKey.iconSource: "image://theme/icon-m-add"
                EnterKey.onClicked: {
                    focus = false;
                    text = '';
                    categoriesListModel.append({ "id": feedly.createCategoryId(text), "label": text });
                    categoriesList.itemAt(categoriesList.count - 1).checked = true;
                }
            }
        }
    }

    Connections {
        target: feedly

        onGetCategoriesCompleted: {
            categoriesListModel.clear();
            for (var i = 0; i < categories.length; i++) categoriesListModel.append(categories[i]);
        }
    }

    Component.onCompleted: {
        for (var i = 0; i < categories.length; i++) _selectedCategories.push(categories[i]);
        feedly.getCategories();
    }

    onDone: {
        if (result === DialogResult.Accepted) categories = _selectedCategories;
    }
}
