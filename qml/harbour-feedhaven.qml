import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "lib/feedly.js" as FeedlyAPI

ApplicationWindow {
    id: main

    initialPage: Component { FeedsListPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    // Object which holds Feedly global properties and methods
    QtObject {
        id: feedly

        property string accessToken: ""
        property int expires: 0
        property string refreshToken: "AQAAvGx7Im4iOiJlVmI5ZzkyZkQ1YUhIdXA2IiwiaSI6ImM4NjAzMTZjLTM1NDgtNGUxNS1iZTc5LWVlYmI0ODU5YzdmNyIsInUiOiIxMDk5MTA3ODUyMDUxNzQ4NDY2ODEiLCJwIjo2LCJjIjoxMzkxNjEzMjk2Mjg0LCJhIjoiRmVlZGx5IHNhbmRib3ggY2xpZW50IiwidiI6InNhbmRib3gifQ:sandbox"
        property bool signedIn: false
        property var pendingRequest: null
        property bool busy: false
        property var currentEntry: null
        /*
         * Return URL to sign in into Feedly
         */
        function getSignInUrl() {
            return FeedlyAPI._apiCalls["auth"].url;
        }

        /*
         * Parse "url" and extract authorization code
         */
        function getAuthCodeFromUrl(url) {
            var retObj = { "authCode": "", "error": false };

            // DEBUG
            console.log(url);
            if ((url !== FeedlyAPI._apiCalls["auth"].url) && (url.indexOf(FeedlyAPI._redirectUri) >= 0)) {
                var startPos = url.indexOf("code=") + 5;
                if (startPos >= 0) {
                    retObj.authCode = url.substring(startPos, url.indexOf("&state=", startPos));
                    // DEBUG
                    console.log("Feedly auth code: " + retObj.authCode);
                } else {
                    retObj.error = true;
                    // DEBUG
                    console.log("Feedly auth error!");
                }
            }
            return retObj;
        }

        /*
         * Check API response for authentication errors
         */
        function checkResponse(retObj, callback) {
            var retval = false;

            // DEBUG
            // console.log(JSON.stringify(retObj));
            switch(retObj.status) {
            case 200:
                retval = true;
                break;
            case 401:
                pendingRequest = new Object({ "method": retObj.callMethod, "param": retObj.callParams, "callback": callback });
                getAccessToken();
                break;
            default:
                break;
            }

            return retval;
        }

        /*
         * Get access and refresh tokens
         */
        function getAccessToken(authCode) {
            var param;

            if (authCode || refreshToken) {
                if (authCode) {
                    param = { "code": authCode, "client_id": FeedlyAPI._clientID, "client_secret": FeedlyAPI._clientSecret, "redirect_uri": FeedlyAPI._redirectUri, "state": "", "grant_type": "authorization_code" };
                } else {
                    param = { "refresh_token": refreshToken, "client_id": FeedlyAPI._clientID, "client_secret": FeedlyAPI._clientSecret, "grant_type": "refresh_token" };
                }
                busy = true;
                FeedlyAPI.call("authRefreshToken", param, accessTokenDoneCB);
            } else {
                // DEBUG
                console.log("No authCode given nor refreshToken found.");
            }
        }

        function accessTokenDoneCB(retObj) {
            if (retObj.status == 200) {
                accessToken = retObj.response.access_token;
                var now = new Date();
                var exp = new Date(now.getMilliseconds() + (retObj.response.expires_in * 1000));
                expires = exp.getMilliseconds();
                if (typeof retObj.response.refresh_token !== "undefined") refreshToken = retObj.response.refresh_token;
                signedIn = true;
                if (pendingRequest !== null) {
                    FeedlyAPI.call(pendingRequest.method, pendingRequest.param, pendingRequest.callback);
                } else busy = false;
            } else {
                // ERROR
                signedIn = false;
                busy = false;
            }
            // DEBUG
            // console.log(JSON.stringify(retObj));
         }

        /*
         * Get subscriptions
         */
        function getSubscriptions() {
            if (accessToken) {
                busy = true;
                FeedlyAPI.call("subscriptions", null, subscriptionsDoneCB, accessToken);
            } else {
                // DEBUG
                console.log("No accessToken found.");
            }
        }

        function subscriptionsDoneCB(retObj) {
            if (checkResponse(retObj, subscriptionsDoneCB) && Array.isArray(retObj.response)) {
                feedsListModel.clear();
                for (var i = 0; i < retObj.response.length; i++) {
                    for (var j = 0; j < retObj.response[i].categories.length; j++) {
                        feedsListModel.append({ "id": retObj.response[i].id,
                                                "title": retObj.response[i].title,
                                                "category": retObj.response[i].categories[j].label,
                                                "unreadCount": 0 });
                    }
                }
                busy = false;
                if (feedsListModel.count > 0) {
                    feedly.getMarkersCounts();
                }
            }
            // DEBUG
            // console.log(JSON.stringify(retObj));
        }

        /*
         * Get markers counts
         */
        function getMarkersCounts() {
            if (accessToken) {
                busy = true;
                FeedlyAPI.call("markersCounts", null, markersCountsDoneCB, accessToken);
            } else {
                // DEBUG
                console.log("accessToken: " + accessToken);
            }
        }

        function markersCountsDoneCB(retObj) {
            if (checkResponse(retObj, markersCountsDoneCB) && Array.isArray(retObj.response.unreadcounts)) {
                for (var i = 0; i < retObj.response.unreadcounts.length; i++) {
                    for (var j = 0; j < feedsListModel.count; j++) {
                        if (feedsListModel.get(j).id === retObj.response.unreadcounts[i].id) feedsListModel.setProperty(j, "unreadCount", retObj.response.unreadcounts[i].count);
                    }
                }
                busy = false;
            }
            // DEBUG
            // console.log(JSON.stringify(retObj));
        }

        /*
         * Get stream content (subscribed feeds)
         */
        function getStreamContent(subscriptionId) {
            if (subscriptionId) {
                busy = true;
                var param = { "streamId": subscriptionId, "count": 40, "ranked": "newest", "unreadOnly": "true" };
                FeedlyAPI.call("streamContent", param, streamContentDoneCB, accessToken);
            } else {
                // DEBUG
                console.log("No subscriptionId given.");
            }
        }

        function streamContentDoneCB(retObj) {
            if (checkResponse(retObj, streamContentDoneCB)) {
                var stripHtmlTags = new RegExp("<[^>]*>", "gi");
                var normalizeSpaces = new RegExp("\\s+", "g");
                articlesListModel.clear();
                for (var i = 0; i < retObj.response.items.length; i++) {
                    var tmpObj = retObj.response.items[i];
                    // Create updated date object
                    var tmpUpd = new Date(((typeof tmpObj.updated !== "undefined") ? tmpObj.updated : tmpObj.published));
                    // Extract date part
                    var tmpUpdDate = new Date(tmpUpd.getFullYear(), tmpUpd.getMonth(), tmpUpd.getDate());
                    articlesListModel.append({ "id": tmpObj.id,
                                               "author": tmpObj.author,
                                               "updated": tmpUpd,
                                               "updatedDate": tmpUpdDate,
                                               "title": tmpObj.title,
                                               "imgUrl": (((typeof tmpObj.visual !== "undefined") && tmpObj.visual.url && tmpObj.visual.url !== "none") ? tmpObj.visual.url : ""),
                                               "unread": tmpObj.unread,
                                               "summary": ((typeof tmpObj.summary.content !== "undefined") ? tmpObj.summary.content.replace(stripHtmlTags, " ").replace(normalizeSpaces, " ").trimLeft() : qsTr("No content preview")) });
                }
                busy = false;
            }
            // DEBUG
            // console.log(JSON.stringify(retObj));
        }

        /*
         * Get single entry's content
         */
        function getEntry(entryId) {
            if (entryId) {
                busy = true;
                FeedlyAPI.call("entries", entryId, entryDoneCB, accessToken);
            } else {
                // DEBUG
                console.log("No entryId given.");
            }
        }

        function entryDoneCB(retObj) {
            if (checkResponse(retObj, entryDoneCB)) {
                if (Array.isArray(retObj.response)) {
                    var tmpObj = retObj.response[0];
                    var tmpContent = ((typeof tmpObj.content !== "undefined") ? tmpObj.content.content : ((typeof tmpObj.summary !== "undefined") ? tmpObj.summary.content : ""))
                    currentEntry = new Object({ "title": tmpObj.title,
                                                "author": tmpObj.author,
                                                "updated": new Date(((typeof tmpObj.updated !== "undefined") ? tmpObj.updated : tmpObj.published)),
                                                "content": tmpContent });
                } else currentEntry = null;
                busy = false;
            }
            // DEBUG
            // console.log(JSON.stringify(retObj));
        }

        /*
         * Mark entry as read
         */
        function markEntryAsRead(entryId) {
            if (entryId) {
                var param = { "action": "markAsRead", "type": "entries", "entryIds": [entryId] };
                FeedlyAPI.call("markers", param, markEntryAsReadDoneCB, accessToken);
            } else {
                // DEBUG
                console.log("No entryId given.");
            }
        }

        function markEntryAsReadDoneCB(retObj) {
            if (checkResponse(retObj, markEntryAsReadDoneCB) && (articlesListModel.count > 0)) {
                var entryId = retObj.callParams.entryIds[0];
                for (var i = 0; i < articlesListModel.count; i++) {
                    if (articlesListModel.get(i).id == entryId) articlesListModel.setProperty(i, "unread", false);
                }
                busy = false;
            }
            // DEBUG
            // console.log(JSON.stringify(retObj));
        }
    }

    ListModel { id: feedsListModel }

    ListModel { id: articlesListModel }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: feedly.busy
        visible: running
    }

    Component.onCompleted: {
        if (feedly.refreshToken) feedly.getAccessToken();
        else pageStack.push(signInPage);
    }

    Component {
        id: signInPage

        SignInPage { }
    }
}
