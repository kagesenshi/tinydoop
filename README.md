Existing Hadoop data platform sandboxes from Cloudera/Hortonworks are quite heavy to run on a developer laptop, and this provide a challenge and increases cost for developers to develop jobs for the platform.

This container provides a small pseudo-distributed Hadoop cluster that is light enough for use in laptop, containing just the bare necessities for doing batch job development on Apache Hive & Spark. 

Components included:
- Hadoop 3.1.2
- Hive 2.3.5
- Spark 2.4.3
- Sqoop 1.4.7
- Airflow 1.10.3
- Livy 0.6.0
- HBase 2.2.0
- NiFi 1.9.2
- Airflow 1.10.3

Running the container:

~~~~
docker pull kagesenshi/tinydoop:latest
docker run --privileged --rm -v /sys/fs/cgroup/:/sys/fs/cgroup:rw -d \
    -p 2222:22 -p 8080:8080 -p 8090:8090 -p 8088:8088 -p 14000:14000 -p 10000:10000 \
     kagesenshi/tinydoop
~~~~

The container runs SSHD on port 2222, and you can ssh with username: ``tinydoop``, password: ``password``. Root password is ``password``
