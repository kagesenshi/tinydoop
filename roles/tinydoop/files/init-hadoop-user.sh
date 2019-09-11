#!/bin/bash

USER=$1

hdfs dfs -stat /user/$USER
if [ "x$?" != "x0" ]; then
    hdfs dfs -mkdir /user/$USER
    hdfs dfs -chown $USER:$USER /user/$USER
fi
