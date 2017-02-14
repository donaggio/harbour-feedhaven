/*
  Copyright (C) 2017 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import org.nemomobile.configuration 1.0

ConfigurationGroup {
    property int articlesOrder: 0
    property bool loadImages: true

    path: "/apps/" + Qt.application.name
}
