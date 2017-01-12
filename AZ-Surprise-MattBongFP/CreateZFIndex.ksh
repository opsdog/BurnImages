#!/bin/ksh
#!/usr/local/bin/ksh
##
##  script to read the Section?? files and create web galleries based
##  on their contents
##
##  first line is the section title
##  following lines are the image filename and the caption
##

##
##  set stuff up
##

TODAY=`date +"%B %d, %Y"`

SitePrefix=http://www.daemony.com
StylePrefix=${SitePrefix}/Styles
MyEMail=doug.greenwald@gmail.com

URLPrefix=http://photos.daemony.com/
ZFURLPrefix="http://opsdog.zenfolio.com/p"
ZRURLSuffix=''

PATH="${PATH}:/usr/GNU/bin:/Volumes/External300/DBProgs/RacePics"

##
##  get the page info
##

exec 4<Info
read -u4 PageTitle
read -u4 PageDesc
read -u4 PageKeywords
exec 4<&-

#echo $PageTitle
#echo $PageDesc
#echo $PageKeywords


##
##  create the header of the index.html file
##

cat > index.html <<EOF
<html>
<head>
<title>$PageTitle</title>

<link rel=stylesheet href="CD.css" type="text/css">

<meta name="description" content="$PageDesc" />
<meta name="keywords" content="$PageKeywords" />
<meta name="revision" content="${TODAY}" />

</head>
<body>

<p>Jump to a specific section or just scroll through them all...</p>

<ul>

EOF

##
##  create the section links
##

for SectionFile in Section??
do

  SectionName=`head -1 ${SectionFile}`

  echo "<li><a href=\"#${SectionFile}\">${SectionName}</a>" >> index.html

done  # for SectionFile

cat >> index.html <<EOF

</ul>

EOF

##
##  main loop driven by the section files
##

for SectionFile in Section??
do

  echo $SectionFile

  #  open the section file and read the title

  exec 4<$SectionFile
  read -u4 SectionTitle
  echo "  $SectionTitle"

  IMAGECOUNT=0

  cat >> index.html <<EOF
<br clear="all">
<a name="$SectionFile"></a>
<h1 align="center">$SectionTitle</h1>
<!-- <br clear="all"> -->
<p align="center" class="caption">Click on an image to see purchase options.</p>
<br clear="all">
<table cellpadding=3 cellspacing=5 border=2>
EOF

  #  read each image and its caption

  while read -u4 ImageFile ImageCaption
  do
    echo "    $ImageFile - $ImageCaption"

    BaseName=`echo $ImageFile | awk -F \. '{ print $1 }'`

    if [ "$ImageCaption" = "&nbsp;" ]
    then
      DBCap=`NewQuery racepics "select caption from commerce where id = '$BaseName'`
      ##  if [ ! -z "$DBCap" ]
      if [ "$DBCap" != "NULL" ]
      then
	echo "      caption override:  $DBCap"
	ImageCaption=$DBCap
      fi
    fi

    ##
    ##  find the zenfolio info
    ##

    ZFInfo=`CSVQuery racepics "select zfgal, zfid from commerce where id = '${BaseName}'"`
    ZFGal=`echo $ZFInfo | awk -F \, '{ print $1 }'`
    ZFID=`echo $ZFInfo | awk -F \, '{ print $2 }'`

    #
    #  determine image resolutions
    #

    TWidth=`cat _Thumb/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f5 | cut -d= -f2 | cut -d, -f1`
    THeight=`cat _Thumb/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f6 | cut -d= -f2 | cut -d, -f1`
  
#    Width=`cat _Screen/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f5 | cut -d= -f2 | cut -d, -f1`
#    Height=`cat _Screen/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f6 | cut -d= -f2 | cut -d, -f1`

    echo "      ${TWidth}x${THeight}"
#    echo "      ${Width}x${Height}"

  #
  #  add entry to index.html
  #

  if [ "$IMAGECOUNT" = "2" ]
  then
    echo "<td width=20>&nbsp;</td>" >> index.html
    echo "<td align=\"center\" valign=top>" >> index.html

    if [ ! -z "${ZFInfo}" ]
    then
      ##  image uploaded into zenfolio
      echo "      $ZFInfo"
      echo "<a href=\"${ZFURLPrefix}${ZFGal}/?photo=${ZFID}\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index.html
    else
      ##  image not in zenfolio
      echo "      No ZFInfo"
      echo "<img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\">" >> index.html
    fi

    echo "<br clear=\"all\">" >> index.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index.html
    echo "</td>" >> index.html
    echo "</tr>" >> index.html
    echo "<tr><td width=20>&nbsp;</td><td>&nbsp;</td></tr>" >> index.html
    IMAGECOUNT=3
  fi

  if [ "$IMAGECOUNT" = "1" ]
  then
    echo "<td width=20>&nbsp;</td>" >> index.html
    echo "<td align=\"center\" valign=top>" >> index.html

    if [ ! -z "${ZFInfo}" ]
    then
      ##  image uploaded into zenfolio
      echo "      $ZFInfo"
      echo "<a href=\"${ZFURLPrefix}${ZFGal}/?photo=${ZFID}\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index.html
    else
      ##  image not in zenfolio
      echo "      No ZFInfo"
      echo "<img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\">" >> index.html
    fi

    echo "<br clear=\"all\">" >> index.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index.html
    echo "</td>" >> index.html
    IMAGECOUNT=2
  fi

  if [ "$IMAGECOUNT" = "0" ]
  then
    echo "<tr>" >> index.html
    echo "<td width=10>&nbsp;</td>" >> index.html
    echo "<td align=\"center\" valign=top>" >> index.html

    if [ ! -z "${ZFInfo}" ]
    then
      ##  image uploaded into zenfolio
      echo "      $ZFInfo"
      echo "<a href=\"${ZFURLPrefix}${ZFGal}/?photo=${ZFID}\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index.html
    else
      ##  image not in zenfolio
      echo "      No ZFInfo"
      echo "<img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\">" >> index.html
    fi

    echo "<br clear=\"all\">" >> index.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index.html
    echo "</td>" >> index.html
    IMAGECOUNT=1
  fi

  if [ "$IMAGECOUNT" = 3 ]
  then
    IMAGECOUNT=0
  fi

  done  ##  while reading SectionFile

  #  close the SectionFile

  exec 4<&-

#
#  figure out if the image table has been completed
#

if [ "$IMAGECOUNT" = 2 ]
then
  echo "<td width=20>&nbsp;</td>" >> index.html
  echo "<td>&nbsp;</td>" >> index.html
  echo "</tr>" >> index.html
fi

if [ "$IMAGECOUNT" = 1 ]
then
  echo "<td width=20>&nbsp;</td>" >> index.html
  echo "<td>&nbsp;</td>" >> index.html
  echo "<td width=20>&nbsp;</td>" >> index.html
  echo "<td>&nbsp;</td>" >> index.html
  echo "</tr>" >> index.html
fi

#if [ "$IMAGECOUNT" = 0 ]
#then
#  echo "</tr>" >> index.html
#fi

cat >> index.html <<EOF

</table>

<!--  end of image table -->

<!-- ****************************************************************** -->

<br clear=all><br>

EOF

done  ##  for SectionFile



##
##  finish the index.html file
##

cat >> index.html <<EOF
<div align="center">
<p class="caption">All content Copyright 1994-2012 <a href="mailto:doug.greenwald@gmail.com">Douglas A. Greenwald</a>, all rights reserved</p>
</div>

<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("UA-5380021-1");
pageTracker._trackPageview();
</script>
</body>
</html>
EOF

##
##  copy the index file to StartHere
##

cp -p index.html StartHere.html
