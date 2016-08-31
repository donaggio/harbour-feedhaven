/*
  Copyright (C) 2016 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import org.nemomobile.notifications 1.0

Notification {
    id: errorIndicator

    property string _defaultErrorMessage: qsTr("Feedly connection error")

    category: "x-jolla.store.error"

    /*
     * Show error indicator
     */
    function show(message) {
        replacesId = 0;
        previewSummary = (message ? message : _defaultErrorMessage);
        publish();
    }

}
