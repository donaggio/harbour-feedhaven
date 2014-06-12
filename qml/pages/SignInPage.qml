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

    readonly property string pageType: "signIn"

    allowedOrientations: Orientation.Portrait | Orientation.Landscape

    SilicaWebView {
        id: signInView

        anchors.fill: parent
        visible: !feedly.busy

        header: PageHeader {
            title: qsTr("Sign in")
        }
        url: feedly.getSignInUrl();

        ViewPlaceholder {
            id: errorPlaceholder

            enabled: false
            text: qsTr("Authentication error")
        }

        onUrlChanged: {
            var authInfo = feedly.getAuthCodeFromUrl(url.toString());

            if (authInfo.authCode !== "") feedly.getAccessToken(authInfo.authCode);
            else if (authInfo.error) errorPlaceholder.enabled = true;
        }
    }

    Connections {
        target: feedly

        onSignedInChanged: {
            if (feedly.signedIn) pageContainer.pop();
        }

        onError: errorPlaceholder.enabled = true;
    }
}





