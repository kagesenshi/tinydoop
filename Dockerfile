FROM kagesenshi/fedora-systemd-sshd:latest

RUN dnf install -y mariadb-server java-1.8.0-openjdk-devel mysql-connector-java \
    postgresql-jdbc polkit \
    && dnf clean all
ADD hadoop-3.1.2.tar.gz /opt/
ADD apache-hive-2.3.5-bin.tar.gz /opt/
ADD spark-2.4.3-bin-without-hadoop.tgz /opt/
ADD sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz /opt/
RUN useradd -ms /bin/bash tinydoop \
    && echo 'password' |passwd tinydoop --stdin; \
    mkdir -p /var/lib/hadoop/hive_metastore \
             /var/lib/hadoop/namenode/name \
             /var/lib/hadoop/namenode/edits \
             /var/lib/hadoop/datanode \
             /var/lib/spark/worker \
             /var/lib/spark/local \
             /var/log/hadoop/ \
             /var/log/spark/ \
    && chown tinydoop:tinydoop -R /var/lib/hadoop \
                               /var/lib/spark \
                               /var/log/hadoop \
                               /var/log/spark;

COPY etc/hadoop/* /opt/hadoop-3.1.2/etc/hadoop/
COPY etc/hive/* /opt/apache-hive-2.3.5-bin/conf/
COPY etc/profile.d/hadoop.sh /etc/profile.d/hadoop.sh
COPY initialize.sh /home/tinydoop/initialize.sh
COPY systemd/* /usr/lib/systemd/system/
COPY init-mysql.sh /home/tinydoop/init-mysql.sh
COPY bin/tinydoop_start.sh /bin/tinydoop_start.sh
RUN ln -s /opt/apache-hive-2.3.5-bin /opt/hive;\
    ln -s /opt/hadoop-3.1.2 /opt/hadoop;\
    ln -s /opt/spark-2.4.3-bin-without-hadoop /opt/spark;\
    ln -s /opt/sqoop-1.4.7.bin__hadoop-2.6.0 /opt/sqoop;\
    chmod a+x /bin/tinydoop_start.sh;

RUN chkconfig namenode on; \
    chkconfig datanode on; \
    chkconfig resourcemanager on; \
    chkconfig nodemanager on; \
    chkconfig hiveserver2 on; \
    chkconfig mariadb on;

COPY etc/my.cnf.d/tinydoop.cnf /etc/my.cnf.d/tinydoop.cnf 

RUN bash /home/tinydoop/init-mysql.sh
USER tinydoop
RUN bash /home/tinydoop/initialize.sh
USER root

RUN dnf install -y python3 python3-devel python3-virtualenv \
    gcc gcc-c++ postgresql-devel mariadb-devel krb5-devel cyrus-sasl-devel
RUN virtualenv /opt/airflow/ && \
    /opt/airflow/bin/pip install apache-airflow[all]==1.10.3 && \
    /opt/airflow/bin/pip install flask==1.1.0 && \
    /opt/airflow/bin/pip install azure-mgmt-resource==2.2.0 && \
    /opt/airflow/bin/pip install google-cloud-bigtable==0.33 && \
    /opt/airflow/bin/pip install azure-datalake-store==0.0.46 && \
    /opt/airflow/bin/pip freeze > /root/requirements.txt

COPY etc/sysconfig/airflow /etc/sysconfig/airflow
RUN mkdir -p /etc/airflow/dags /etc/airflow/plugins /var/log/airflow 

COPY etc/airflow/airflow.cfg /etc/airflow/airflow.cfg
COPY etc/profile.d/99-airflow.sh /etc/profile.d/99-airflow.sh
COPY init-mysql-airflow.sh /root/init-mysql-airflow.sh
RUN bash /root/init-mysql-airflow.sh
RUN rm /var/lib/mysql/mysql.sock
RUN chkconfig airflow-webserver on; \
    chkconfig airflow-scheduler on; \
    chkconfig systemd-tmpfiles-setup on;

RUN chown tinydoop:tinydoop -R /etc/airflow /var/log/airflow


EXPOSE 8020
EXPOSE 8088
EXPOSE 10000
EXPOSE 8080
