hadoop fs -cat /events/info.json | ruby logs_between.rb 01/10/2013 +1.days | time hadoop jar build/hadoop_jobs.jar generate_test_data_set - /tmp/angelos/test_data