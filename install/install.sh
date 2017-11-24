#!/bin/sh
URL_BUSYBOX=https://frippery.org/files/busybox/
URL_APACHE=https://www.apachelounge.com/download/
#URL_MARIADB=https://downloads.mariadb.org/mariadb/+releases/
URL_MARIADB='https://downloads.mariadb.org/mariadb/+files/?os_group=windows&file_type=zip'
URL_PHP=http://windows.php.net/download/
URL_PERL=http://strawberryperl.com/releases.html
URL_TOMCAT=https://tomcat.apache.org/download-70.cgi
URL_PHPMYADMIN=https://www.phpmyadmin.net/files/
URL_PYTHON=https://www.python.org/downloads/windows/
URL_JAVA=http://www.oracle.com/technetwork/java/javase/downloads/index.html
URL_XAMPP=https://github.com/xampp-phoenix/xampp-control-panel/releases

URL_CURL=http://dl.uxnr.de/build/curl/

curdir=$PWD
installdir=`dirname $0`
installdir=`cd $installdir;pwd`
rootdir=`cd $installdir/..;pwd`
tmpdir=$rootdir/tmp
distdir=$tmpdir/xampp

php=$rootdir/php/php.exe
curl=$installdir/curl.exe

uname=`uname -m`
x32='x86\|win32\|32bit\|i586\|i686'
x64='x64\|win64\|64bit\|amd64\|x86_64'

init_xampp=3.2.2.0

x3264=$x32
[ "$uname" == "x86_64" ] && x3264=$x64 

mkdir -p $tmpdir

getcurl()
{
    local name=curl-7.55.1-60-g78b863d.zip
    [ -f $curl ] && return 
    if [ "$uname" == 'x86_64' ];then
        wget -O $tmpdir/$name $URL_CURL/curl_winssl_msys2_mingw64_stc/${name%-*-*}/$name
    else
        wget -O $tmpdir/$name $URL_CURL/curl_winssl_msys2_mingw32_stc/${name%-*-*}/$name
    fi
    unzip -d $installdir -j $tmpdir/$name curl.exe
    rm -f $tmpdir/$name
}

curl()
{
    echo get $1 >&2
    [ -f "$2" ] && return
    local u='Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)' 
    local c='_ga=GA1.3.529311640.1508686048; _gid=GA1.3.1125738004.1511274547'
    [ -n "$cookie" ] && c="$c; $cookie"
    [ -n "$useragent" ] && u=$useragent
    $curl --retry 3 --user-agent "$u" --cookie "$c" --referer ${1%\/*} --location $1 --output $2.tmp -#
    [ $? == 0 ] && mv $2.tmp $2
}


urljoin()
{
    if [ -z "${2/http:*}" -o -z "${2/https:*}" ];then
        echo $2
        return
    fi
    if [ -n "$2" -a -z ${2/\/*} ];then
        echo `echo $1 | sed 's@\(.*://[^/]*\)/.*@\1@'`$2
    else
        echo "${1%/*}/$2"
    fi
}

getlist()
{
    [ -z $1 ] && return
    rm -f $tmpdir/index.tmp
    curl $1 $tmpdir/index.tmp
    local list=`cat $tmpdir/index.tmp | grep -i 'href=\|filepath' | sed -e 's@.*\(href=\|filepath":\)"\([^"]*\)".*@\2@g' -e 's@\.zip/from/.*$@.zip@'`
    list=`echo "$list" | grep -i -v '[-]src\|-debug\|-nts\|-latest'`
    list=`echo "$list" | grep -i '\(.gz\|.zip\|.msi\|jre[0-9]-downloads-[0-9]*.html\)$'`
    rm -f $tmpdir/index.tmp
    echo "$list" | uniq
}

menu_install()
{
    local num
    echo '--------------------------------------------'
    echo ' 1. Compatible with XAMPP 7.1.x'
    echo ' 2. Compatible with XAMPP 7.0.x'
    echo ' 3. Compatible with XAMPP 5.6.x'
    echo ' 4. All newest stable releases'
    echo ' 5. All newest unstable releases'
    echo
    echo ' 9. I choose the version myself'
    echo
    echo ' 0. Exit the installation wizard'
    echo '--------------------------------------------'
    while read -p 'Which one to install:' num
    do
        case $num in
            1) init_xampp71;break;;
            2) init_xampp70;break;;
            3) init_xampp56;break;;
            4) init_stable;break;;
            5) init_unstable;break;;
            9) init_manually;break;;
            0) echo 'exit...';exit 0;;
            *) echo 'Invalid!';;
        esac
    done
}
init_xampp71()
{
    init_apache=VC14
    init_php=7.1
    init_mariadb=10.1
    init_perl=5.16
    init_tomcat=7.0
    init_phpmyadmin=4.7
    init_java=8
    init_python=2.7
}
init_xampp70()
{
    init_apache=VC14
    init_php=7.0
    init_mariadb=10.1
    init_perl=5.16
    init_tomcat=7.0
    init_phpmyadmin=4.7
    init_java=8
    init_python=2.7
}
init_xampp56()
{
    init_apache=VC14
    init_php=5.6
    init_mariadb=10.1
    init_perl=5.16
    init_tomcat=7.0
    init_phpmyadmin=4.7
    init_java=8
    init_python=2.7
}
init_stable()
{
    init_apache=VC14
    init_php=7.1
    init_mariadb=10.2
    init_perl=5.26
    init_tomcat=8.5
    init_phpmyadmin=4.7
    init_java=8
    init_python=3.6
}
init_unstable()
{
    init_apache=VC15
    init_php=7.2
    init_mariadb=10.3
    init_perl=5.26
    init_tomcat=9.0
    init_phpmyadmin=4.8
    init_java=9
    init_python=3.7
}
init_manually()
{
    :
}
get_install()
{
    file_apache=`getlist $URL_APACHE$init_apache/ | grep -i $x3264 | grep httpd | head -n1`
    [ "$init_php" == "7.2" ] && URL_PHP=${URL_PHP/download/qa}
    file_php=`getlist $URL_PHP | grep -i $x3264  | grep $init_php | head -n1`
    file_mariadb=`getlist $URL_MARIADB | grep -i $x3264 | grep $init_mariadb | tail -n1`
    file_perl=`getlist $URL_PERL | grep -i $x3264  | grep $init_perl | grep portable | head -n1`
    file_tomcat=`getlist ${URL_TOMCAT/70/${init_tomcat/.*}0} | grep -i $x3264  | grep $init_tomcat | head -n1`
    file_phpmyadmin=`getlist $URL_PHPMYADMIN | grep -i '[-]all-'  | grep $init_phpmyadmin | head -n1`
    if [ "$uname" == "x86_64" ]; then
        file_python=`getlist $URL_PYTHON | grep -i $x3264 | grep $init_python | head -n1`
    else
        file_python=`getlist $URL_PYTHON | grep -i -v $x64 | grep $init_python | head -n1`
    fi
    file_java=`getlist $URL_JAVA | grep "/jre$init_java" | head -n1`
    file_java=`urljoin $URL_JAVA $file_java`
    file_java=`getlist $file_java | grep -i $x3264 | tail -n1`
    file_xampp=`getlist $URL_XAMPP | grep -i $x3264  | grep $init_xampp | head -n1`

    file_apache=`urljoin $URL_APACHE $file_apache`
    file_mariadb=`urljoin $URL_MARIADB $file_mariadb`
    file_php=`urljoin $URL_PHP $file_php`
    file_perl=`urljoin $URL_PERL $file_perl`
    file_tomcat=`urljoin $URL_TOMCAT $file_tomcat`
    file_phpmyadmin=`urljoin $URL_PHPMYADMIN $file_phpmyadmin`
    file_python=`urljoin $URL_PYTHON $file_python`
    file_java=`urljoin $URL_JAVA $file_java`
    file_xampp=`urljoin $URL_XAMPP $file_xampp`
    echo '--------------------------------------------'
    echo ${file_apache/*\/}
    echo ${file_mariadb/*\/}
    echo ${file_php/*\/}
    echo ${file_perl/*\/}
    echo ${file_tomcat/*\/}
    echo ${file_phpmyadmin/*\/}
    echo ${file_python/*\/}
    echo ${file_java/*\/}
    echo ${file_xampp/*\/}
    echo '--------------------------------------------'
    while read -p 'These files to download?(y/n):' num
    do
        case $num in
            y|Y) break;;
            n|N) exit 1;;
            *) echo 'Invalid!';;
        esac

    done
    curl $file_apache     $tmpdir/${file_apache/*\/}
    useragent=curl
    curl $file_mariadb    $tmpdir/${file_mariadb/*\/}
    curl $file_php        $tmpdir/${file_php/*\/}
    curl $file_perl       $tmpdir/${file_perl/*\/}
    curl $file_tomcat     $tmpdir/${file_tomcat/*\/}
    curl $file_phpmyadmin $tmpdir/${file_phpmyadmin/*\/}
    curl $file_python     $tmpdir/${file_python/*\/}
    cookie='gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie'
    curl $file_java       $tmpdir/${file_java/*\/}
    curl $file_xampp       $tmpdir/${file_xampp/*\/}
}

unpack()
{
    local n=$1 p=${1%.*}
    p=${p#.tar}
    echo $n
    rm -rf $tmpdir/$p
    mkdir -p $tmpdir/$p
    case ${n##*.} in
        zip) unzip -q $tmpdir/$n -d $tmpdir/$p;;
        gz)  tar xf $tmpdir/$n -C $tmpdir/$p;;
        msi) msiexec -a ${tmpdir//\//\\}\\$n -qn TARGETDIR=${tmpdir//\//\\}\\$p;;
        *);;
    esac
    unpack=$tmpdir/$p
}
do_install()
{
    rm -rf $distdir
    mkdir $distdir

    unpack ${file_apache/*\/}
    mv $unpack/Apache24/ $distdir/apache 
    rm -rf $distdir/apache/cgi-bin $distdir/apache/htdocs
    cp -af $rootdir/apache/* $distdir/apache/ 
    rm -rf $unpack

    unpack ${file_mariadb/*\/}
    mv $unpack/mariadb-*/ $distdir/mysql
    rm -rf $distdir/mysql/mysql-test $distdir/mysql/sql-bench
    find $distdir/mysql -name '*.pdb' -delete
    cp -af $rootdir/mysql/* $distdir/mysql/ 
    rm -f $distdir/mysql/data/ib*
    rm -rf $unpack
    
    unpack ${file_php/*\/}
    mv $unpack/ $distdir/php
    cp -af $rootdir/php/* $distdir/php/ 
    cp -f  $distdir/php/libssh2.dll $distdir/php/icu*.dll $distdir/apache/bin/ 
    rm -rf $unpack
    
    unpack ${file_perl/*\/}
    mv $unpack/perl/ $distdir/perl
    #cp -af $rootdir/perl/* $distdir/perl/ 
    rm -rf $unpack
    
    unpack ${file_tomcat/*\/}
    mv $unpack/apache-tomcat-*/ $distdir/tomcat
    cp -af $rootdir/tomcat/* $distdir/tomcat/ 
    rm -rf $unpack
    
    unpack ${file_phpmyadmin/*\/}
    mv $unpack/phpMyAdmin-*/ $distdir/phpMyAdmin
    cp -af $rootdir/phpMyAdmin/* $distdir/phpMyAdmin/ 
    rm -rf $unpack
    
    unpack ${file_python/*\/}
    mv $unpack/ $distdir/python
    rm -f $distdir/python/*.msi
    rm -rf $unpack
    
    unpack ${file_java/*\/}
    mv $unpack/jre*/ $distdir/jre
    rm -rf $unpack

    unpack ${file_xampp/*\/}
    mv $unpack/*.exe/ $distdir/
    rm -rf $unpack

    cp -a $rootdir/cgi-bin $rootdir/htdocs $rootdir/install $rootdir/licenses $rootdir/webdav $rootdir/locale $distdir/
    cp -a $rootdir/*.bat $rootdir/*.txt $distdir/
    cp -f $rootdir/src/xampp-usb-lite/setup_xampp.bat $distdir/
    cp -f $rootdir/src/xampp-usb-lite/xampp-control.ini $distdir/
    mv $distdir/htdocs/xampp/.modell-usb $distdir/htdocs/xampp/.modell
    mkdir -p $distdir/tmp
    sed -i -e 's@C:/strawberry@/xampp@g' $distdir/perl/lib/CPAN/Config.pm 
    sed -i -e 's@C:\\strawberry@\\xampp@g' $distdir/perl/bin/*.bat 
    sed -i -e 's@C:\\strawberry@\\xampp@g' $distdir/perl/lib/Config_heavy.pl
    sed -i -e 's@C:\\strawberry@\\xampp@g' $distdir/perl/vendor/lib/ppm.xml
    sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' $distdir/perl/lib/CPAN/Config.pm
    sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' $distdir/perl/lib/CORE/config.h
    sed -i -e 's@C:\\\\strawberry@\\\\xampp@g' $distdir/perl/lib/Config.pm
}


getcurl
menu_install
get_install
do_install
