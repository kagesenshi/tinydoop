
source /etc/profile.d/hadoop.sh

hdfs namenode -format

hdfs namenode &
NN_PID=$$

hdfs datanode & 
DN_PID=$$

sleep 30

hdfs dfs -mkdir -p /user/tinydoop/ /user/hive/warehouse 

sleep 30

kill $NN_PID $DN_PID
