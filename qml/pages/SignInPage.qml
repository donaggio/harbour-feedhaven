import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaWebView {
        id: signInView

        anchors.fill: parent
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

    onStatusChanged: {
        if (status === PageStatus.Activating) feedly.acquireStatusIndicator(page);
    }
}





