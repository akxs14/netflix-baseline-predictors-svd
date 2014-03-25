Hadoop streaming filtering script
=================================

Usage
-----
To filter the scripts that reside in the /events directory you can run
a command like the following:

```
$ hadoop fs -cat /events/info.json | ruby ../logs_between.rb 1/09/2013 +1.weeks | ./hadoop_filter.sh
```

It will generate filtered versions of events files in /click_impressions.

You can optionally specify the number of reduce jobs to use. We suggest using
a large number (320 tasks) if you process a lot of data. Specially because
Hadoop's key hashing function does not seem to be very good.

Implementation
--------------
This script filters the event files stored in the LiquidM Hadoop cluster
using Hadoop streaming.

The reducers in this filtering job run a shell script (filter.sh) that
keeps only impressions and clicks from event files.

The original intent was to use a map task per file to be processed. This is
indeed what the hadoop streaming documentation suggests:
http://hadoop.apache.org/docs/stable/streaming.html .
Search for "How do I process files, one per map?" for more details.
Unfortunately that was not possible to do (no details provided in the documentation
either) easily. For example, the input file with file names cannot be split
with 1 file name per mapper granularity. Therefore we perform the work
in the reducers. We use the filename as the key but apparently Hadoop's hashing
function is not great since the file name distribution is quite skewed.
