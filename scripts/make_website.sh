#!/bin/bash -ex
# Must be called from a directory which the snowball module
# has been checked out into.
# Builds the website, placing all the generated files (such as
# tarballs and generated code files) in the appropriate places.

# Directory to place the built website into.
htmldir_local="/srv/www/snowball.tartarus.org/"
if [ x"$destdir" != x ]
then
  htmldir_local="$destdir"
fi

export PATH="$PATH:/usr/bin:/bin"

omindex="/u1/olly/install/bin/omindex"

mailcmd="/usr/lib/sendmail -oem -t -oi"

tmpdir="/tmp/snowball_mkwebsite$$"
trap "(rm -rf $tmpdir;echo \"make_website.sh failed\";
#trap "(echo \"make_website.sh failed\";
{
    echo \"From: richard@tartarus.org\";
    echo \"To: richard@tartarus.org\";
    echo \"Subject: Snowball - make_website.sh failed\";
    echo;
    echo \"Date: `date`\";
    echo;
    /usr/bin/env;
} | $mailcmd )" EXIT

rm -rf ${tmpdir}
mkdir -p ${tmpdir}
chmod go= ${tmpdir}
chmod g+s ${tmpdir}

cp -a snowball ${tmpdir}
cp -a website ${tmpdir}
find ${tmpdir} -name .svn | xargs rm -rf

cd ${tmpdir}/snowball
make all dist
cd -

cd snowball/algorithms
langs=`find * -type d -maxdepth 0 -not -name .svn`
cd -

# Get the compiled stemmer, for use by the demo.
cp ${tmpdir}/snowball/stemwords /home/snowball-svn/pub/compiled/

# Build the website, excluding the data files.
for lang in $langs
do
  cp -a ${tmpdir}/snowball/algorithms/${lang}/stem*.sbl ${tmpdir}/website/algorithms/${lang}/ || true
  for genfile in ${tmpdir}/snowball/src_c/stem_*_${lang}.[ch]
  do
    cp -a ${genfile} ${tmpdir}/website/algorithms/${lang}/`basename ${genfile/_${lang}/}` || true
  done

  # Copy one of the algorithms as stem.[ch], to preserve links.
  if [ -e ${tmpdir}/snowball/src_c/stem_ISO_8859_1_${lang}.c ]
  then
    ln -s stem_ISO_8859_1.c ${tmpdir}/website/algorithms/${lang}/stem.c
    ln -s stem_ISO_8859_1.h ${tmpdir}/website/algorithms/${lang}/stem.h
  else
    if [ -e ${tmpdir}/snowball/src_c/stem_KOI8_R_${lang}.c ]
    then
      ln -s stem_KOI8_R.c         ${tmpdir}/website/algorithms/${lang}/stem.c
      ln -s stem_KOI8_R.h         ${tmpdir}/website/algorithms/${lang}/stem.h
    else
      if [ -e ${tmpdir}/snowball/src_c/stem_UTF_8_${lang}.c ]
      then
        ln -s stem_UTF_8.c         ${tmpdir}/website/algorithms/${lang}/stem.c
        ln -s stem_UTF_8.h         ${tmpdir}/website/algorithms/${lang}/stem.h
      fi
    fi
  fi
done

# Build a tarball of the whole website, together with the code,
# but excluding the data.
cd ${tmpdir}
mv website snowball_web_and_code
tar zcf snowball_web_and_code.tgz snowball_web_and_code
mv snowball_web_and_code website
cd -

# Add the data files to the website
cd data
datalangs=`find * -type d -maxdepth 0 -not -name .svn`
for lang in $datalangs
do
  cp -a ${lang}/*.txt ${tmpdir}/website/algorithms/${lang}/
done
cd -

# Build a tarball of the whole website, together with the code and data.
cd ${tmpdir}
mv website snowball_all
tar zcf snowball_all.tgz snowball_all
mv snowball_all website
cd -

# Build tarballs of the files for each individual stemmer.
for lang in $datalangs
do
  cd ${tmpdir}/website/algorithms/
  # kraaij_pohlmann voc.txt and output.txt don't exist.
  if [ -e ${lang}/voc.txt ]
  then
    tar zcf ${lang}/tarball.tgz \
      ${lang}/stem*.sbl \
      ${lang}/stem*.c \
      ${lang}/stem*.h \
      ${lang}/voc.txt \
      ${lang}/output.txt \
      ${lang}/stemmer.html
  fi
  cd -
done

mkdir -p ${tmpdir}/website/dist
mv ${tmpdir}/snowball_all.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball_web_and_code.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball/dist/snowball_code.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball/dist/libstemmer_c.tgz ${tmpdir}/website/dist/
mv ${tmpdir}/snowball/dist/libstemmer_java.tgz ${tmpdir}/website/dist/

# Update mail archives
cd ~/archives
mkdir -p archives
#HM_LINKQUOTES=1 HM_REVERSE=1 HM_MONTHLY_INDEX=1 /home/richard/pub/builds/hypermail -m /usr/data/mailman/archives/private/snowball-discuss.mbox/snowball-discuss.mbox -d archives/snowball-discuss -l "Snowball Discuss"
#HM_LINKQUOTES=1 HM_REVERSE=1 HM_MONTHLY_INDEX=1 /home/richard/pub/builds/hypermail -m /usr/data/mailman/archives/private/snowball-commits.mbox/snowball-commits.mbox -d archives/snowball-commits -l "Snowball Commits"
cp -r archives/* ${tmpdir}/website/archives
cd -

cp -a /home/snowball-svn/pub/compiled/omega.cgi ${tmpdir}/website/omega.cgi

rsync -q -a -r --delete --delete-after ${tmpdir}/website/ ${htmldir_local}

# Stop here - don't update search indexes now.
trap EXIT
rm -rf ${tmpdir}
exit 0

# Update search indices
dbprefix="/home/richard/pub/omega/data/snowball-";

# We build into a new database, and then remove the old one and move the new
# one into place.  It would be better to use a symlink, but I can't be
# bothered to deal with timestamped directories, and cleaning up carefully, etc.

db="discuss";
mkdir -p ${dbprefix}${db}-new;
${omindex} --db ${dbprefix}${db}-new \
        --url http://www.snowball.tartarus.org/archives/snowball-${db}/ \
        --mime-type txt:x-unhandled \
        ${htmldir_local}/archives/snowball-${db}/
mv "${dbprefix}${db}" "${dbprefix}${db}-old" || /bin/true;
mv "${dbprefix}${db}-new" "${dbprefix}${db}";
rm -rf "${dbprefix}${db}-old";

db="commits";
mkdir -p ${dbprefix}${db}-new;
${omindex} --db ${dbprefix}${db}-new \
        --url http://www.snowball.tartarus.org/archives/snowball-${db}/ \
        --mime-type txt:x-unhandled \
        ${htmldir_local}/archives/snowball-${db}/
mv "${dbprefix}${db}" "${dbprefix}${db}-old" || /bin/true;
mv "${dbprefix}${db}-new" "${dbprefix}${db}";
rm -rf "${dbprefix}${db}-old";

db="website";
mkdir -p ${dbprefix}${db}-new;
${omindex} --db ${dbprefix}${db}-new \
        --url http://snowball.tartarus.org/ \
        --mime-type txt:x-unhandled \
        /srv/www/snowball.tartarus.org/
mv "${dbprefix}${db}" "${dbprefix}${db}-old" || /bin/true;
mv "${dbprefix}${db}-new" "${dbprefix}${db}";
rm -rf "${dbprefix}${db}-old";

trap EXIT
rm -rf ${tmpdir}
