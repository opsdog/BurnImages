#!/bin/ksh
#!/usr/local/bin/ksh

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
<li><a href="index-c.html">Critters</a>
<li><a href="index-f.html">Flowers/Grounds</a>
<li><a href="index-h.html">HDR</a>
</ul>

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

##
##  call the scripts to build the actual image tables
##

./CreateFlowers.ksh -f
./CreateCritter.ksh -f
./CreateHDR.ksh -f
