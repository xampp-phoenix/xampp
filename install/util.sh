#!/bin/sh

debug=1

URL_BUSYBOX='https://frippery.org/files/busybox/'
URL_CURL='http://dl.uxnr.de/build/curl/'
URL_WGET='https://eternallybored.org/misc/wget/releases/old/'

URL_APACHE='https://www.apachelounge.com/download/'
URL_PHP='http://windows.php.net/downloads/'
URL_MARIADB='https://downloads.mariadb.org/mariadb/+files/?os_group=windows&file_type=zip'
URL_PERL='http://strawberryperl.com/releases.html'
URL_PHPMYADMIN='https://www.phpmyadmin.net/files/'
URL_TOMCAT='https://tomcat.apache.org/'
URL_JAVA='http://www.oracle.com/technetwork/java/javase/downloads/index.html'
URL_PYTHON='https://www.python.org/downloads/windows/'

URL_VC11='https://www.microsoft.com/en-us/download/confirmation.aspx?id=30679'
URL_VC14='https://www.microsoft.com/en-us/download/confirmation.aspx?id=48145'
URL_VC15X32='https://go.microsoft.com/fwlink/?LinkId=746571'
URL_VC15X64='https://go.microsoft.com/fwlink/?LinkId=746572'

URL_SENDMAIL='https://github.com/xampp-phoenix/sendmail/releases'
URL_XAMPP_CONTROL='https://github.com/xampp-phoenix/xampp-control-panel/releases'

modules='php mariadb perl phpmyadmin tomcat java sendmail xampp_control'

curdir=$PWD
installdir=`dirname $0`
installdir=`cd ${installdir};pwd`
rootdir=`cd ${installdir}/..;pwd`
tmpdir=${rootdir}/tmp

curl=$installdir/curl.exe
wget=$installdir/wget.exe

win32='x86[^_]|[wW]in32|32bit|i586|i686|mingw32'
win64='x64|[wW]in64|64bit|amd64|x86_64|mingw64'
unstable='\.[0-9]+\.[ab]|rc[a-z0-9]*\s'

java_cookie='gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie'

bit=`uname -m`
bit=${bit/i?86/32}
bit=${bit/x86_/}

download()
{
    local url=$1 base=$2 cookie=$3 ua=$4
    local name=${url##*/}
    echo ${name} | egrep -q '\.(zip|gz|bz2|xz|exe|msi)' || name=`echo ${url} | md5sum | cut -d\  -f1`.htm
    download=${cachedir}/${name}
    [ -f ${download} ] && return 0
    #ua=${ua:-'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)'}
    ua=${ua:-'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36'}
    [ "${url:0:1}" == "/" ] && url=`echo ${base} | sed -E 's@(.*://[^/]*)/.*@\1@'`${url}
    echo ${url} | egrep -q '^(http|https|ftp)://' || url="${base%/*}/${url}"
    echo ">get ${url}"
    if [ -f ${wget} ]; then
        ${wget} --quiet --show-progress --progress=bar:force --tries 5 --retry-connrefused \
            --no-check-certificate --no-cookies --user-agent="${ua}" --header "Cookie: ${cookie}" \
            --referer="${base}" --output-document=${name}.tmp ${url}
    elif [ -f ${curl} ]; then
        ${curl} --progress-bar --tlsv1 --retry 5 --retry-connrefused --ssl-no-revoke --location \
            --user-agent "${ua}" --cookie "$cookie" --referer "${base}" --output ${name}.tmp ${url} 
    else
        wget --user-agent="${ua}" --header "Cookie: ${cookie}" --output-document=${name}.tmp ${url}
    fi
    if [ $? == 0 ]; then
        mv -f ${name}.tmp ${download}
    else
        rm -f ${name}.tmp
        return 1
    fi
}

html2txt()
{
    local name=$1 name1=${tmpdir}/${1##*/}.txt
    sed -E -e 's@<a @\n\0@gi' -e 's@>@\0\n@g' ${name} >${name1}
    sed -i -E -e '/href=|HREF=|"filepath":|"url":/!d' \
        -e 's@.*(href=|"filepath":|"url":)"([^"]*)".*@\2@ig' -e 's@\.zip/from/.*$@.zip@' \
        -e '/-src|-source|-[dD]ebug|-pdb|-nts|-latest|-test|-devel|-no64/d' ${name1}
    html2txt=${name1}
    [ -n "${debug}" ] || rm -f ${name}
}

unpackvc()
{
    local name=$1 path=$2
    rm -rf ${path}
    local offset=`strings -t d ${name} | egrep MSCF | awk -F\  '{print $1}'`
    mkdir -p ${path}/tmp
    local offset1=`echo "${offset}" | head -n1`
    local offset2=`echo "${offset}" | head -n2 | tail -n1`
    local size1=`expr \( $offset2 - $offset1 \) / 1024 + 1` 
    dd if=${name} of=${path}/tmp/part1.cab bs=1k skip=${offset1} iflag=skip_bytes count=${size1}
    dd if=${name} of=${path}/tmp/part2.cab bs=1k skip=${offset2} iflag=skip_bytes
    expand.exe -F:* ${path}/tmp/part1.cab ${path}/tmp >/dev/null
    expand.exe -F:* ${path}/tmp/part2.cab ${path}/tmp >/dev/null
    [ -f ${path}/tmp/0 ] || return 1
    local vcr=`sed -E -e 's@[<>]@\n@g' ${path}/tmp/0 | sed -E -e '/vcRuntimeMinimum.*cab/!d' -e 's@.*SourcePath="([^"]*)".*@\1@'`
    expand.exe -F:* ${path}/tmp/${vcr} ${path} >/dev/null
    rm -rf ${path}/tmp
    find ${path} -name 'F_CENTRAL_*' | while read name
    do
        name1=${name/F_CENTRAL_/}
        name1=${name1%_*}.dll
        mv -f ${name} ${name1}
    done
    find ${path} -name 'api_ms_*.dll' | while read name
    do
        mv ${name} ${name//_/-}
    done
}

unpack()
{
    local name=$1 path=${1##*/}
    echo ">unpack ${name##*/}"
    path=${path%.*}
    path=${tmpdir}/${path#.tar}
    [ -n "${name}" -a -f "${name}" ] || return 1
    [ -e ${path} ] && rm -rf ${path}
    mkdir -p ${path}
    case ${name##*.} in
        zip) unzip -q ${name} -d ${path};;
        gz)  tar xf ${name} -C ${path};;
        msi) msiexec -a ${name//\//\\} -qn TARGETDIR=${path//\//\\};;
        exe) unpackvc ${name} ${path};;
        *);;
    esac
    unpack=${path}
}


bootstrip()
{
    [ "${bit}" == "32" -o "${bit}" == "64" ] || { echo "unable detect your os, set to Win32";bit=32; }
    cachedir=${tmpdir}/cache/x${bit}
    mkdir -p ${tmpdir} ${cachedir}
    cd ${tmpdir}
    if ! [ -f ${curl} ] || ! ${curl} --version &>/dev/null;then
        curl=${tmpdir}/curl.exe
        if ! [ -f ${curl} ] || ! ${curl} --version &>/dev/null;then
            rm -f ${curl}
            local name=curl-7.55.1-60-g78b863d.zip
            local path=curl_winssl_msys2_mingw${bit}_stc/${name%-*-*}
            wget=: download ${path}/${name} ${URL_CURL}
            unpack ${download}
            mv -f ${unpack}/src/curl.exe ${curl}
            rm -rf ${unpack}
        fi
    fi
    if ! [ -f ${wget} ] || ! ${wget} --version &>/dev/null;then
        wget=${tmpdir}/wget.exe
        if ! [ -f ${wget} ] || ! ${wget} --version &>/dev/null;then
            rm -f ${wget}
            local name=wget-1.16.1-win${bit}.zip
            download ${name} ${URL_WGET} 
            unpack ${download}
            mv -f ${unpack}/wget.exe ${wget}
            rm -rf ${unpack}
        fi
    fi
}

menu_bit()
{
    echo '--------------------------------------------'
    echo '  1. x86_64/amd64/em64t (Win64)'
    echo '  2. x86/i386/i586/i686 (Win32)'
    echo '    ...'
    echo "  9. auto detect/native (Win${bit})"
    echo '  0. Cancel'
    echo '--------------------------------------------'
    while read -p ':' num
    do
        case $num in
            1) _bit=64;break;;
            2) _bit=32;break;;
            9) _bit=${bit};break;;
            0|q|n|c) echo 'Canceled...';exit 0;;
            *) echo 'Invalid!';;
        esac
    done
}

menu_xampp()
{
    local num
    echo '--------------------------------------------'
    echo '  1. Compatible with XAMPP 7.1.x'
    echo '  2. Compatible with XAMPP 7.0.x'
    echo '  3. Compatible with XAMPP 5.6.x'
    echo '  4. All newest stable releases'
    echo '  5. All newest unstable releases'
    echo '    ...'
    echo '  9. Manual'
    echo '  0. Cancel'
    echo '--------------------------------------------'
    while read -p ':' num
    do
        case $num in
            1) init_xampp 7.1;break;;
            2) init_xampp 7.0;break;;
            3) init_xampp 5.6;break;;
            4) init_stable;break;;
            5) init_unstable;break;;
            9) init_manual;break;;
            0|q|n|c) echo 'Canceled...';exit 0;;
            *) echo 'Invalid!';;
        esac
    done
}

init_xampp()
{
    local _v_php=$1 _v_mariadb=10.1 _v_perl=5.16 _v_tomcat=7.0 _v_phpmyadmin=4.7
    local _v_java _v_python _v_sendmail _v_xampp_control
    local m r name url
    _dist=php${1/./}
    init_releases
    for m in ${modules}
    do
        eval lst='${_lst_'$m'}'
        eval 'r=$_v_'$m
        name=`get_names ${lst} | standard | sort_vr | sed -E -e "/${unstable}/d"| egrep "^$r" | head -n1 | awk '{print $2}'`
        eval _name_$m='${name}'
        url=`fgrep "${name}" ${lst} | head -n1`
        eval _url_$m='${url}'
    done
}

init_stable()
{
    local m lst name text url
    _dist=stable
    init_releases
    for m in ${modules}
    do
        eval lst='${_lst_'$m'}'
        text=`get_names ${lst} | standard | sort_vr | sed -E -e "/${unstable}/d" | unique`
        name=`echo "${text}" | head -n1`
        if [ "$m" == "mariadb" ]; then
            local v=`echo ${name} | sed -E -e 's@.*-([0-9]+[.u][0-9]+[^-_]*(-(alpha|beta|rc)[0-9]*)?)[-_.].*@\1@g'`
            download ../$v ${URL_MARIADB}
            if egrep -q -i 'alpha|beta|rc|release candidate' ${download}; then
                name=`echo "${text}" | head -n2 | tail -n1`
            fi
            [ -n "${debug}" ] || rm -f ${download}
        elif [ "$m" == "tomcat" ];then
            local v=`echo ${name} | sed -E -e 's@.*-([0-9]+[.u][0-9]+[^-_]*(-(alpha|beta|rc)[0-9]*)?)[-_.].*@\1@g'`
            download download-${v//.*}0.cgi ${URL_TOMCAT}
            if egrep -q -i 'alpha|beta|rc|release candidate' ${download}; then
                name=`echo "${text}" | head -n2 | tail -n1`
            fi
            [ -n "${debug}" ] || rm -f ${download}
        fi
        eval _name_$m='${name}'
        url=`fgrep "${name}" ${lst} | head -n1`
        eval _url_$m='${url}'
    done
}

init_unstable()
{
    local m lst text url
    _dist=unstable
    init_releases
    for m in ${modules}
    do
        eval lst='${_lst_'$m'}'
        text=`get_names ${lst} | standard | sort_vr | head -n1 | awk '{print $2}'`
        eval _name_$m='${text}'
        url=`fgrep "${name}" ${lst} | head -n1`
        eval _url_$m='${url}'
    done
}

init_manual()
{
    local m 
    _dist=manual
    init_releases
    for m in ${modules}
    do
        init_menu $m
    done
}

init_menu()
{
    local m=$1 num name text lst
    eval lst='${_lst_'$m'}'
    text=`get_names ${lst} | standard | sort_vr | unique`
    echo '--------------------------------------------'
    echo "${text}" | while read n
    do
        num=`expr ${num:-0} + 1`
        printf "  %-4s%s\n" ${num}. $n
    done
    echo '--------------------------------------------'
    while read -p ':' num
    do
        num=`echo ${num} | sed 's@[^0-9]@@g'`
        [ -n "${num}" ] || continue
        [ ${num} -gt `echo "${text}" | wc -l` ] && continue
        [ "${num}" == "0" ] && { eval _name_$m='^$';break; }
        name=`echo "${text}" | head -n${num} | tail -n1`
        eval _name_$m=${name}
        url=`fgrep "${name}" ${lst} | head -n1`
        eval _url_$m='${url}'
        break
    done
}

init_print()
{
    local m num name url
    echo '--------------------------------------------'
    for m in apache fcgid xsendfile vc  ${modules}
    do
        eval name='$_name_'$m
        eval url='$_url_'$m
        [ -n "${name}" ] && echo "  ${name}"
    done
    echo '--------------------------------------------'
    while read -p ':' num
    do
        num=`echo ${num} | sed 's@[^a-z]@@gi' | tr A-Z a-z`
        case "${num}" in
            y|yes|o|ok) return ;;
            n|no|q|quit|exit) exit 1;;
            *) echo 'Invalid!';;
        esac
    done
}

init_releases()
{
    local 
    local url m
    for m in ${modules}
    do
        case $m in
            apache|php|tomcat|java) init_url_deep $m;;
            *) init_url_flat $m;;
        esac
        eval "_lst_$m=lst-url-$m.txt"
    done
}

init_url_vc()
{
    local url rbit lst=lst-url-vc.txt
    eval "rbit=\${win${_bit}}"
    _name_vc=vcredist-${_v_vc}-x${_bit}.exe
    if [ "${_v_vc}" == "VC11" -o "${_v_vc}" == "VC14"  ]; then
        eval 'url=${URL_'${_v_vc}'}'
        download ${url}
        html2txt ${download}
        sed -E -i -e '/.exe$/!d' -e "/${rbit}/!d" ${html2txt}
        mv -f ${html2txt} ${lst}
        _url_vc=`head -n1 ${lst}`
    else
        eval 'url=${URL_'${_v_vc}X${_bit}'}'
        _url_vc=${url}
    fi
}


init_url_apache()
{
    local name=apache url rbit lst=lst-url-apache.txt
    eval "rbit=\${win${_bit}}"
    url=${URL_APACHE}
    _v_vc=`echo ${_name_php} | sed -E -e 's@^.*(VC[0-9]+).*$@\1@'`
    download ${_v_vc} ${url}
    html2txt ${download}
    sed -i -E -e '/.zip$|.msi$/!d' -e "/${rbit}/!d" ${html2txt}
    mv -f ${html2txt} ${lst}
    _name_apache=`get_names ${lst} | egrep 'httpd' | head -n1`
    _url_apache=`egrep "${_name_apache}" ${lst} | head -n1`
    _name_fcgid=`get_names ${lst} | egrep 'fcgid' | head -n1`
    _url_fcgid=`egrep "${_name_fcgid}" ${lst} | head -n1`
    _name_xsendfile=`get_names ${lst} | egrep 'xsendfile' | head -n1`
    _url_xsendfile=`egrep "${_name_xsendfile}" ${lst} | head -n1`
}

init_url_flat()
{
    local name=$1 url rbit lst=lst-url-$1.txt
    eval "rbit=\${win${_bit}}"
    eval 'url="${URL_'`echo $name | tr a-z A-Z`'}"'
    download ${url}
    html2txt ${download}
    [ "${name}" == "phpmyadmin" ] && rbit=all-languages
    sed -i -E -e '/.zip$|.msi$/!d' -e '/mariadb_client/d' -e "/${rbit}/!d" ${html2txt}
    [ "${_bit}" == "32" ] && sed -i -E -e "/${win64}/d" ${html2txt}
    [ "${name}" == "perl" ] && sed -i -E -e '/-portable/!d' ${html2txt}
    sort -u -o ${lst} ${html2txt}
    rm -f ${html2txt}
}

init_url_deep()
{
    local name=$1 url rbit n idx lst=lst-url-$1.txt
    eval "rbit=\${win${_bit}}"
    eval 'url="${URL_'`echo $name | tr a-z A-Z`'}"'
    rm -f ${lst}
    if [ "${name}" == "php" ]; then
        idx=${tmpdir}/`echo ${url} | md5sum | cut -d\  -f1`.htm.txt
        echo -e "releases\nreleases/archives\nqa" >${idx}
    else
        download ${url}
        html2txt ${download}
        idx=${html2txt}
        case ${name} in
            apache) sed -i -E -e '/^\/download.*\/$/!d' ${idx};;
            tomcat) sed -i -E -e '/download-[0-9][0-9]\.cgi/!d' ${idx};;
            java) sed -i -E -e '/\/jre[^-]*-downloads/!d' ${idx};;
            *);;
        esac
        sort -u -o ${idx}.tmp ${idx}
        mv -f ${idx}.tmp ${idx}
    fi
    while read n
    do
        download $n ${url}
        html2txt ${download}
        cat ${html2txt} >> ${lst}
        rm -f ${html2txt}
    done <${idx}
    rm -f ${idx}
    case ${name} in
        apache|php|tomcat) sed -i -E -e '/.zip$/!d' -e "/${rbit}/!d" ${lst};;
        java) sed -i -E -e '/.tar.gz$/!d' -e '/[-_]windows/!d' -e "/$rbit/!d" ${lst};;
        *);;
    esac
    [ "${_bit}" == "32" ] && sed -i -E -e "/${win64}/d" ${lst}
    sort -u -o ${lst}.tmp ${lst}
    mv -f ${lst}.tmp ${lst}
}

get_names(){ sed -E -e 's@^.*/([^/]*)$@\1@' "$@";}

standard()
{
    sed -E -e 's@.*-([0-9]+[.u][0-9]+[^-_]*(-(alpha|beta|rc)[0-9]*)?)[-_.].*@\1\t\0@g' -e 's@\.amd64\t@\t@' \
        -e 's@([0-9])u([0-9]+\t)@\1.0.\2@' -e 's@-((alpha|beta|rc)[^\t]*\t)@\1@' -e 's@RC([^\t]*\t)@rc\1@' \
        -e 's@(\.[0-9]+)\t@\1rtm\t@' -e 's@([0-9])([abr][^\t]*\t)@\1.\2@i' -e 's@^(([0-9]+\.){2})([abr])@\10.0.\3@' \
        -e 's@^(([0-9]+\.){3})([abr])@\10.\3@' "$@" 

}

sort_vr(){ sort -t . -k1,1nr -k2,2nr -k3,3nr -k4,4nr -k5,5dr "$@";}

unique()
{
    local i m n
    while read n i
    do
        n=${n%.*.*.*}
        [ "$m" == "$n" ] && continue
        m=$n
        echo $i
    done
}

init_download()
{
    local m name url base URL_FCGID=${URL_APACHE} URL_XSENDFILE=${URL_APACHE}
    local mariadb_ua=wget cookie ua
    for m in apache fcgid xsendfile ${modules}
    do
        eval name='${_name_'$m'}'
        eval url='${_url_'$m'}'
        eval base='${URL_'`echo $m | tr a-z A-Z`'}'
        eval cookie=\$${m}_cookie
        eval ua=\$${m}_ua
        [ -n "${url}" ] || { echo $m ; continue;}
        download ${url} ${base} "${cookie}" ${ua}
    done
    if [ "${_bit}" == "32" ]; then
        _name_busybox=busybox_safe.exe
    else
        _name_busybox=busybox64.exe
    fi
    _name_wget=wget-1.16.1-win${_bit}.zip
    download ${_name_busybox} ${URL_BUSYBOX}
    download ${_name_wget} ${URL_WGET}

    _name_curl=curl-7.55.1-60-g78b863d-x${_bit}.zip
    [ -f "${cachedir}/${_name_curl}" ] || download curl_winssl_msys2_mingw${_bit}_stc/${_name_curl%-*-*-*}/${_name_curl/-x??./.} ${URL_CURL}
    [ -f "${cachedir}/${_name_curl/-x??./.}" ] && mv ${download} ${cachedir}/${_name_curl}

    [ -n "${_url_vc}" ] || return 
    [ -f ${cachedir}/${_name_vc} ] && return
    download ${_url_vc}
    mv -f ${download} ${cachedir}/${_name_vc}
}

install_new()
{
    unpack ${cachedir}/${_name_apache}
    mv ${unpack}/Apache24/ ${distdir}/apache 
    rm -rf ${distdir}/apache/cgi-bin ${distdir}/apache/htdocs
    cp -af ${rootdir}/apache/* ${distdir}/apache/ 
    rm -rf ${unpack}

    unpack ${cachedir}/${_name_fcgid}
    mv ${unpack}/mod_fcgid*/mod_fcgid.so ${distdir}/apache/modules/
    rm -rf ${unpack}

    unpack ${cachedir}/${_name_xsendfile}
    mv ${unpack}/mod_xsendfile.so ${distdir}/apache/modules/
    rm -rf ${unpack}

    unpack ${cachedir}/${_name_mariadb}
    mv ${unpack}/mariadb-*/ ${distdir}/mysql
    rm -rf ${distdir}/mysql/mysql-test ${distdir}/mysql/sql-bench
    find ${distdir}/mysql -name '*.pdb' -delete
    cp -af ${rootdir}/mysql/* ${distdir}/mysql/ 
    rm -f ${distdir}/mysql/data/ib*
    rm -rf ${unpack}
    
    unpack ${cachedir}/${_name_php}
    mv ${unpack}/ ${distdir}/php
    cp -af ${rootdir}/php/* ${distdir}/php/ 
    cp -f  ${distdir}/php/libssh2.dll ${distdir}/php/icu*.dll ${distdir}/apache/bin/ 
    rm -rf ${unpack}
    
    unpack ${cachedir}/${_name_perl}
    mv ${unpack}/perl/ ${distdir}/perl
    rm -rf ${unpack}
    
    unpack ${cachedir}/${_name_tomcat}
    mv ${unpack}/apache-tomcat-*/ ${distdir}/tomcat
    cp -af ${rootdir}/tomcat/* ${distdir}/tomcat/ 
    rm -rf ${unpack}
    
    unpack ${cachedir}/${_name_phpmyadmin}
    mv ${unpack}/phpMyAdmin-*/ ${distdir}/phpMyAdmin
    cp -af ${rootdir}/phpMyAdmin/* ${distdir}/phpMyAdmin/ 
    rm -rf ${unpack}
    
#    unpack ${cachedir}/${_name_python}
#    mv ${unpack}/ ${distdir}/python
#    rm -f ${distdir}/python/*.msi
#    rm -rf ${unpack}
    
    unpack ${cachedir}/${_name_java}
    mv ${unpack}/jre*/ ${distdir}/jre
    rm -rf ${unpack}

    unpack ${cachedir}/${_name_sendmail}
    mv ${unpack} ${distdir}/sendmail
    rm -rf $unpack

    unpack ${cachedir}/${_name_xampp_control}
    mv $unpack/*.exe/ ${distdir}/
    rm -rf $unpack

    unpack ${cachedir}/${_name_vc}
    cp $unpack/*.dll ${distdir}/apache/bin/
    cp $unpack/*.dll ${distdir}/php/
    rm -rf $unpack

    unpack ${cachedir}/${_name_wget}
    mkdir -p ${distdir}/install/
    mv -f ${unpack}/wget.exe ${distdir}/install/
    rm -rf ${unpack}

    unpack ${cachedir}/${_name_curl}
    mv -f ${unpack}/src/curl.exe ${distdir}/install/
    rm -rf ${unpack}

    cp -f ${cachedir}/${_name_busybox} ${distdir}/install/busybox.exe

    cp -a ${rootdir}/cgi-bin ${rootdir}/htdocs ${rootdir}/install ${rootdir}/licenses ${rootdir}/webdav ${rootdir}/locale ${distdir}/
    cp -a ${rootdir}/*.bat ${rootdir}/*.txt ${distdir}/
    cp -f ${rootdir}/src/xampp-usb-lite/setup_xampp.bat ${distdir}/
    cp -f ${rootdir}/src/xampp-usb-lite/xampp-control.ini ${distdir}/
    mv ${distdir}/htdocs/xampp/.modell-usb ${distdir}/htdocs/xampp/.modell
    mkdir -p ${distdir}/tmp
    sed -i -e 's@C:/strawberry@/xampp@g' ${distdir}/perl/lib/CPAN/Config.pm 
    sed -i -e 's@C:\\strawberry@\\xampp@g' ${distdir}/perl/bin/*.bat 
    sed -i -e 's@C:\\strawberry@\\xampp@g' ${distdir}/perl/lib/Config_heavy.pl
    sed -i -e 's@C:\\strawberry@\\xampp@g' ${distdir}/perl/vendor/lib/ppm.xml
    sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' ${distdir}/perl/lib/CPAN/Config.pm
    sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' ${distdir}/perl/lib/CORE/config.h
    sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' ${distdir}/perl/lib/Config.pm
    if echo ${_name_php} | egrep -q '\-5\.[0-9]'; then
        sed -i 's@php7@php5@g' ${distdir}/apache/conf/extra/httpd-xampp.conf
        sed -i 's@^extension=php_ftp.dll@;\0@' ${distdir}/php/php.ini
    fi
}


install()
{
    menu_bit
    cachedir=${tmpdir}/cache/x${_bit}
    mkdir -p ${tmpdir} ${cachedir}
    menu_xampp
    distdir=${tmpdir}/xampp-${_dist}-x${_bit}
    init_url_apache
    init_url_vc
    init_print
    init_download
    [ -d ${distdir} ] && rm -rf ${distdir}
    mkdir -p ${distdir}
    install_new
}

update()
{
    echo update
    distdir=$rootdir
    $distdir/apache/bin/httpd.exe -v | grep 'version' | sed -E 's@.*/([^ ]+) .*@\1@'
    $distdir/apache/bin/httpd.exe -v | grep 'version' | sed -E 's@.*(Win[0-9]+).*@\1@'
    $distdir/apache/bin/httpd.exe -v | grep 'VC' | sed -E 's@.*(VC[0-9]+).*@\1@'
    $distdir/php/php.exe -n --version | grep '^PHP' | awk '{print $2}'
    $distdir/php/php.exe -n --version | grep 'MSVC' | sed -E 's@^.*MS(VC[0-9]+) .*$@\1@'
    $distdir/php/php.exe -n --version | grep 'MSVC' | sed -E 's@^.* (x[0-9]+) .*$@\1@'
    $distdir/mysql/bin/mysql.exe --version | grep 'Distrib' | sed -E 's@^.*Distrib ([0-9.]+)-.*$@\1@'
    $distdir/perl/bin/perl.exe --version | grep 'version' | sed -E 's@^.*\(v([0-9.]+)\).*$@\1@'
    export JRE_HOME=$distdir/jre
    export CATALINA_HOME=$distdir/tomcat
    $distdir/jre/bin/java.exe -version 2>&1| grep '^java version' | awk '{print $3}' | sed -E -e 's@"@@g' -e 's@1.([0-9]).0_@\1u@'
    $distdir/tomcat/bin/version.bat --version | grep 'version' | sed -E 's@^.*Tomcat/([0-9.]+).*$@\1@'
    cat $distdir/phpMyAdmin/README | grep 'Version' | awk '{print $2}'
    hexdump -C $distdir/sendmail/sendmail.exe |tail -n 80|awk -F \| '{print $2}'|sed ':a;N;$!ba;s/\n//g'|sed -E 's@(.)\.@\1@g' | sed -E 's@.*FileVersion..(([0-9]+\.){3}+[0-9]+).*@\1@'
    hexdump -C $distdir/xampp-control.exe |tail -n 80|awk -F \| '{print $2}'|sed ':a;N;$!ba;s/\n//g'|sed -E 's@(.)\.@\1@g' | sed -E 's@.*FileVersion..(([0-9]+\.){3}[0-9]+).*@\1@'
}

main()
{
    if [ -n "$1" ];then
        local func=$1;shift
        ${func} "$@"
        return
    fi
    if [ -f ${rootdir}/xampp-control.exe -a -f ${rootdir}/xampp-control.ini ]; then
        update
    else
        install
    fi
}
bootstrip
main "$@"
