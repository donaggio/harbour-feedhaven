/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/feedly.js" as FeedlyAPI
import "../lib/dbmanager.js" as DB

QtObject {
    id: feedly

    property string userId: ""
    property string refreshToken: ""
    property string accessToken: ""
    property string expires: ""
    property bool signedIn: false
    property bool busy: false
    property var pendingRequest: null
    property var currentEntry: null
    property string continuation: ""
    property int totalUnread: 0
    property int uniqueFeeds: 0
    property QtObject feedsListModel: null
    property QtObject articlesListModel: null
    property QtObject _errorIndicator: null
    property Item _statusIndicator: null

    signal error(string message)
    signal searchFeedCompleted(var results)
    signal getCategoriesCompleted(var categories)
    signal entryUnsaved(int index)
    signal markersCountRefreshed()

    /*
     * Return URL to sign in into Feedly
     */
    function getSignInUrl() {
        return (FeedlyAPI._apiCalls["auth"].protocol + "://" + FeedlyAPI._apiCallBaseUrl + FeedlyAPI._apiCalls["auth"].url + feedlyClientId);
    }

    /*
     * Parse URL and extract authorization code
     */
    function getAuthCodeFromUrl(url) {
        var retObj = { "authCode": "", "error": false };

        if ((url !== getSignInUrl()) && (url.indexOf(FeedlyAPI._redirectUri) >= 0)) {
            var startPos = url.indexOf("code=") + 5;
            if (startPos >= 0) {
                retObj.authCode = url.substring(startPos, url.indexOf("&state=", startPos));
                // DEBUG
                // console.log("Feedly auth code: " + retObj.authCode);
            } else {
                retObj.error = true;
            }
        }
        return retObj;
    }

    /*
     * Check API response for authentication errors
     */
    function checkResponse(retObj, callback) {
        var retval = false;

        switch(retObj.status) {
            case 200:
                retval = true;
                break;
            case 401:
                pendingRequest = new Object({ "method": retObj.callMethod, "param": retObj.callParams, "callback": callback });
                getAccessToken();
                break;
            default:
                // DEBUG
                // console.log(JSON.stringify(retObj));
                busy = false;
                error("");
                break;
        }

        return retval;
    }

    /*
     * Reset authorization
     */
    function resetAuthorization() {
        userId = "";
        accessToken = "";
        expires = "";
        refreshToken = ""
        signedIn = false;
        DB.saveAuthTokens(feedly);
    }

    /*
     * Reset object's properties
     */
    function resetProperties() {
        busy = false; // Experimental
        pendingRequest = null;
        currentEntry = null;
        continuation = "";
        totalUnread = 0;
        uniqueFeeds = 0;
        if (feedsListModel) feedsListModel.clear();
        if (articlesListModel) articlesListModel.clear();
    }

    /*
     * Get access and refresh tokens
     */
    function getAccessToken(authCode) {
        var param;

        if (authCode || refreshToken) {
            if (authCode) {
                param = { "code": authCode, "client_id": feedlyClientId, "client_secret": feedlyClientSecret, "redirect_uri": FeedlyAPI._redirectUri, "state": "", "grant_type": "authorization_code" };
            } else {
                param = { "refresh_token": refreshToken, "client_id": feedlyClientId, "client_secret": feedlyClientSecret, "grant_type": "refresh_token" };
            }
            busy = true;
            FeedlyAPI.call("authRefreshToken", param, accessTokenDoneCB);
        } else error(qsTr("Neither authCode nor refreshToken found."));
    }

    function accessTokenDoneCB(retObj) {
        if (retObj.status == 200) {
            userId = retObj.response.id;
            accessToken = retObj.response.access_token;
            var tmpDate = new Date();
            tmpDate.setSeconds(tmpDate.getSeconds() + retObj.response.expires_in);
            expires = tmpDate.getTime();
            if (typeof retObj.response.refresh_token !== "undefined") refreshToken = retObj.response.refresh_token;
            signedIn = true;
            DB.saveAuthTokens(feedly);
            if (pendingRequest !== null) {
                FeedlyAPI.call(pendingRequest.method, pendingRequest.param, pendingRequest.callback);
                pendingRequest = null;
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
     * Revoke refresh token
     */
    function revokeRefreshToken() {
        if (refreshToken) {
            var param = { "refresh_token": refreshToken, "client_id": feedlyClientId, "client_secret": feedlyClientSecret, "grant_type": "revoke_token" };
            busy = true;
            FeedlyAPI.call("authRefreshToken", param, revokeRefreshTokenDoneCB);
        } else error(qsTr("No refreshToken found."));
    }

    function revokeRefreshTokenDoneCB(retObj) {
        resetAuthorization();
        busy = false;
        if (retObj.status != 200) error(qsTr("Error revoking refreshToken"));
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Check if given stream is a category
     */
    function streamIsCategory(streamId) {
        return (streamId.indexOf("user/" + userId + "/category/") >= 0);
    }

    /*
     * Check if given stream is collection of articles with the same tag
     */
    function streamIsTag(streamId) {
        return (streamId.indexOf("user/" + userId + "/tag/") >= 0);
    }

    /*
     * Get subscriptions
     */
    function getSubscriptions() {
        busy = true;
        FeedlyAPI.call("subscriptions", null, subscriptionsDoneCB, accessToken);
    }

    function subscriptionsDoneCB(retObj) {
        if (checkResponse(retObj, subscriptionsDoneCB)) {
            var tmpSubscriptions = [];
            feedsListModel.clear();
            uniqueFeeds = 0;
            if (Array.isArray(retObj.response)) {
                for (var i = 0; i < retObj.response.length; i++) {
                    uniqueFeeds++;
                    var tmpObj = retObj.response[i];
                    var j = 0;
                    if (!tmpObj.categories.length) tmpObj.categories = [ { "id": "user/" + userId + "/category/global.uncategorized", "label": qsTr("Uncategorized")} ];
                    do {
                        tmpSubscriptions.push({ "id": tmpObj.id,
                                                "title": tmpObj.title,
                                                "category": tmpObj.categories[j].label.trim(),
                                                "categoryId": tmpObj.categories[j].id,
                                                "categories": tmpObj.categories,
                                                "imgUrl": ((typeof tmpObj.visualUrl !== "undefined") ? tmpObj.visualUrl : ""),
                                                "lang": ((typeof tmpObj.language !== "undefined") ? tmpObj.language : ""),
                                                "unreadCount": 0,
                                                "busy": false });
                        j++;
                    } while (j < tmpObj.categories.length);
                }
                // Sort subscriptions by category
                tmpSubscriptions.sort(function (a, b) {
                    if (a.category > b.category) return 1;
                    if (a.category < b.category) return -1;
                    return 0;
                });
                if (tmpSubscriptions.length) {
                    // Add "Saved for later" and "All feeds" fake subscription
                    if (userId) {
                        feedsListModel.append({ "id": "user/" + userId + "/tag/global.saved",
                                                "title": qsTr("Saved for later"),
                                                "category": "",
                                                "categoryId": "",
                                                "categories": [],
                                                "imgUrl": "",
                                                "lang": "",
                                                "unreadCount": 0,
                                                "busy": false });
                        feedsListModel.append({ "id": "user/" + userId + "/category/global.all",
                                                "title": qsTr("All feeds"),
                                                "category": "",
                                                "categoryId": "user/" + userId + "/category/global.all",
                                                "categories": [],
                                                "imgUrl": "",
                                                "lang": "",
                                                "unreadCount": 0,
                                                "busy": false });
                    }
                    // Populate ListModel
                    var currentCatId = "";
                    for (i = 0; i < tmpSubscriptions.length; i++) {
                        tmpObj = tmpSubscriptions[i];
                        // Add category fake subscription
                        if (tmpObj.categoryId && (tmpObj.categoryId !== currentCatId)) {
                            currentCatId = tmpObj.categoryId;
                            feedsListModel.append({ "id": currentCatId,
                                                    "title": tmpObj.category,
                                                    "category": tmpObj.category,
                                                    "categoryId": currentCatId,
                                                    "categories": [],
                                                    "imgUrl": "",
                                                    "lang": "",
                                                    "unreadCount": 0,
                                                    "busy": false });
                        }
                        feedsListModel.append(tmpObj);
                    }
                }
            }
            busy = false;
            if (feedsListModel.count > 0) {
                getMarkersCounts();
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
        } else error(qsTr("No accessToken found."));
    }

    function markersCountsDoneCB(retObj) {
        if (checkResponse(retObj, markersCountsDoneCB)) {
            if (Array.isArray(retObj.response.unreadcounts)) {
                totalUnread = 0;
                for (var i = 0; i < retObj.response.unreadcounts.length; i++) {
                    var tmpObj = retObj.response.unreadcounts[i];
                    var tmpTotUnreadUpd = false;
                    for (var j = 0; j < feedsListModel.count; j++) {
                        if (feedsListModel.get(j).id === tmpObj.id) {
                            feedsListModel.setProperty(j, "unreadCount", tmpObj.count);
                            if (userId) {
                                if (tmpObj.id === ("user/" + userId + "/category/global.all")) totalUnread = tmpObj.count;
                            } else {
                                if (!tmpTotUnreadUpd) {
                                    totalUnread += tmpObj.count;
                                    tmpTotUnreadUpd = true;
                                }
                            }
                        }
                    }
                }
            }
            busy = false;
            markersCountRefreshed();
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
            var param = { "streamId": subscriptionId, "count": 40, "ranked": entriesSorting(), "unreadOnly": "true", "continuation": (more ? continuation : "") };
            FeedlyAPI.call("streamContent", param, streamContentDoneCB, accessToken);
        } else error(qsTr("No subscriptionId found."));
    }

    function streamContentDoneCB(retObj) {
        if (checkResponse(retObj, streamContentDoneCB)) {
            var stripNewlines = new RegExp("\\r?\\n|\\r", "g");
            var stripHtmlTags = new RegExp("<[^>]*>", "gi");
            var normalizeSpaces = new RegExp("\\s+", "g");
            var htmlEntitiesMap = [
                        [ "&quot;", "\"" ],
                        [ "&apos;", "'" ],
                        [ "&amp;", "&" ],
                        [ "&gt;", ">" ],
                        [ "&lt;", "<"]
                    ];
            if (!retObj.callParams.continuation) articlesListModel.clear();
            continuation = ((typeof retObj.response.continuation != "undefined") ? retObj.response.continuation : "");
            if (Array.isArray(retObj.response.items)) {
                for (var i = 0; i < retObj.response.items.length; i++) {
                    var tmpObj = retObj.response.items[i];
                    // Create updated date object
                    var tmpUpd = new Date(((typeof tmpObj.updated !== "undefined") ? tmpObj.updated : tmpObj.published));
                    // Create section label from article's updated date
                    var tmpSection = Format.formatDate(new Date(tmpUpd.getFullYear(), tmpUpd.getMonth(), tmpUpd.getDate()), Formatter.TimepointSectionRelative);
                    if (!tmpSection) tmpSection = qsTr("Today");
                    // Create article's summary
                    var tmpSummary = ((typeof tmpObj.summary !== "undefined") ? tmpObj.summary.content : ((typeof tmpObj.content !== "undefined") ? tmpObj.content.content : ""));
                    if (tmpSummary) {
                        tmpSummary = tmpSummary.replace(stripHtmlTags, " ")
                        for (var j = 0; j < htmlEntitiesMap.length; j++) tmpSummary = tmpSummary.replace(new RegExp(htmlEntitiesMap[j][0], "g"), htmlEntitiesMap[j][1]);
                        tmpSummary = tmpSummary.replace(normalizeSpaces, " ").trim().substr(0, ((Screen.sizeCategory < Screen.Large) ? 320 : 640));
                    }
                    // Remove line breaks from article's title
                    var tmpTitle = ((typeof tmpObj.title !== "undefined") ? tmpObj.title : "");
                    if (tmpTitle) tmpTitle = tmpTitle.replace(stripNewlines, " ").trim();
                    articlesListModel.append({ "id": tmpObj.id,
                                               "title": (tmpTitle ? tmpTitle : qsTr("No title")),
                                               "author": ((typeof tmpObj.author !== "undefined") ? tmpObj.author : qsTr("Unknown")),
                                               "updated": tmpUpd,
                                               "sectionLabel": tmpSection,
                                               "imgUrl": (((typeof tmpObj.visual !== "undefined") && tmpObj.visual.url && tmpObj.visual.url !== "none") ? tmpObj.visual.url : ""),
                                               "unread": tmpObj.unread,
                                               "summary": (tmpSummary ? tmpSummary : qsTr("No preview")),
                                               "content": ((typeof tmpObj.content !== "undefined") ? tmpObj.content.content : ((typeof tmpObj.summary !== "undefined") ? tmpObj.summary.content : "")),
                                               "contentUrl": ((typeof tmpObj.alternate !== "undefined") ? tmpObj.alternate[0].href : ""),
                                               "streamId": ((typeof tmpObj.origin !== "undefined") ? tmpObj.origin.streamId : retObj.response.id),
                                               "streamTitle": ((typeof tmpObj.origin !== "undefined") ? tmpObj.origin.title : ((typeof retObj.response.title !== "undefined") ? retObj.response.title : "")),
                                               "busy": false,
                                               "tagging": false
                                             });
                }
            }
            busy = false;
            if (!retObj.callParams.continuation) getMarkersCounts();
        }
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Mark feed as read
     */
    function markFeedAsRead(feedId, lastEntryId) {
        if (feedId) {
            var param = { "action": "markAsRead" };
            if (streamIsCategory(feedId)) {
                param.type = "categories";
                param.categoryIds = [feedId];
            } else {
                param.type = "feeds";
                param.feedIds = [feedId];
            }
            if (lastEntryId) param.lastReadEntryId = lastEntryId;
            else param.asOf = Date.now();
            FeedlyAPI.call("markers", param, markFeedAsReadDoneCB, accessToken);
        } else error(qsTr("No feedId found."));
    }

    function markFeedAsReadDoneCB(retObj) {
        if (checkResponse(retObj, markFeedAsReadDoneCB)) {
            if (articlesListModel.count > 0) {
                var hasLastReadEntryId = (typeof retObj.callParams.lastReadEntryId !== "undefined");
                var lastModelIndex = null;
                for (var i = 0; i < articlesListModel.count; i++) {
                    if (hasLastReadEntryId && (articlesListModel.get(i).id === retObj.callParams.lastReadEntryId)) lastModelIndex = i;
                    if (!hasLastReadEntryId ||
                        ((entriesSorting() === 'oldest') && ((lastModelIndex === null) || (i <= lastModelIndex))) ||
                        ((entriesSorting() === 'newest') && (lastModelIndex !== null) && (i >= lastModelIndex))
                       ) articlesListModel.setProperty(i, "unread", false);
                }
            }
            busy = false;
            getMarkersCounts();
        }
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Mark entry
     * Possible actions are: markAsRead, keepUnread, markAsSaved, markAsUnsaved
     */
    function markEntry(entryId, action) {
        var actions = ["markAsRead", "keepUnread", "markAsSaved", "markAsUnsaved"];
        if (actions.indexOf(action) >= 0) {
            if (entryId) {
                // Set item indicator accordingly to action
                if (articlesListModel.count > 0) {
                    for (var i = 0; i < articlesListModel.count; i++) {
                        if (articlesListModel.get(i).id === entryId) {
                            switch (action) {
                                case "markAsRead":
                                case "keepUnread":
                                    articlesListModel.setProperty(i, "busy", true);
                                    break;
                                case "markAsSaved":
                                case "markAsUnsaved":
                                    articlesListModel.setProperty(i, "tagging", true);
                                    break;
                            }
                        }
                    }
                }
                var param = { "action": action, "type": "entries", "entryIds": [entryId] };
                FeedlyAPI.call("markers", param, markEntryDoneCB, accessToken);
            } else error(qsTr("No entryId found."));
        } else error(qsTr("Unknown marker action."));
    }

    function markEntryDoneCB(retObj) {
        var entryId = retObj.callParams.entryIds[0];
        var articleIdx = -1;
        var streamId = "";
        if (entryId && (articlesListModel.count > 0)) {
            for (var i = 0; i < articlesListModel.count; i++) {
                if (articlesListModel.get(i).id === entryId) {
                    switch (retObj.callParams.action) {
                        case "markAsRead":
                        case "keepUnread":
                            articlesListModel.setProperty(i, "busy", false);
                            break;
                        case "markAsSaved":
                        case "markAsUnsaved":
                            articlesListModel.setProperty(i, "tagging", false);
                            break;
                    }
                    articleIdx = i;
                    streamId = articlesListModel.get(i).streamId;
                }
            }
        }
        if (checkResponse(retObj, markEntryDoneCB)) {
            if (articleIdx >= 0) {
                var unreadCountChanged = false;
                switch (retObj.callParams.action) {
                    case "markAsRead":
                        if (articlesListModel.get(articleIdx).unread) {
                            articlesListModel.setProperty(articleIdx, "unread", false);
                            unreadCountChanged = true;
                        }
                        break;
                    case "keepUnread":
                        if (!articlesListModel.get(articleIdx).unread) {
                            articlesListModel.setProperty(articleIdx, "unread", true);
                            unreadCountChanged = true;
                        }
                        break;
                    case "markAsSaved":
                        break;
                    case "markAsUnsaved":
                        entryUnsaved(articleIdx);
                        break;
                }
                if (unreadCountChanged) {
                    var categories = [];
                    var tmpUnreadCount = 0;
                    if ((retObj.callParams.action === "markAsRead") && (totalUnread > 0)) totalUnread--;
                    else if (retObj.callParams.action === "keepUnread") totalUnread++;
                    for (var j = 0; j < feedsListModel.count; j++) {
                        if (feedsListModel.get(j).id.indexOf("/category/global.all") >= 0) feedsListModel.setProperty(j, "unreadCount", totalUnread);
                        if (feedsListModel.get(j).id === streamId) {
                            tmpUnreadCount = feedsListModel.get(j).unreadCount;
                            if ((retObj.callParams.action === "markAsRead") && (tmpUnreadCount > 0)) tmpUnreadCount--;
                            else if (retObj.callParams.action === "keepUnread") tmpUnreadCount++;
                            feedsListModel.setProperty(j, "unreadCount", tmpUnreadCount);
                            if (!categories.length && feedsListModel.get(j).categories.count) {
                                for (var k = 0; k < feedsListModel.get(j).categories.count; k++) {
                                    categories.push(feedsListModel.get(j).categories.get(k).id);
                                }
                            }
                        }
                    }
                    if (categories.length) {
                        for (j = 0; j < feedsListModel.count; j++) {
                            if (categories.indexOf(feedsListModel.get(j).id) >= 0) {
                                tmpUnreadCount = feedsListModel.get(j).unreadCount;
                                if ((retObj.callParams.action === "markAsRead") && (tmpUnreadCount > 0)) tmpUnreadCount--;
                                else if (retObj.callParams.action === "keepUnread") tmpUnreadCount++;
                                feedsListModel.setProperty(j, "unreadCount", tmpUnreadCount);
                            }
                        }
                    }
                }
            }
        }
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Search feed
     */
    function searchFeed(searchString) {
        if (searchString) {
            var param = { "q": searchString, "n": 20, "locale": Qt.locale().name };
            FeedlyAPI.call("searchFeed", param, searchFeedDoneCB, accessToken);
        } else error(qsTr("No search string or URL given."));
    }

    function searchFeedDoneCB(retObj) {
        if (checkResponse(retObj, searchFeedDoneCB)) {
            var results = [];
            if (Array.isArray(retObj.response.results)) {
                for (var i = 0; i < retObj.response.results.length; i++) {
                    var tmpObj = retObj.response.results[i];
                    results.push({ "id": tmpObj.feedId,
                                   "title": tmpObj.title,
                                   "description": ((typeof tmpObj.description !== "undefined") ? tmpObj.description : ""),
                                   "imgUrl": ((typeof tmpObj.visualUrl !== "undefined") ? tmpObj.visualUrl : ""),
                                   "lang": ((typeof tmpObj.language !== "undefined") ? tmpObj.language : ""),
                                   "subscribers": tmpObj.subscribers });
                }
            }
            searchFeedCompleted(results);
        }
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Update subscription
     */
    function updateSubscription(subscriptionId, title, categories) {
        if (subscriptionId) {
            busy = true;
            var param = { "id": subscriptionId }
            if (title) param.title = title;
            if (Array.isArray(categories) && categories.length) param.categories = categories
            FeedlyAPI.call("updateSubscription", param, updateSubscriptionDoneCB, accessToken);
        } else error(qsTr("No subscriptionId found."));
    }

    function updateSubscriptionDoneCB(retObj) {
        if (checkResponse(retObj, updateSubscriptionDoneCB)) {
            busy = false;
            getSubscriptions();
        }
        // DEBUG
        // console.log(JSON.stringify(retObj));
    }

    /*
     * Unsubscribe
     */
    function unsubscribe(subscriptionId) {
        if (subscriptionId) {
            // Mark single feed item as busy
            for (var j = 0; j < feedsListModel.count; j++) {
                if (feedsListModel.get(j).id === subscriptionId) feedsListModel.setProperty(j, "busy", true);
            }
            FeedlyAPI.call("unsubscribe", subscriptionId, unsubscribeDoneCB, accessToken);
        } else error(qsTr("No subscriptionId found."));
    }

    function unsubscribeDoneCB(retObj) {
        var unreadCount = 0;
        var j = 0;
        if (retObj.callParams) {
            for (j = 0; j < feedsListModel.count; j++) {
                if (feedsListModel.get(j).id === retObj.callParams) {
                    feedsListModel.setProperty(j, "busy", false);
                    if (!unreadCount) unreadCount = feedsListModel.get(j).unreadCount;
                }
            }
        }
        if (checkResponse(retObj, unsubscribeDoneCB)) {
            for (j = 0; j < feedsListModel.count; j++) {
                if (feedsListModel.get(j).id.indexOf("/category/global.all") >= 0) {
                    feedsListModel.setProperty(j, "unreadCount", (feedsListModel.get(j).unreadCount - unreadCount));
                }
                if (feedsListModel.get(j).id === retObj.callParams) feedsListModel.remove(j);
            }
        }
    }

    /*
     * Get categories
     */
    function getCategories() {
        busy = true;
        FeedlyAPI.call("categories", null, categoriesDoneCB, accessToken);
    }

    function categoriesDoneCB(retObj) {
        if (checkResponse(retObj, categoriesDoneCB)) {
            var categories;
            if (Array.isArray(retObj.response)) categories = retObj.response;
            else categories = [];
            busy = false;
            getCategoriesCompleted(categories);
        }
    }

    /*
     * Create new categoryId from its label
     */
    function createCategoryId(label) {
        return "user/" + userId + "/category/" + label.trim().toLowerCase().replace(/\s/gi, "_");
    }

    /*
     * Delete a category
     */
    function deleteCategory(categoryId) {
        if (categoryId) {
            busy = true;
            FeedlyAPI.call("deleteCategory", categoryId, deleteCategoryDoneCB, accessToken);
        } else error(qsTr("No categoryId found."));
    }

    function deleteCategoryDoneCB(retObj) {
        if (checkResponse(retObj, deleteCategoryDoneCB)) {
            busy = false;
            getSubscriptions();
        }
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
     * Load error indicator item when needed
     */
    function _createErrorIndicator() {
        var retVal = true;

        if (_errorIndicator === null) {
            var component = Qt.createComponent("ErrorIndicator.qml");
            if (component.status === Component.Ready) _errorIndicator = component.createObject(null);
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

    /*
     * Get current entries sorting value
     */
    function entriesSorting() {
        var sortOpt = 'newest';

        if ((typeof settings !== 'undefined') && (settings.articlesOrder === 1)) sortOpt = 'oldest';
        return sortOpt;
    }

    onBusyChanged: {
        if (_createStatusIndicator()) _statusIndicator.visible = busy;
    }

    onSignedInChanged: {
        if (signedIn) getSubscriptions();
        else resetProperties();
    }

    onError: {
        if (_createErrorIndicator()) _errorIndicator.show(message);
    }

    Component.onCompleted: {
        var useTest = (feedlyClientId === "sandbox");
        FeedlyAPI.init(useTest);
        feedsListModel = Qt.createQmlObject('import QtQuick 2.0; ListModel { }', feedly);
        articlesListModel = Qt.createQmlObject('import QtQuick 2.0; ListModel { }', feedly);
        DB.getAuthTokens(feedly);
        if (refreshToken) {
            var tmpDate = new Date();
            tmpDate.setHours(tmpDate.getHours() + 1);
            if (!accessToken || (expires < tmpDate.getTime())) getAccessToken();
            else signedIn = true;
        }
    }
}
