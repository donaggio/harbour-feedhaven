import QtQuick 2.0
import "../lib/feedly.js" as FeedlyAPI
import "../lib/dbmanager.js" as DB

QtObject {
    id: feedly

    property string refreshToken: ""
    property string accessToken: ""
    property int expires: 0
    property bool signedIn: false
    property bool busy: false
    property var pendingRequest: null
    property var currentEntry: null
    property string continuation: ""
    property int totalUnread: 0
    property QtObject feedsListModel: null
    property QtObject articlesListModel: null
    property Item _statusIndicator: null

    signal error(string message)

    /*
     * Return URL to sign in into Feedly
     */
    function getSignInUrl() {
        return FeedlyAPI._apiCalls["auth"].url;
    }

    /*
     * Parse URL and extract authorization code
     */
    function getAuthCodeFromUrl(url) {
        var retObj = { "authCode": "", "error": false };

        if ((url !== FeedlyAPI._apiCalls["auth"].url) && (url.indexOf(FeedlyAPI._redirectUri) >= 0)) {
            var startPos = url.indexOf("code=") + 5;
            if (startPos >= 0) {
                retObj.authCode = url.substring(startPos, url.indexOf("&state=", startPos));
                // DEBUG
                // console.log("Feedly auth code: " + retObj.authCode);
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
            busy = false;
            error();
            break;
        }

        return retval;
    }

    /*
     * Reset authorization
     */
    function resetAuthorization() {
        accessToken = "";
        expires = 0;
        refreshToken = ""
        signedIn = false;
        DB.saveAuthTokens(feedly);
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
            DB.saveAuthTokens(feedly);
            if (pendingRequest !== null) {
                busy = true;
                FeedlyAPI.call(pendingRequest.method, pendingRequest.param, pendingRequest.callback);
            } else busy = false;
        } else {
            // ERROR
            signedIn = false;
            busy = false;
            error(qsTr("Feedly authentication error"));
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
        if (checkResponse(retObj, subscriptionsDoneCB)) {
            feedsListModel.clear();
            if (Array.isArray(retObj.response)) {
                for (var i = 0; i < retObj.response.length; i++) {
                    var tmpObj = retObj.response[i];
                    for (var j = 0; j < tmpObj.categories.length; j++) {
                        feedsListModel.append({ "id": tmpObj.id,
                                                "title": tmpObj.title,
                                                "category": tmpObj.categories[j].label,
                                                "unreadCount": 0 });
                    }
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
        if (checkResponse(retObj, markersCountsDoneCB)) {
            if (Array.isArray(retObj.response.unreadcounts)) {
                for (var i = 0; i < retObj.response.unreadcounts.length; i++) {
                    var tmpObj = retObj.response.unreadcounts[i];
                    for (var j = 0; j < feedsListModel.count; j++) {
                        if (feedsListModel.get(j).id === tmpObj.id) feedsListModel.setProperty(j, "unreadCount", tmpObj.count);
                    }
                }
                totalUnread = 0;
                for (i = 0; i < feedsListModel.count; i++) {
                    totalUnread = (totalUnread + feedsListModel.get(i).unreadCount);
                    // TODO: Do not count same feed multiple times (can happen when a feed belongs to multiple categories)
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
    function getStreamContent(subscriptionId, more) {
        if (subscriptionId) {
            busy = true;
            var param = { "streamId": subscriptionId, "count": 40, "ranked": "newest", "unreadOnly": "true", "continuation": (more ? continuation : "") };
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
            if (!retObj.callParams.continuation) articlesListModel.clear();
            continuation = ((typeof retObj.response.continuation != "undefined") ? retObj.response.continuation : "");
            if (Array.isArray(retObj.response.items)) {
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
                                               "summary": ((typeof tmpObj.summary.content !== "undefined") ? tmpObj.summary.content.replace(stripHtmlTags, " ").replace(normalizeSpaces, " ").trimLeft() : qsTr("No content preview")),
                                               "contentUrl": ((typeof tmpObj.alternate !== "undefined") ? tmpObj.alternate[0].href : ""),
                                               "streamId": retObj.response.id });
                }
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
            if ((currentEntry == null) || (currentEntry.id != entryId)) {
                currentEntry = null;
                busy = true;
                FeedlyAPI.call("entries", entryId, entryDoneCB, accessToken);
            }
        } else {
            // DEBUG
            console.log("No entryId given.");
        }
    }

    function entryDoneCB(retObj) {
        if (checkResponse(retObj, entryDoneCB)) {
            if (Array.isArray(retObj.response) && (retObj.response.length > 0)) {
                var tmpObj = retObj.response[0];
                var tmpContent = ((typeof tmpObj.content !== "undefined") ? tmpObj.content.content : ((typeof tmpObj.summary !== "undefined") ? tmpObj.summary.content : ""))
                tmpContent = tmpContent.replace(new RegExp("<img[^>]*>", "gi"), " ").replace(new RegExp("\\s+", "g"), " ").trim();
                currentEntry = new Object({ "id": tmpObj.id,
                                            "title": tmpObj.title,
                                            "author": tmpObj.author,
                                            "updated": new Date(((typeof tmpObj.updated !== "undefined") ? tmpObj.updated : tmpObj.published)),
                                            "imgUrl": (((typeof tmpObj.visual !== "undefined") && tmpObj.visual.url && tmpObj.visual.url !== "none") ? tmpObj.visual.url : ""),
                                            "content": tmpContent,
                                            "contentUrl": ((typeof tmpObj.alternate !== "undefined") ? tmpObj.alternate[0].href : "") });
            }
            busy = false;
        }
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Mark feed as read
     */
    function markFeedAsRead(feedId, lastEntryId) {
        if (feedId) {
            var param = { "action": "markAsRead", "type": "feeds", "feedIds": [feedId] };
            if (lastEntryId) param.lastReadEntryId = lastEntryId;
            else param.asOf = Date.now();
            FeedlyAPI.call("markers", param, markFeedAsReadDoneCB, accessToken);
        } else {
            // DEBUG
            console.log("No feedId given.");
        }
    }

    function markFeedAsReadDoneCB(retObj) {
        if (checkResponse(retObj, markFeedAsReadDoneCB)) {
            if (articlesListModel.count > 0) {
                for (var i = 0; i < articlesListModel.count; i++) {
                    articlesListModel.setProperty(i, "unread", false);
                }
            }
            busy = false;
            getMarkersCounts();
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
        if (checkResponse(retObj, markEntryAsReadDoneCB)) {
            if (articlesListModel.count > 0) {
                var entryId = retObj.callParams.entryIds[0];
                var streamId = "";
                for (var i = 0; i < articlesListModel.count; i++) {
                    if ((articlesListModel.get(i).id === entryId) && articlesListModel.get(i).unread) {
                        articlesListModel.setProperty(i, "unread", false);
                        streamId = articlesListModel.get(i).streamId;
                    }
                }
                if (streamId != "") {
                    for (var j = 0; j < feedsListModel.count; j++) {
                        if (feedsListModel.get(j).id === streamId) {
                            var tmpUnreadCount = feedsListModel.get(j).unreadCount;
                            if (tmpUnreadCount > 0) feedsListModel.setProperty(j, "unreadCount", (tmpUnreadCount - 1));
                        }
                    }
                }
                if (totalUnread > 0) totalUnread--;
            }
            busy = false;
        }
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Load status indicator item when needed
     */
    function _createStatusIndicator() {
        var retVal = true;

        if (_statusIndicator === null) {
            var component = Qt.createComponent("StatusIndicator.qml");
            if (component.status === Component.Ready) _statusIndicator = component.createObject(null);
            else retVal = false;
        }
        return retVal;
    }

    /*
     * Reparent status indicator item
     */
    function acquireStatusIndicator(container) {
        if (_createStatusIndicator()) _statusIndicator.parent = container;
    }

    onBusyChanged: {
        if (_createStatusIndicator()) _statusIndicator.busyIndRunning = busy;
    }

    onError: {
        if (_createStatusIndicator()) _statusIndicator.showErrorIndicator(message);
        // DEBUG
        console.log("Feedly API error!");
    }

    Component.onCompleted: {
        feedsListModel = Qt.createQmlObject('import QtQuick 2.0; ListModel { }', feedly);
        articlesListModel = Qt.createQmlObject('import QtQuick 2.0; ListModel { }', feedly);
        DB.getAuthTokens(feedly);
    }
}
