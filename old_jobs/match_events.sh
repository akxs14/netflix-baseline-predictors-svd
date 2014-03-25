hadoop jar build/old_jobs.jar match_events_job "`hadoop fs -cat /events/info.json | ruby logs_between.rb -4.weeks +1.hours`" /tmp/angelos/match_events
