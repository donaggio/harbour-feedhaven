/*
  Copyright (C) 2014 Luca Donaggio
  Contact: Luca Donaggio <donaggio@gmail.com>
  All rights reserved.

  You may use this file under the terms of MIT license

  Feedly API wrapper
*/

.pragma library

var _isInitialized = false;
var _apiCallBaseUrl;
var _redirectUri = "urn:ietf:wg:oauth:2.0:oob";
var _apiCalls = {
    "auth": { "method": "GET", "protocol": "https", "url": "auth/auth?response_type=code&scope=https://cloud.feedly.com/subscriptions&redirect_uri=" + _redirectUri + "&client_id=" },
    "authRefreshToken": { "method": "POST", "protocol": "https", "url":  "auth/token" },
    "subscriptions": { "method": "GET", "protocol": "https", "url": "subscriptions" },
    "markers": { "method": "POST", "protocol": "http", "url": "markers" },
    "markersCounts": { "method": "GET", "protocol": "http", "url": "markers/counts" },
    "streamContent": { "method": "GET", "protocol": "http", "url": "streams/contents" },
    "entries": { "method": "GET", "protocol": "http", "url": "entries" },
    "searchFeed": { "method": "GET", "protocol": "http", "url": "search/feeds" },
    "updateSubscription": { "method": "POST", "protocol": "https", "url": "subscriptions" },
    "unsubscribe": { "method": "DELETE", "protocol": "https", "url": "subscriptions" },
    "categories": { "method": "GET", "protocol": "http", "url": "categories" },
    "deleteCategory": { "method": "DELETE", "protocol": "https", "url": "categories" }
}

/*
 * Initialize API
 */
function init(useTest) {
    if (!_isInitialized) {
        if (useTest) _apiCallBaseUrl = "sandbox.feedly.com/v3/";
        else _apiCallBaseUrl = "cloud.feedly.com/v3/";
        _isInitialized = true;
    }
}

/*
 * Make a call to API method "method" passing input parameters "param" and acces token "accessToken"
 * Callback function "callback" will be called after a response has been received
 */
function call(method, param, callback, accessToken) {
    var xhr = new XMLHttpRequest();
    var url = _apiCalls[method].protocol + "://" + _apiCallBaseUrl + _apiCalls[method].url;

    if (((_apiCalls[method].method === "GET") || (_apiCalls[method].method === "DELETE")) && (param !== null)) {
        if ((_apiCalls[method].method === "GET") && (typeof param === "object")) {
            var queryString = [];
            for (var p in param) {
                if (param.hasOwnProperty(p)) {
                    queryString.push(encodeURIComponent(p) + "=" + encodeURIComponent(param[p]));
                }
            }
            url += ("?" + queryString.join("&"));
        } else url += ("/" + encodeURIComponent(param));
    }

    // Timeout is not implemented yet in this version of the XMLHttpRequest object
    xhr.timeout = 10000;
    xhr.ontimeout = function() {
        console.log("API call timeout");
    }
    xhr.open(_apiCalls[method].method, url, true);
    if (accessToken) xhr.setRequestHeader("Authorization", "OAuth " + accessToken);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            var tmpResp;
            if (xhr.responseText) {
                try {
                    tmpResp = JSON.parse(xhr.responseText);
                } catch (exception) {
                    // Not a valid JSON response
                    tmpResp = null;
                }
            }
            var retObj = { "status": xhr.status, "response": tmpResp, "callMethod": method, "callParams": param };
            // DEBUG
            // console.log(JSON.stringify(retObj));
            callback(retObj);
            delete xhr;
        }
    }
    if ((_apiCalls[method].method === "POST") && (param !== null) && (typeof param === "object")) {
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify(param));
    } else xhr.send();
}
