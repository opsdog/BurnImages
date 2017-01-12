#!/bin/ksh                                                                      
##                                                                              
##  script to check to see if any of these have already been sorted             
##                                                                              

for File in `ls -l *.jpg 2>/dev/null | awk '{ print $NF }'`
do
  echo "====== $File ======"
  echo $File | awk -F\. '{ print $1 }' | read BaseName
  ##  echo "  $BaseName"                                                        
  ls ../${BaseName}.* 2>/dev/null | wc -l | awk '{ print $1 }' | read NumMatches
  ##  echo "  $NumMatches"                                                      
  if [ $NumMatches -ne 0 ]
  then
    echo "  Moving ../${BaseName}.* to ../02-NukeMe/..."
    mv ../${BaseName}.* ../02-NukeMe/
  fi
done
