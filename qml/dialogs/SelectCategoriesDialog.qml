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
        contentHeight: categoriesContainer.height

        Column {
            id: categoriesContainer

            width: dialog.width - (2 * Theme.paddingLarge)
            x: Theme.paddingLarge
            spacing: Theme.paddingLarge

            DialogHeader {
               title: qsTr("Choose categories")
               acceptText: qsTr("Accept")
            }

            Repeater {
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
