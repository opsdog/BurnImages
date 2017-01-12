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

PATH="${PATH}:/Volumes/External300/GNU-old/bin:/Volumes/External300/DBProgs/RacePics"

##
##  create the header of the index.html file
##

cat > index.html <<EOF
<html>
<head>
<title>Pilgrim Lutheran Church</title>

<link rel=stylesheet href="CD.css" type="text/css">

<meta name="description" content="Images of the Pilgrim Lutheran Church in Columbia, SC.  Photography by and Copyright Doug Greenwald, all rights reserved." />
<meta name="keywords" content="doug, greenwald, photography, pilgrim, lutheran, church, columbia, sc, south, carolina" />
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

<title>Pilgrim Lutheran Church - ${SectionTitle} - ${ImageFile}</title>

<link rel=stylesheet href="../CD.css" type="text/css">

<meta name="description" content="Images of the Pilgrim Lutheran Church in Columbia, SC.  Photography by and Copyright Doug Greenwald, all rights reserved." />
<meta name="keywords" content="doug, greenwald, photography, pilgrim, lutheran, church, columbia, sc, south, carolina" />
<meta name="revision" content="${TODAY}" />

</head>

<body>

<!-- ****************************************************************** -->

<table cellspacing=5 cellpadding=3 border=0>

<tr>  
<td width=5>&nbsp;</td>
<td valign=top><h1 align=center>${ImageFile}</h1>
<p>Click the image to see it full-sized...</p>
</td>
</tr>

<tr><td width=5>&nbsp;</td><td>&nbsp;</td></tr>

<tr>
<td width=5>&nbsp;</td>
<td align=center valign=top>  <!-- ***** Image goes here ***** -->
<a href="../_FullSize/${ImageFile}"><img src="${ImageFile}" width="${Width}" height="${Height}"></a>
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
      <p  align=center class="Caption"><a href="${ZFURLPrefix}${ZFGal}/?photo=${ZFid}">Click Here</a> if you would like to purchase this image as a large print, poster, puzzle, or mousepad.</p>
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
<td><center><a class="address" href="mailto:doug.greenwald@gmail.com">Doug Greenwald</a></center></td>
</tr>

</table>

</body>
</html>
EOF

  #
  #  add entry to index.html
  #

  if [ "$IMAGECOUNT" = "2" ]
  then
    echo "<td width=20>&nbsp;</td>" >> index.html
    echo "<td align=center valign=top><a href=\"_Screen/${ImageFile}.html\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index.html
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
    echo "<td align=center valign=top><a href=\"_Screen/${ImageFile}.html\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index.html
    echo "<br clear=\"all\">" >> index.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index.html
    echo "</td>" >> index.html
    IMAGECOUNT=2
  fi

  if [ "$IMAGECOUNT" = "0" ]
  then
    echo "<tr>" >> index.html
    echo "<td width=10>&nbsp;</td>" >> index.html
    echo "<td align=center valign=top><a href=\"_Screen/${ImageFile}.html\"><img src=\"_Thumb/${ImageFile}\" width=\"${TWidth}\" height=\"${THeight}\"></a>" >> index.html
    echo "<br clear=\"all\">" >> index.html
    echo "<p class=\"caption\">${ImageCaption}</p>" >> index.html
    echo "</td>" >> index.html
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
</body>
</html>
EOF

##
##  copy the index file to StartHere
##

cp -p index.html StartHere.html
