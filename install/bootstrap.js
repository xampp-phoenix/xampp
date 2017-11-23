function echo(text) {
    if(/cscript.exe$/i.test(WScript.FullName)){
        WScript.StdOut.Write(text + '\n');
    }
}
function xmlhttp(method, url, data) {
    try {
        var xhr = new ActiveXObject('Msxml2.ServerXMLHTTP');
        xhr.setOption(2, 13056);
    } catch (e){
        try {
            echo('failback to Msxml2.XMLHTTP');
            xhr = new ActiveXObject('Msxml2.XMLHTTP');
        } catch (e) {
            try {
                echo('failback to Microsoft.XMLHTTP');
                xhr = new ActiveXObject('Microsoft.XMLHTTP');
            } catch (e) {
                echo('error: no xmlhttp!');
                return null;
            }
        }
    }
    xhr.open(method, url, false);
    xhr.setRequestHeader('User-Agent','Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)');
    xhr.setRequestHeader('Referer',url.replace(/[^/]*$/, ''));
    xhr.send(data);
    if (xhr.readyState != 4 || xhr.status > 400){
        echo('error: ready=' + xhr.readyState + ', status=' + xhr.status);
        return null;
    }
    return xhr;
}

function download(method, url, data, savepath) {
    var xhr = xmlhttp(method, url, data);
    if (xhr) {
        var stm = new ActiveXObject('ADODB.Stream');
        stm.Type = 1;
        stm.Open();
        stm.Write(xhr.responseBody);
        stm.SaveToFile(savepath, 2);
        stm.Close();
        stm = null;
    } else {
        WScript.echo('error: download fail!');
    }
}
var busybox32 = 'https://frippery.org/files/busybox/busybox_safe.exe';
var busybox64 = 'https://frippery.org/files/busybox/busybox64.exe';
var busybox = 'busybox.exe'
var wget32='https://eternallybored.org/misc/wget/releases/old/wget-1.16-win32.zip'
var wget64='https://eternallybored.org/misc/wget/releases/old/wget-1.16-win64.zip'
var wget='wget-1.16-win.zip'
if (WScript.Arguments.Count() > 0 && WScript.Arguments.Item(0).toLowerCase() == 'win64') {
    download('GET', busybox64, null, busybox);
//    download('GET', wget64, null, wget);
} else {
    download('GET', busybox32, null, busybox);
//    download('GET', wget32, null, wget);
}
