#!/bin/sh

curdir=$PWD
installdir=$(dirname $0)
installdir=$(cd ${installdir}; pwd)
rootdir=$(cd ${installdir}/..; pwd)
tmpdir=${rootdir}/tmp
sysroot=${tmpdir}/sysroot


init_runtime()
{
    OS=$(uname -s)
    ARCH=$(uname -m)
    case $ARCH in
        i?86) bit=32;;
        x86_64) bit=64;;
        *) echo "Unsupported ARCH $ARCH." ; exit 1;;
    esac
    case $OS in
        Linux) init_linux;;
        Windows_NT) init_win32;;
        *) echo "Unsupported OS $OS." ; exit 1;;
    esac

    #sh --help 2>&1 | grep -i -q busybox && return 0
}

init_linux()
{
    #wget=${tmpdir}/wget
    #curl=${tmpdir}/curl
    #busybox=${tmpdir}/busybox
    #local url=https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/
    #local name=busybox-${ARCH/i586/i486}
    wget=$(which wget 2>/dev/null)
    curl=$(which curl 2>/dev/null)
    busybox=$(which busybox 2>/dev/null)
    wget=${wget:-nofound}
    curl=${curl:-nofound}
    busybox=${busybox:-nofound}
}

init_win32()
{
    wget=${tmpdir}/wget.exe
    curl=${tmpdir}/curl.exe
    busybox=${tmpdir}/busybox.exe
    cachedir=${tmpdir}/cache/x${bit}

}

download()
{
    local url=$1 baseurl=$2
    local user_agent=${USER_AGENT:-'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36'}
    local user_cookie=${USER_COOKIE}
    local name=${url##*/}
    echo ${name} | grep -E -q '\.(zip|gz|bz2|xz|exe|msi)' || name=$(echo ${url} | md5sum | cut -d\  -f1).htm
    download=${cachedir}/${name}
    [ -f ${download} ] && return 0
    [ "${url:0:1}" = "/" ] && url=$(echo ${baseurl} | sed -E 's@(.*://[^/]*)/.*@\1@')${url}
    echo ${url} | grep -E -q '^(http|https|ftp)://' || url="${baseurl%/*}/${url}"
    echo ">get ${url}"
    echo "->${download}"
    if [ -f ${wget} ]; then
        ${wget} --quiet --show-progress --progress=bar:force --tries 5 --retry-connrefused \
            --no-check-certificate --no-cookies --user-agent="${user_agent}" --header "Cookie: ${user_cookie}" \
            --referer="${baseurl}" --output-document=${name}.tmp ${url}
    elif [ -f ${curl} ]; then
        ${curl} --progress-bar --tlsv1 --retry 5 --retry-connrefused --ssl-no-revoke --location \
            --user-agent "${user_agent}" --cookie "${user_cookie}" --referer "${baseurl}" --output ${name}.tmp ${url} 
    elif [ -f ${busybox} ]; then
        ${busybox} wget --user-agent="${user_agent}" --header "Cookie: ${user_cookie}" --output-document=${name}.tmp ${url}
    else
        echo 'Nerthor curl nor wget.'
        exit 1
    fi
    if [ $? = 0 ]; then
        mv -f ${name}.tmp ${download}
    else
        rm -f ${name}.tmp
        return 1
    fi
}

URL_BUSYBOX=http://dl.uxnr.de/build/curl/
URL_CURL=http://dl.uxnr.de/build/curl/
URL_WGET=https://eternallybored.org/misc/wget/releases/old/

init_runtime
