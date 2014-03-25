
Usage:
======

Test jar locally:
-----------------

hadoop jar ClicksImpressionsFilter events/2013/10/01/ci_1000.json,events/2013/10/02/ci_1000.json

Test it in the cluster:
-----------------------

hadoop jar CIFilter.jar ClicksImpressionsFilter "`hadoop fs -cat /events/info.json | ruby logs_between.rb DD/MM/YYYY +1.days`" /tmp/output/folder


Note: Timespan is an integer number with the time span as the message send to FixNum

e.g.  +1.weeks

      +3.days

      +2.months