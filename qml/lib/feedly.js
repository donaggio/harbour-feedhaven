.pragma library

var _clientID = "sandbox";
var _clientSecret = "W60IW73DYSUIISZX4OUP";
var _apiCallBaseUrl = "http://sandbox.feedly.com/v3/";
var _redirectUri = "urn:ietf:wg:oauth:2.0:oob";
var _apiCalls = {
    "auth": { "method": "GET", "url": _apiCallBaseUrl + "auth/auth?response_type=code&scope=https://cloud.feedly.com/subscriptions&client_id=" + _clientID + "&redirect_uri=" + _redirectUri },
    "authRefreshToken": { "method": "POST", "url": _apiCallBaseUrl +  "auth/token" },
    "subscriptions": { "method": "GET", "url": _apiCallBaseUrl + "subscriptions" },
    "markers": { "method": "POST", "url": _apiCallBaseUrl + "markers" },
    "markersCounts": { "method": "GET", "url": _apiCallBaseUrl + "markers/counts" },
    "streamContent": { "method": "GET", "url": _apiCallBaseUrl + "streams/contents" },
    "entries": { "method": "GET", "url": _apiCallBaseUrl + "entries" }
}

/*
 * Make a call to API method "method" passing input parameters "param" and acces token "accessToken"
 * Callback function "callback" will be called after a response has been received
 */
function call(method, param, callback, accessToken) {
    var xhr = new XMLHttpRequest();
    var url = _apiCalls[method].url;

    if ((_apiCalls[method].method === "GET") && (param !== null)) {
        if (typeof param === "object") {
            var queryString = [];
            for (var p in param) {
                if (param.hasOwnProperty(p)) {
                    queryString.push(encodeURIComponent(p) + "=" + encodeURIComponent(param[p]));
                }
            }
            url += ("?" + queryString.join("&"));
        } else url += ("/" + encodeURIComponent(param));
    }

    xhr.timeout = 10000;
    xhr.open(_apiCalls[method].method, url, true);
    if (accessToken !== "") xhr.setRequestHeader("Authorization", "OAuth " + accessToken);
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
        }
    }
    xhr.ontimeout = function() { console.log("API call timeot"); }
    if ((_apiCalls[method].method === "POST") && (param !== null) && (typeof param === "object")) {
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify(param));
    } else xhr.send();
}
