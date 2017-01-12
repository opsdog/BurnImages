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

PATH="${PATH}:/usr/GNU/bin:/Volumes/External300/DBProgs/RacePics:/Users/douggreenwald/bin"

##
##  do we create links to full sized images?
##

if [ "$1" = "-f" ]
then
  DoFullSize=1
else
  unset DoFullSize
fi

#if [ $DoFullSize ]
#then
#  echo "true"
#else
#  echo "false"
#fi

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
##  create the header of the index-f.html file
##

cat > index-f.html <<EOF
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

for SectionFile in Flowers??
do

  SectionName=`head -1 ${SectionFile}`

  echo "<li><a href=\"#${SectionFile}\">${SectionName}</a>" >> index-f.html

done  # for SectionFile

cat >> index-f.html <<EOF

</ul>

EOF

##
##  main loop driven by the section files
##

for SectionFile in Flowers??
do

  echo $SectionFile

  #  open the section file and read the title

  exec 4<$SectionFile
  read -u4 SectionTitle
  echo "  $SectionTitle"

  IMAGECOUNT=0

  cat >> index-f.html <<EOF
<a name="$SectionFile"></a>
<h1 align="center">$SectionTitle</h1>
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
      # if [ ! -z "$DBCap" ]
      if [ ! -z "$DBCap"  -a  "$DBCap" != "NULL" ]
      then
	echo "      caption override:  $DBCap"
	ImageCaption=$DBCap
      fi
    fi

    #
    #  determine image resolutions
    #

    TWidth=`cat _Thumb/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f5 | cut -d= -f2 | cut -d, -f1`
    THeight=`cat _Thumb/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f6 | cut -d= -f2 | cut -d, -f1`
  
    Width=`cat _Screen/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f5 | cut -d= -f2 | cut -d, -f1`
    Height=`cat _Screen/${ImageFile} | djpeg -outfile /dev/null -verbose 2>&1 | grep width | cut -d\  -f6 | cut -d= -f2 | cut -d, -f1`

    echo "      ${TWidth}x${THeight}"
    echo "      ${Width}x${Height}"

    cat > _Screen/${ImageFile}.html << EOF
<html>

<head>

<title>$PageTitle - ${SectionTitle} - ${ImageFile}</title>

<link rel=stylesheet href="../CD.css" type="text/css">

<meta name="description" content="$PageDesc" />
<meta name="keywords" content="$PageKeywords" />
<meta name="revision" content="${TODAY}" />

</head>

<body>

<!-- ****************************************************************** -->

<table cellspacing=5 cellpadding=3 border=0>

<tr>  
<td width=5>&nbsp;</td>
<td valign=top><h1 align=center>${ImageFile}</h1>
EOF
    if [ $DoFullSize ]
    then
      echo "<p>Click the image to see it full-sized...</p>" >> _Screen/${ImageFile}.html
    fi
    cat >> _Screen/${ImageFile}.html << EOF
</td>
</tr>

<tr><td width=5>&nbsp;</td><td>&nbsp;</td></tr>

<tr>
<td width=5>&nbsp;</td>
<td align=center valign=top>  <!-- ***** Image goes here ***** -->
EOF
    if [ $DoFullSize ]
    then
      echo "<a href="../_FullSize/${ImageFile}"><img src="${ImageFile}" width="${Width}" height="${Height}"></a>" >> _Screen/${ImageFile}.html
    else
      echo "<img src="${ImageFile}" width="${Width}" height="${Height}">" >> _Screen/${ImageFile}.html
    fi
    cat >> _Screen/${ImageFile}.html << EOF
<br>
${ImageCaption}
EOF

    ##
    ##  find the zenfolio info - insert a link if it's loaded
    ##

    ZFInfo=`CSVQuery racepics "select zfgal, zfid from commerce where id = '${BaseName}'"`
    ZFGal=`echo $ZFInfo | awk -F \, '{ print $1 }'`
    ZFid=`echo $ZFInfo | awk -F \, '{ print $2 }'`

    if [ ! -z "${ZFInfo}" ]
    then
      #  image uploaded into zenfolio
      echo "      $ZFInfo"
      cat >> _Screen/${ImageFile}.html << EOF
<p align=center class="Caption"><a href="${ZFURLPrefix}${ZFGal}/?photo=${ZFid}">Click Here</a> if you would like to purchase this image as a large print, poster, puzzle, or mousepad.</p>
EOF
    fi

    cat >> _Screen/${ImageFile}.html << EOF
</td>
</tr>

<!-- ****************************************************************** -->

<!--  Image specific page bottom nav table -->

<tr><td width=5>&nbsp;</td><td>&nbsp;</td></tr>
<!-- 
<tr>
<td width=5>&nbsp;</td>
<td align=center valign=top>
  <table cellpadding=3 cellspacing=5 border=0>
  <tr>
  <td align=center valign=top><a href="../index.htm">Back</a></td>
  <td align=center valign=top><a href="../../">Photo Collections</a></td>
  </tr>
  </table>
</td>
</tr>
-->
<tr>
<td width=5>&nbsp;</td>
<td><center><p class="caption">All content Copyright <a href="mailto:doug.greenwald@gmail.com">Douglas A. Greenwald</a>, all rights reserved</p></center></td>
</tr>

</table>

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

  #
  #  add entry to index-f.html
  #

  if [ "$IMAGECOUNT" = "2" ]
  then
    echo "<td width=20>&nbsp;</td>" >> index-f.html
    echo "<td align=center valign=top><a href=\"_Screen/${ImageFile}.html\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index-f.html
    echo "<br clear=\"all\">" >> index-f.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index-f.html
    echo "</td>" >> index-f.html
    echo "</tr>" >> index-f.html
    echo "<tr><td width=20>&nbsp;</td><td>&nbsp;</td></tr>" >> index-f.html
    IMAGECOUNT=3
  fi

  if [ "$IMAGECOUNT" = "1" ]
  then
    echo "<td width=20>&nbsp;</td>" >> index-f.html
    echo "<td align=center valign=top><a href=\"_Screen/${ImageFile}.html\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index-f.html
    echo "<br clear=\"all\">" >> index-f.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index-f.html
    echo "</td>" >> index-f.html
    IMAGECOUNT=2
  fi

  if [ "$IMAGECOUNT" = "0" ]
  then
    echo "<tr>" >> index-f.html
    echo "<td width=10>&nbsp;</td>" >> index-f.html
    echo "<td align=center valign=top><a href=\"_Screen/${ImageFile}.html\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index-f.html
    echo "<br clear=\"all\">" >> index-f.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index-f.html
    echo "</td>" >> index-f.html
    IMAGECOUNT=1
  fi

  if [ "$IMAGECOUNT" = 3 ]
  then
    IMAGECOUNT=0
  fi

  #
  #  make image specific .html executable
  #

  chmod 0644 _Screen/${ImageFile}.html


  done  ##  while reading SectionFile

  #  close the SectionFile

  exec 4<&-

#
#  figure out if the image table has been completed
#

if [ "$IMAGECOUNT" = 2 ]
then
  echo "<td width=20>&nbsp;</td>" >> index-f.html
  echo "<td>&nbsp;</td>" >> index-f.html
  echo "</tr>" >> index-f.html
fi

if [ "$IMAGECOUNT" = 1 ]
then
  echo "<td width=20>&nbsp;</td>" >> index-f.html
  echo "<td>&nbsp;</td>" >> index-f.html
  echo "<td width=20>&nbsp;</td>" >> index-f.html
  echo "<td>&nbsp;</td>" >> index-f.html
  echo "</tr>" >> index-f.html
fi

#if [ "$IMAGECOUNT" = 0 ]
#then
#  echo "</tr>" >> index-f.html
#fi

cat >> index-f.html <<EOF

</table>

<!--  end of image table -->

<!-- ****************************************************************** -->

<br clear=all><br>

EOF

done  ##  for SectionFile



##
##  finish the index-f.html file
##

cat >> index-f.html <<EOF

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

#cp -p index-f.html StartHere.html
