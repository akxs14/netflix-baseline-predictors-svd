#!/bin/bash

# if [[ $# != 2 ]]; then
#   echo "Usage: run number_of_weeks(=1-4) path/to/output"
#   exit 1
# fi

# if [[ -e "$2" ]]; then
#   echo "error: output path exist"
#   exit 2
# fi

# hadoop fs -rmr /tmp/angelos/train_bias_model

# hadoop jar build/hadoop_jobs.jar bias_model "`hadoop fs -cat /events/info.json | ruby logs_between.rb 01/09/2013 +10.minutes`" /tmp/angelos/bias
hadoop fs -cat /events/info.json | ruby logs_between.rb -2.weeks +2.weeks | time hadoop jar build/hadoop_jobs.jar bias_model - /tmp/angelos/bias
