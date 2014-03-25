# rhadoop

Some ruby map and reduce scripts

Very simple ruby map-reduce script to calculate the difference between impression and click timestamps

Instructions
------------

First package:

    rake package

Time between impression and click
---------------------------------

    hadoop jar build/rhadoop.jar impression_click_timestamp_diff_job "/events/2013/07/01/*/part*" /tmp/fabio/impression_click_ts_diff


Match impression and click data
-------------------------------

    hadoop jar build/rhadoop.jar match_impression_click_job "`hadoop fs -cat /events/info.json | ruby logs_between.rb -4.weeks +4.weeks`" /tmp/fabio/match_impression_clicks
