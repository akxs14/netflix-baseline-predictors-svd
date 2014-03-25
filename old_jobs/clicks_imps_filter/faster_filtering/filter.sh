#!/bin/sh

export PATH=$PATH:/opt/hadoop/bin

FILES=`cat`
echo Filtering the following files: $FILES > /dev/stderr
for F in $FILES; do
  echo File $F > /dev/stderr
  rm -f tmp2.gz
  # Filter clicks and impressions
  hadoop fs -cat $F | gzip -d | grep -E '"type":0,|"type":1,' | gzip > tmp2.gz
  # Output something to standard output to avoid being killed due to output inactivity
  echo Done with $F
  # Unfortunately it's not possible to specify a "-f" to the rm command
  hadoop fs -rm $1/$F
  hadoop fs -put tmp2.gz $1/$F
done
echo Done > /dev/stderr
