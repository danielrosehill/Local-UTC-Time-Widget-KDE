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

function format(hebrew, withYear, monthFirst) {
    if (!hebrew || !hebrew.hd || !hebrew.hm) return "";
    if (monthFirst) {
        return withYear ? (hebrew.hm + " " + hebrew.hd + " " + hebrew.hy)
                        : (hebrew.hm + " " + hebrew.hd);
    }
    return withYear ? (hebrew.hd + " " + hebrew.hm + " " + hebrew.hy)
                    : (hebrew.hd + " " + hebrew.hm);
}
