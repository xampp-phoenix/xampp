#!/bin/sh

curdir=$PWD
installdir=$(dirname $0)
installdir=$(cd ${installdir}; pwd)
rootdir=$(cd ${installdir}/..; pwd)
tmpdir=${rootdir}/tmp


init_runtime()
{
    OS=$(uname -s)
    ARCH=$(uname -m)
    mkdir -p ${tmpdir}
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
    win32='x86[^_]|[wW]in32|32bit|i586|i686|mingw32'
    win64='x64|[wW]in64|64bit|amd64|x86_64|mingw64'
    unstable='\.[0-9]+\.[ab]|rc[a-z0-9]*\s'
}

init_linux()
{
    wget=$(which wget 2>/dev/null)
    curl=$(which curl 2>/dev/null)
    busybox=$(which busybox 2>/dev/null)
    wget=${wget:-nofound}
    curl=${curl:-nofound}
    busybox=${busybox:-nofound}
    if ! which cabextract >/dev/null; then
        echo "cabextract not found, can not unpack vc_redist."
        exit 1;
    fi
}

init_win32()
{
    wget=${tmpdir}/wget.exe
    curl=${tmpdir}/curl.exe
    busybox=${tmpdir}/busybox.exe
    if ! which expand.exe >/dev/null; then
        echo "expand.exe not found, can not unpack vc_redist."
        exit 1;
    fi
    cachedir=${tmpdir}/cache/x${bit}
    local name=wget-1.16.1-win${bit}.zip
    download ${name} ${URL_WGET}
    unpack ${download}
	mv -f ${unpack}/wget.exe ${wget}
	rm -rf ${unpack}
}

download()
{
    local url=$1 baseurl=$2
    local user_agent=${USER_AGENT:-'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Safari/537.36'}
    local user_cookie=${USER_COOKIE}
    local name=${url##*/}
    if echo ${name} | grep -qvE '\.(zip|gz|bz2|xz|exe|msi)'; then
        local domain=$(echo ${baseurl:-${url}} | sed 's@.*//\([^/]*\)/.*@\1@')
        local hash=$(echo ${url} | sha1sum | cut -c1-8)
        name=${domain}-${hash}.htm
    fi
    download=${cachedir}/${name}
    [ -f ${download} ] && return 0

    if [ "${url:0:1}" = "/" ]; then
        url=$(echo ${baseurl} | sed -E 's@(.*://[^/]*)/.*@\1@')${url}
    elif echo ${url} | grep -qvE '^(http|https|ftp)://'; then
        url="${baseurl%/*}/${url}"
    fi
    echo ">get ${url}"
    (cd ${tmpdir};
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
    fi)
    if [ $? = 0 ]; then
        mv -f ${tmpdir}/${name}.tmp ${download}
    else
        rm -f ${tmpdir}/${name}.tmp
        return 1
    fi
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

unpackvc()
{
    local name=$1 path=$2
    rm -rf ${path}
    local offset=$(strings -t d ${name} | grep -E MSCF | awk -F\  '{print $1}')
    mkdir -p ${path}/tmp
    local offset1=$(echo "${offset}" | head -n1)
    local offset2=$(echo "${offset}" | head -n2 | tail -n1)
    local size1=$(expr \( $offset2 - $offset1 \) / 1024 + 1)
    dd status=none if=${name} of=${path}/tmp/part1.cab bs=1k skip=${offset1} iflag=skip_bytes count=${size1}
    dd status=none if=${name} of=${path}/tmp/part2.cab bs=1k skip=${offset2} iflag=skip_bytes
    if [ "${OS}" = "Windows_NT" ]; then
        expand.exe -F:* ${path}/tmp/part1.cab ${path}/tmp >/dev/null
        expand.exe -F:* ${path}/tmp/part2.cab ${path}/tmp >/dev/null
    else
        cabextract -q -d ${path}/tmp ${path}/tmp/part1.cab
        cabextract -q -d ${path}/tmp ${path}/tmp/part2.cab
    fi
    [ -f ${path}/tmp/0 ] || return 1
    local vcname=$(sed -E -e 's@[<>]@\n@g' ${path}/tmp/0 | sed -E -e '/vcRuntimeMinimum.*cab/!d' -e 's@.*SourcePath="([^"]*)".*@\1@')
    if [ "${OS}" = "Windows_NT" ]; then
        expand.exe -F:* ${path}/tmp/${vcname} ${path} >/dev/null
    else
        cabextract -q -d ${path} ${path}/tmp/${vcname}
    fi
    rm -rf ${path}/tmp
    find ${path} -name 'F_CENTRAL_*' -exec basename {} \; | while read name
    do
        name1=${name/F_CENTRAL_/}
        name1=${name1%_*}.dll
        mv -f ${path}/${name} ${path}/${name1}
    done
    find ${path} -name 'api_ms_*.dll' -exec basename {} \; | while read name
    do
        mv ${path}/${name} ${path}/${name//_/-}
    done
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

get_names()
{
	sed -E -e 's@^.*/([^/]*)$@\1@' "$@"
}

standard()
{
    sed -E -e 's@.*-([0-9]+[.u][0-9]+[^-_]*(-(alpha|beta|rc)[0-9]*)?)[-_.].*@\1\t\0@g' -e 's@\.amd64\t@\t@' \
        -e 's@([0-9])u([0-9]+\t)@\1.0.\2@' -e 's@-((alpha|beta|rc)[^\t]*\t)@\1@' -e 's@RC([^\t]*\t)@rc\1@' \
        -e 's@(\.[0-9]+)\t@\1rtm\t@' -e 's@([0-9])([abr][^\t]*\t)@\1.\2@i' -e 's@^(([0-9]+\.){2})([abr])@\10.0.\3@' \
        -e 's@^(([0-9]+\.){3})([abr])@\10.\3@' "$@"

}

sort_vr()
{
    sort -t . -k1,1nr -k2,2nr -k3,3nr -k4,4nr -k5,5dr "$@"
}

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
            1) mbit=64;break;;
            2) mbit=32;break;;
            9) mbit=${bit};break;;
            [0qncQNC]) echo 'Canceled...';exit 0;;
            *) echo 'Invalid!';;
        esac
    done
}

menu_main()
{
    local num
    echo '--------------------------------------------'
    echo '  1. Compatible with XAMPP 5.6.x'
    echo '  2. Compatible with XAMPP 7.0.x'
    echo '  3. Compatible with XAMPP 7.1.x'
    echo '  4. Compatible with XAMPP 7.2.x'
    echo '  5. Compatible with XAMPP 7.3.x'
    echo '  6. Compatible with XAMPP 7.4.x'
    echo '    ...'
    echo '  S. All latest stable releases'
    echo '  U. All latest unstable releases'
    echo '    ...'
    echo '  M. Manual'
    echo '  0. Cancel'
    echo '--------------------------------------------'
    while read -p ':' num
    do
        case $num in
            6) init_version_xampp 7.4;break;;
            5) init_version_xampp 7.3;break;;
            4) init_version_xampp 7.2;break;;
            3) init_version_xampp 7.1;break;;
            2) init_version_xampp 7.0;break;;
            1) init_version_xampp 5.6;break;;
            [sS]) init_version_stable;break;;
            [uU]) init_version_unstable;break;;
            [mM]) init_version_manual;break;;
            [0qncQNC]) echo 'Canceled...';exit 0;;
            *) echo 'Invalid!';;
        esac
    done
}


init_url_apache()
{
    local name=apache url rbit lst=${tmpdir}/lst-url-apache.txt
    eval "rbit=\${win${mbit}}"
    url=${URL_APACHE}
    v_vc=$(echo ${name_php} | sed -E -e 's@^.*(VC[0-9]+).*$@\1@i' | tr a-z A-Z)
    download ${v_vc} ${url}
    html2txt ${download}
    sed -i -E -e '/.zip$|.msi$/!d' -e "/${rbit}/!d" ${html2txt}
    mv -f ${html2txt} ${lst}
    name_apache=$(get_names ${lst} | grep 'httpd' | head -n1)
    url_apache=$(grep "${name_apache}" ${lst} | head -n1)
    name_fcgid=$(get_names ${lst} | grep 'fcgid' | head -n1)
    url_fcgid=$(grep "${name_fcgid}" ${lst} | head -n1)
    name_xsendfile=$(get_names ${lst} | grep 'xsendfile' | head -n1)
    url_xsendfile=$(grep "${name_xsendfile}" ${lst} | head -n1)
    rm -f ${lst}
}

init_url_vc()
{
    local url rbit lst=${tmpdir}/lst-url-vc.txt
    eval "rbit=\${win${mbit}}"
    name_vc=vc_redist-${v_vc/VC}-x${mbit}.exe
	eval "url=\${URL_${v_vc}}"
    if [ "${v_vc}" = "VC11" -o "${v_vc}" = "VC14"  ]; then
        download ${url}
        html2txt ${download}
        sed -E -i -e '/.exe$/!d' -e "/${rbit}/!d" ${html2txt}
        mv -f ${html2txt} ${lst}
        url_vc=$(head -n1 ${lst})
    else
        url_vc=${url}/VC_redist.x${mbit/32/86}.exe
    fi
    rm -f ${lst}
}

init_url_flat()
{
    local name=$1 url rbit lst=${tmpdir}/lst-url-$1.txt
    eval "rbit=\${win${mbit}}"
    eval "url=\${URL_$(echo ${name} | tr a-z A-Z)}"
    download ${url}
    html2txt ${download}
    [ "${name}" = "phpmyadmin" ] && rbit=all-languages
    sed -i -E -e '/.zip$|.msi$/!d' -e '/mariadb_client/d' -e "/${rbit}/!d" ${html2txt}
    [ "${mbit}" = "32" ] && sed -i -E -e "/${win64}/d" ${html2txt}
    [ "${name}" = "perl" ] && sed -i -E -e '/-portable/!d' ${html2txt}
    sort -u -o ${lst} ${html2txt}
    rm -f ${html2txt}
}

init_url_deep()
{
    local name=$1 url rbit n idx lst=${tmpdir}/lst-url-$1.txt
    eval "rbit=\${win${mbit}}"
    eval "url=\${URL_$(echo ${name} | tr a-z A-Z)}"
    rm -f ${lst}
    if [ "${name}" == "php" ]; then
        local domain=$(echo ${url} | sed 's@.*//\([^/]*\)/.*@\1@')
        local hash=$(echo ${url} | sha1sum | cut -c1-8)
        idx=${tmpdir}/${domain}-${hash}.htm.txt
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
    [ "${mbit}" == "32" ] && sed -i -E -e "/${win64}/d" ${lst}
    sort -u -o ${lst}.tmp ${lst}
    mv -f ${lst}.tmp ${lst}
}


init_list_release()
{
    local url m
    for m in ${modules} ${modules2}
    do
        case $m in
            apache|php|tomcat|java) init_url_deep $m;;
            *) init_url_flat $m;;
        esac
        eval "lst_$m=${tmpdir}/lst-url-$m.txt"
    done
}

init_version_xampp()
{
    local v_php=$1 v_mariadb=10.1 v_perl=5.16 v_tomcat=7.0 v_phpmyadmin=4.7
    local v_java=8 v_python v_sendmail v_xampp_control
    local m v name url
    dist=php${1/./}
    init_list_release
    for m in ${modules} ${modules2}

    do
        eval "lst=\${lst_$m}"
        eval "v=\$v_$m"
        name=$(get_names ${lst} | standard | sort_vr | sed -E -e "/${unstable}/d"| grep -E "^$v" | head -n1 | awk '{print $2}')
        eval "name_$m=\${name}"
        url=$(fgrep "${name}" ${lst} | head -n1)
        eval "url_$m=\${url}"
        rm -f ${lst}
    done
}

init_version_stable()
{
    local m v lst name text url
    dist=stable
    init_list_release
    for m in ${modules} ${modules2}
    do
        eval "lst=\${lst_$m}"
        text=$(get_names ${lst} | standard | sort_vr | sed -E -e "/${unstable}/d" | unique)
        name=$(echo "${text}" | head -n1)
        if [ "$m" = "mariadb" ]; then
            local v=$(echo ${name} | sed -E -e 's@.*-([0-9]+[.u][0-9]+[^-_]*(-(alpha|beta|rc)[0-9]*)?)[-_.].*@\1@g')
            download ../$v ${URL_MARIADB}
            if grep -E -q -i 'alpha|beta|rc|release candidate' ${download}; then
                name=$(echo "${text}" | head -n2 | tail -n1)
            fi
            [ -n "${debug}" ] || rm -f ${download}
        elif [ "$m" == "tomcat" ];then
            local v=$(echo ${name} | sed -E -e 's@.*-([0-9]+[.u][0-9]+[^-_]*(-(alpha|beta|rc)[0-9]*)?)[-_.].*@\1@g')
            download download-${v//.*}0.cgi ${URL_TOMCAT}
            if grep -E -q -i 'alpha|beta|release candidate' ${download}; then
                name=$(echo "${text}" | head -n2 | tail -n1)
            fi
            [ -n "${debug}" ] || rm -f ${download}
        fi
        eval "name_$m=\${name}"
        url=$(fgrep "${name}" ${lst} | head -n1)
        eval "url_$m=\${url}"
    done
}

init_version_unstable()
{
    local m lst name url
    dist=unstable
    init_list_release
    for m in ${modules} ${modules2}
    do
        eval "lst=\${lst_$m}"
        name=$(get_names ${lst} | standard | sort_vr | head -n1 | awk '{print $2}')
        eval "name_$m=\${name}"
        url=$(fgrep "${name}" ${lst} | head -n1)
        eval "url_$m=\${url}"
    done
}

init_version_manual()
{
    local m
    dist=manual
    init_list_release
    for m in ${modules} ${modules2}
    do
        init_version_menu $m
    done
}

init_version_menu()
{
    local m=$1 num name text lst
    eval lst="\${lst_$m}"
    text=$(get_names ${lst} | standard | sort_vr | unique)
    echo '--------------------------------------------'
    echo "${text}" | while read n
    do
        if echo ${name_tomcat} | grep -E -q '\-7.0|-8.0' ; then
            if echo $n | grep  -E -q 'jre-9'; then
                continue
            fi
        fi
        num=$(expr ${num:-0} + 1)
        printf "  %-4s%s\n" ${num}. $n
    done
    echo '--------------------------------------------'
    while read -p ':' num
    do
        case "${num}" in
            n|no|q|quit|e|exit) exit 1;;
            *);;
        esac
        num=$(echo ${num} | sed 's@[^0-9]@@g')
        [ -n "${num}" ] || continue
        [ ${num} -gt $(echo "${text}" | wc -l) ] && continue
        [ "${num}" = "0" ] && { eval name_$m='^$'; break; }
        name=$(echo "${text}" | head -n${num} | tail -n1)
        eval "name_$m=\${name}"
        url=$(fgrep "${name}" ${lst} | head -n1)
        eval "url_$m=\${url}"
        break
    done
}

install_print()
{
    local m num name url
    echo '--------------------------------------------'
    for m in apache fcgid xsendfile vc  ${modules} ${modules2}
    do
        eval "name=\${name_$m}"
        eval "url=\${url_$m}"
        if [ -n "${name}" ]; then
            echo -e "  $m:\n\t${name}\n\t${url}"
        else
            echo -e "  $m:\n\tnofound"
        fi
    done
    echo '--------------------------------------------'
    while read -p ':' num
    do
        num=$(echo ${num} | sed 's@[^a-z]@@gi' | tr A-Z a-z)
        case "${num}" in
            y|yes|o|ok) return ;;
            n|no|q|quit|exit) exit 1;;
            *) echo 'Invalid!';;
        esac
    done
}

install_download()
{
    local m name url base URL_FCGID=${URL_APACHE} URL_XSENDFILE=${URL_APACHE}
    local mariadb_ua=wget cookie ua
    for m in apache fcgid xsendfile ${modules} ${modules2}
    do
        eval "name=\${name_$m}"
        eval "url=\${url_$m}"
        eval "baseurl=\${URL_$(echo $m | tr a-z A-Z)}"
        [ -n "${url}" ] || { echo $m ; continue;}
        case $m in
            mariadb) USER_AGENT=wget;;
            *);;
        esac
        download ${url} ${baseurl}
    done
	name_busybox=busybox${mbit/32/_safe}.exe
    name_wget=wget-1.16.1-win${mbit}.zip
    name_curl=curl-7.55.1-60-g78b863d.zip
    download ${name_busybox} ${URL_BUSYBOX}
    download ${name_wget} ${URL_WGET}
    download curl_winssl_msys2_mingw${mbit}_stc/${name_curl%-*-*}/${name_curl} ${URL_CURL}

    if [ ! -f ${cachedir}/${name_vc} ]; then
        download ${url_vc}
        mv -f ${download} ${cachedir}/${name_vc}
    fi
}

install_unpack()
{
    local m
    [ -d ${distdir} ] && rm -rf ${distdir}
    mkdir -p ${distdir}/install/
    for m in apache fcgid xsendfile ${modules} ${modules2} vc wget curl
    do
        eval "name=\${name_$m}"
        if [ -z "${name}" ]; then
            echo "nofound: $m"
        elif unpack ${cachedir}/${name}; then
            case ${m} in
                apache)
                    mv ${unpack}/Apache24/ ${distdir}/apache
                    rm -rf ${distdir}/apache/cgi-bin ${distdir}/apache/htdocs
                    cp -af ${rootdir}/apache/* ${distdir}/apache/
                    cp -a ${rootdir}/cgi-bin ${rootdir}/htdocs ${rootdir}/webdav ${distdir}/
                    ;;
                fcgid) mv ${unpack}/mod_fcgid*/mod_fcgid.so ${distdir}/apache/modules/;;
                xsendfile) mv ${unpack}/mod_xsendfile.so ${distdir}/apache/modules/;;
                php)
                    mv ${unpack}/ ${distdir}/php
                    cp -af ${rootdir}/php/* ${distdir}/php/
                    cp -f  ${distdir}/php/libssh2.dll ${distdir}/php/icu*.dll ${distdir}/apache/bin/
                    ;;
                mariadb)
                    mv ${unpack}/mariadb-*/ ${distdir}/mysql
                    rm -rf ${distdir}/mysql/mysql-test ${distdir}/mysql/sql-bench
                    rm -f ${distdir}/mysql/data/ib*
                    find ${distdir}/mysql -name '*.pdb' -exec rm -f {} \;
                    cp -af ${rootdir}/mysql/* ${distdir}/mysql/
                    ;;
                phpmyadmin)
                    mv ${unpack}/phpMyAdmin-*/ ${distdir}/phpMyAdmin
                    cp -af ${rootdir}/phpMyAdmin/* ${distdir}/phpMyAdmin/
                    ;;
                perl) mv ${unpack}/perl/ ${distdir}/perl;;
                sendmail) mv ${unpack} ${distdir}/sendmail;;
                xampp_control) mv $unpack/*.exe ${distdir}/;;
                python)
                    mv ${unpack}/ ${distdir}/python
                    rm -f ${distdir}/python/*.msi
                    ;;
                java) mv ${unpack}/jre*/ ${distdir}/jre;;
                tomcat)
                    mv ${unpack}/apache-tomcat-*/ ${distdir}/tomcat
                    cp -af ${rootdir}/tomcat/* ${distdir}/tomcat/
                    ;;
                vc)
                    cp $unpack/*.dll ${distdir}/apache/bin/
                    cp $unpack/*.dll ${distdir}/php/
                    ;;
                wget)
                    mv -f ${unpack}/wget.exe ${distdir}/install/
                    ;;
                curl)
                    mv -f ${unpack}/src/curl.exe ${distdir}/install/
                    ;;
                *);;
            esac
            rm -rf ${unpack}
        fi
    done
    cp -f ${cachedir}/${name_busybox} ${distdir}/install/busybox.exe
}

install_final()
{
    mkdir -p ${distdir}/tmp
    cp -a ${rootdir}/install ${rootdir}/licenses ${rootdir}/locale ${distdir}/
    cp -a ${rootdir}/*.bat ${rootdir}/*.txt ${distdir}/
    cp -f ${rootdir}/src/xampp-usb-lite/setup_xampp.bat ${distdir}/
    cp -f ${rootdir}/src/xampp-usb-lite/xampp-control.ini ${distdir}/
    mv ${distdir}/htdocs/xampp/.modell-usb ${distdir}/htdocs/xampp/.modell
    if [ -f ${distdir}/perl/lib/Config.pm ]; then
        sed -i -e 's@C:/strawberry@/xampp@g' ${distdir}/perl/lib/CPAN/Config.pm
        sed -i -e 's@C:\\strawberry@\\xampp@g' ${distdir}/perl/bin/*.bat
        sed -i -e 's@C:\\strawberry@\\xampp@g' ${distdir}/perl/lib/Config_heavy.pl
        sed -i -e 's@C:\\strawberry@\\xampp@g' ${distdir}/perl/vendor/lib/ppm.xml
        sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' ${distdir}/perl/lib/CPAN/Config.pm
        sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' ${distdir}/perl/lib/CORE/config.h
        sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' ${distdir}/perl/lib/Config.pm
    fi
    if echo ${name_php} | grep -qE '\-5\.[0-9]'; then
        sed -i 's@php7@php5@g' ${distdir}/apache/conf/extra/httpd-xampp.conf
        sed -i 's@^extension=php_ftp.dll@;\0@' ${distdir}/php/php.ini
    fi
    if [ -d ${distdir}/tomcat ]; then
        local name=$(find ${distdir}/tomcat -name 'tomcat?.exe' | head -n 1)
        if [ -n "${name}" ]; then
            sed -iE 's@(Tomcat=)tomcat..exe@\1'${name##*/}'@' ${distdir}/xampp-control.ini
        fi
    fi
    if ! echo ${name_mariadb} | grep -qE '\-5.[0-9]|-10.0|-10.1' ; then
        sed -iE '/^innodb_additional_mem_pool_size/s@^.@#\0@' ${distdir}/mysql/bin/my.ini
    fi
    local version=$(echo  ${name_php} | sed -E 's@.*-(([0-9]+\.){2,}[^-]+)-.*@\1@')
    echo "${version}" > ${distdir}/htdocs/xampp/.version
    sed -iE "/<h2>/s@0.0.0@${version}@" ${distdir}/htdocs/dashboard/index.html
    sed -iE "/<h2>/s@0.0.0@${version}@" ${distdir}/htdocs/dashboard/*/index.html
    sed -iE "/xamppversion/s@0.0.0@${version}@" ${distdir}/install/.version
    sed -iE "/^######/s@0.0.0@${version}@" ${distdir}/readme_*.txt
}

install_main()
{
    menu_bit
    cachedir=${tmpdir}/cache/x${mbit}
    mkdir -p ${tmpdir} ${cachedir}
    menu_main
    distdir=${tmpdir}/xampp-${dist}-x${mbit}
    init_url_apache
    init_url_vc
    install_print
    install_download
    install_unpack
    install_final
}

main()
{
    if [ -n "$1" ];then
        local func=$1;shift
        ${func} "$@"
        return
    fi
	init_runtime
	install_main
}

URL_CURL='http://dl.uxnr.de/build/curl/'
URL_WGET='https://eternallybored.org/misc/wget/releases/old/'
URL_BUSYBOX='https://frippery.org/files/busybox/'

URL_APACHE='https://www.apachelounge.com/download/'
URL_MARIADB='https://downloads.mariadb.org/mariadb/+files/?os_group=windows&file_type=zip'
URL_PHP='http://windows.php.net/downloads/'
URL_PERL='http://strawberryperl.com/releases.html'
URL_PHPMYADMIN='https://www.phpmyadmin.net/files/'

URL_PYTHON='https://www.python.org/downloads/windows/'
URL_TOMCAT='https://tomcat.apache.org/'
URL_JAVA='http://www.oracle.com/technetwork/java/javase/downloads/index.html'

URL_VC11='https://www.microsoft.com/en-us/download/confirmation.aspx?id=30679'
URL_VC14='https://www.microsoft.com/en-us/download/confirmation.aspx?id=48145'
URL_VC15='https://aka.ms/vs/15/release/'
URL_VC16='https://aka.ms/vs/16/release/'

URL_SENDMAIL='https://github.com/xampp-phoenix/sendmail/releases'
URL_XAMPP_CONTROL='https://github.com/xampp-phoenix/xampp-control-panel/releases'

#modules='php mariadb phpmyadmin perl python java tomcat'
modules='php mariadb phpmyadmin perl'
modules2="sendmail xampp_control"
main "$@"
