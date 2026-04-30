// Minimal Hebcal converter for the Local + UTC Time widget.
// Fetches Hebrew date for a given Gregorian date. No sunset logic.
.pragma library

function _key(d) {
    return d.getFullYear() + "-" + (d.getMonth() + 1) + "-" + d.getDate();
}

var _cache = {};

// cb(ok, { hd, hm, hy }, err)
function fetchHebrewDate(dateObj, cb) {
    var k = _key(dateObj);
    if (_cache[k]) { cb(true, _cache[k], ""); return; }
    try {
        var url = "https://www.hebcal.com/converter?cfg=json&g2h=1&strict=1"
            + "&gy=" + dateObj.getFullYear()
            + "&gm=" + (dateObj.getMonth() + 1)
            + "&gd=" + dateObj.getDate();
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            if (xhr.status !== 200) { cb(false, null, "HTTP " + xhr.status); return; }
            try {
                var data = JSON.parse(xhr.responseText);
                var out = { hd: data.hd, hm: data.hm, hy: data.hy };
                _cache[k] = out;
                cb(true, out, "");
            } catch (e) { cb(false, null, "Parse error: " + e); }
        };
        xhr.send();
    } catch (e) { cb(false, null, "Exception: " + e); }
}

function _sunsetKey(d, lat, lon) {
    return _key(d) + "|" + lat.toFixed(3) + "|" + lon.toFixed(3);
}

var _sunsetCache = {};

// cb(ok, Date|null, err). `dateObj` is the civil day to query; sunset returned in local time.
function fetchSunset(dateObj, lat, lon, tzid, cb) {
    var k = _sunsetKey(dateObj, lat, lon);
    if (_sunsetCache[k]) { cb(true, _sunsetCache[k], ""); return; }
    try {
        var iso = dateObj.getFullYear() + "-"
            + String(dateObj.getMonth() + 1).padStart(2, "0") + "-"
            + String(dateObj.getDate()).padStart(2, "0");
        var url = "https://www.hebcal.com/zmanim?cfg=json"
            + "&latitude=" + encodeURIComponent(lat)
            + "&longitude=" + encodeURIComponent(lon)
            + (tzid ? "&tzid=" + encodeURIComponent(tzid) : "")
            + "&date=" + iso;
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function () {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            if (xhr.status !== 200) { cb(false, null, "HTTP " + xhr.status); return; }
            try {
                var data = JSON.parse(xhr.responseText);
                var t = data && data.times && data.times.sunset;
                if (!t) { cb(false, null, "No sunset in response"); return; }
                var sunset = new Date(t);
                if (isNaN(sunset.getTime())) { cb(false, null, "Bad sunset value"); return; }
                _sunsetCache[k] = sunset;
                cb(true, sunset, "");
            } catch (e) { cb(false, null, "Parse error: " + e); }
        };
        xhr.send();
    } catch (e) { cb(false, null, "Exception: " + e); }
}

function format(hebrew, withYear, monthFirst) {
    if (!hebrew || !hebrew.hd || !hebrew.hm) return "";
    if (monthFirst) {
        return withYear ? (hebrew.hm + " " + hebrew.hd + " " + hebrew.hy)
                        : (hebrew.hm + " " + hebrew.hd);
    }
    return withYear ? (hebrew.hd + " " + hebrew.hm + " " + hebrew.hy)
                    : (hebrew.hd + " " + hebrew.hm);
}
