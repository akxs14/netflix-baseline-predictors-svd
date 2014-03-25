#!/bin/sh

# Reads the list of event files from stdin and generates filtered event files

# First use the input file list to generate the file list for the Hadoop job
tr , '\n' > FILE_LIST

# Default locations for Streaming Jars in Mac and opt0
STREAMING_JARS="/usr/local/Cellar/hadoop/1.2.1/libexec/contrib/streaming/hadoop-streaming-1.2.1.jar /opt/hadoop/contrib/streaming/hadoop-streaming-1.1.2-SNAPSHOT.jar"

for JAR in $STREAMING_JARS; do
  if [[ -z $STREAMING_JAR && -f $JAR ]]; then
    STREAMING_JAR=$JAR
  fi
done

if [ -z $STREAMING_JAR ]; then
  echo No JAR for Hadoop streaming found
  exit 1
fi

FILTER=`pwd`/filter.sh

TASKS=$1
if [ -z $TASKS ]; then
  TASKS=$(cat FILE_LIST | wc -l | awk '{ print $1 }')
fi

OUTPUT=$2
if [ -z $OUTPUT ]; then
  OUTPUT=/clicks_impressions
fi

# Output to make Hadoop job happy
FAKE_OUTPUT=/tmp/hadoop_filter_fake_output

hadoop fs -rmr $FAKE_OUTPUT
hadoop fs -rm /tmp/FILE_LIST
hadoop fs -put FILE_LIST /tmp

# Is timeout really needed? Probably not.
# The /bin/cat mapper is needed because in some
# Hadooop versions the identity mapper does not run.
hadoop jar $STREAMING_JAR \
	-Dmapred.task.timeout=600000000 \
	-Dmapred.reduce.tasks=$TASKS \
	-input /tmp/FILE_LIST \
	-output $FAKE_OUTPUT \
	-file $FILTER \
	-mapper "/bin/cat" \
	-reducer "filter.sh $OUTPUT"
