#!/bin/sh -e
# Get the snowball source and documentation from SVN and call the
# script which makes the website.

mailcmd="/usr/lib/sendmail -oem -t -oi"

tmpdir="/tmp/snowball_bootstrap$$"
logfile="${tmpdir}/stdout_log"
errlogfile="${tmpdir}/stderr_log"

export PATH="$PATH:/usr/bin:/bin"

trap "(echo \"bootstrap.sh failed\";
{
    echo \"From: richard@tartarus.org\";
    echo \"To: richard@tartarus.org\";
    echo \"Subject: Snowball - bootstrap.sh failed\";
    echo;
    echo -n \"Date: \"; date;
    echo;
    /usr/bin/env;
    echo;
    echo "===STDERR===";
    cat $errlogfile;
    echo;
    echo "===STDOUT===";
    cat $logfile;
} | $mailcmd; rm -rf $tmpdir)" EXIT
#} | $mailcmd;)" EXIT

svnbase="svn://snowball.tartarus.org/snowball/trunk/"

rm -rf ${tmpdir}
mkdir -p ${tmpdir}
chmod go= ${tmpdir}
chmod g+s ${tmpdir}

cd ${tmpdir}
svn export ${svnbase} >$logfile 2>$errlogfile
cd trunk

/home/snowball-svn/snowball/hooks/make_website.sh >>$logfile 2>>$errlogfile

trap EXIT
rm -rf ${tmpdir}
