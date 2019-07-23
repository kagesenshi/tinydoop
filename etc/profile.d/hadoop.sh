export JAVA_HOME='/usr/lib/jvm/java-1.8.0/'
export HADOOP_HOME='/opt/hadoop/'
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_HOME=$HADOOP_HOME
export HIVE_HOME='/opt/hive/'
export SPARK_HOME='/opt/spark/'
export SPARK_CONF_DIR=$SPARK_HOME/conf
export SQOOP_HOME='/opt/sqoop/'
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HIVE_HOME/bin:$SPARK_HOME/bin:$HADOOP_HOME/sbin
export PATH=$PATH:$SQOOP_HOME/bin
export HADOOP_CLASSPATH=$(hadoop classpath):$SQOOP_HOME/lib/*
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/usr/share/java/mysql-connector-java.jar
export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:/usr/share/java/postgresql-jdbc.jar
export SPARK_DIST_CLASSPATH=$HADOOP_CLASSPATH
export HADOOP_LOG_DIR=/var/log/hadoop/
export SPARK_WORKER_DIR=/var/lib/spark/worker/
export SPARK_LOCAL_DIRS=/var/lib/spark/local/
export SPARK_LOG_DIR=/var/log/spark/
export LIVY_LOG_DIR=/var/log/livy/
