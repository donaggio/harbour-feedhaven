/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "components"

ApplicationWindow {
    id: main

    initialPage: Qt.resolvedUrl("pages/FeedsListPage.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    Feedly {
        id: feedly
    }

    Component.onCompleted: { if (!feedly.refreshToken) pageStack.push(Qt.resolvedUrl("SignInPage.qml")); }
}
