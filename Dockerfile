FROM kagesenshi/fedora-systemd-sshd:latest

RUN dnf install -y mariadb-server java-1.8.0-openjdk-devel mysql-connector-java \
    postgresql-jdbc polkit libxcrypt-compat less npm \
    && dnf clean all
ADD hadoop-3.1.2.tar.gz /opt/
ADD apache-hive-2.3.5-bin.tar.gz /opt/
ADD spark-2.4.3-bin-without-hadoop.tgz /opt/
ADD sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz /opt/
ADD apache-livy-0.6.0-incubating-bin.tar.gz /opt/
ADD nifi-1.9.2-bin.tar.gz /opt/
ADD hbase-2.2.0-bin.tar.gz /opt/
ADD apache-zookeeper-3.5.5-bin.tar.gz /opt/
RUN useradd -ms /bin/bash tinydoop \
    && echo 'password' |passwd tinydoop --stdin; \
    mkdir -p /var/lib/hadoop/hive_metastore \
             /var/lib/hadoop/namenode/name \
             /var/lib/hadoop/namenode/edits \
             /var/lib/hadoop/datanode \
             /var/lib/spark/worker \
             /var/lib/spark/local \
             /var/lib/nifi/ \
             /var/log/hadoop/ \
             /var/log/spark/ \
             /var/log/livy/ \
             /var/log/nifi/ \
             /var/log/hbase/ \
             /var/lib/zookeeper/ \
    && chown tinydoop:tinydoop -R /var/lib/hadoop \
                               /var/lib/spark \
                               /var/lib/nifi \
                               /var/log/hadoop \
                               /var/log/spark \
                               /var/log/livy \
                               /var/log/nifi \
                               /var/log/hbase \
                               /var/lib/zookeeper/;



RUN ln -s /opt/apache-hive-2.3.5-bin /opt/hive;\
    ln -s /opt/hadoop-3.1.2 /opt/hadoop;\
    ln -s /opt/spark-2.4.3-bin-without-hadoop /opt/spark;\
    ln -s /opt/sqoop-1.4.7.bin__hadoop-2.6.0 /opt/sqoop;\
    ln -s /opt/apache-livy-0.6.0-incubating-bin /opt/livy; \
    ln -s /opt/nifi-1.9.2 /opt/nifi; \
    ln -s /opt/hbase-2.2.0 /opt/hbase; \
    ln -s /opt/apache-zookeeper-3.5.5-bin/ /opt/zookeeper; 

COPY spark-hive_2.11-2.4.3.jar /opt/spark/jars/
COPY etc/hadoop/* /opt/hadoop/etc/hadoop/
COPY etc/hive/* /opt/hive/conf/
COPY etc/hbase/* /opt/hbase/conf/
COPY etc/zookeeper/* /opt/zookeeper/conf/
COPY etc/profile.d/hadoop.sh /etc/profile.d/hadoop.sh
COPY initialize.sh /home/tinydoop/initialize.sh
COPY systemd/* /usr/lib/systemd/system/
COPY opt/nifi/bin/nifi-env.sh /opt/nifi/bin/nifi-env.sh
COPY etc/nifi/* /opt/nifi/conf/
COPY init-mysql.sh /home/tinydoop/init-mysql.sh
COPY bin/tinydoop_start.sh /bin/tinydoop_start.sh
COPY etc/sysconfig/livy /etc/sysconfig/livy

# fix nifi perms
RUN find /opt/nifi/ -type d -exec chmod a+rx '{}' ';' && \
    find /opt/nifi/ -type f -exec chmod a+r '{}' ';' && \
    chmod a+x /opt/nifi/bin/* 


RUN chmod a+x /bin/tinydoop_start.sh;
RUN chkconfig namenode on; \
    chkconfig datanode on; \
    chkconfig httpfs on; \
    chkconfig resourcemanager on; \
    chkconfig nodemanager on; \
    chkconfig hiveserver2 on; \
    chkconfig livy on; \
    chkconfig nifi on; \
    chkconfig hbase-master on; \
    chkconfig hbase-regionserver on; \
    chkconfig mariadb on;

COPY etc/my.cnf.d/tinydoop.cnf /etc/my.cnf.d/tinydoop.cnf 

RUN bash /home/tinydoop/init-mysql.sh
USER tinydoop
RUN bash /home/tinydoop/initialize.sh
USER root

RUN dnf install -y python3 python3-devel python3-virtualenv \
    gcc gcc-c++ postgresql-devel mariadb-devel krb5-devel cyrus-sasl-devel
RUN virtualenv --python /usr/bin/python3.7 /opt/airflow/ && \
    /opt/airflow/bin/pip install apache-airflow[devel_ci]==1.10.3 && \
    /opt/airflow/bin/pip install flask==1.1.0 && \
    /opt/airflow/bin/pip install azure-mgmt-resource==2.2.0 && \
    /opt/airflow/bin/pip install google-cloud-bigtable==0.33 && \
    /opt/airflow/bin/pip install azure-datalake-store==0.0.46 && \
    /opt/airflow/bin/pip freeze > /root/airflow-requirements.txt



COPY etc/sysconfig/airflow /etc/sysconfig/airflow
RUN mkdir -p /etc/airflow/dags /etc/airflow/plugins /var/log/airflow 

COPY etc/airflow/airflow.cfg /etc/airflow/airflow.cfg
COPY etc/profile.d/99-airflow.sh /etc/profile.d/99-airflow.sh
COPY init-mysql-airflow.sh /root/init-mysql-airflow.sh
RUN bash /root/init-mysql-airflow.sh
RUN rm /var/lib/mysql/mysql.sock
RUN chkconfig airflow-webserver on; \
    chkconfig airflow-scheduler on; 

RUN chown tinydoop:tinydoop -R /etc/airflow /var/log/airflow

RUN virtualenv --python /usr/bin/python3.7 /opt/jupyterlab/ && \
    cd /opt/spark/python/ && /opt/jupyterlab/bin/python setup.py sdist && \
    /opt/jupyterlab/bin/pip install /opt/spark/python/dist/*.tar.gz && \
    /opt/jupyterlab/bin/pip install jupyterlab==1.0.2 && \
    /opt/jupyterlab/bin/pip install jupyterhub==1.0.0 && \
    /opt/jupyterlab/bin/pip install sparkmagic==0.12.9 && \
    /opt/jupyterlab/bin/pip install optimuspyspark==2.2.7 && \
    /opt/airflow/bin/pip freeze > /root/jupyterlab-requirements.txt

RUN /opt/jupyterlab/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
    /opt/jupyterlab/bin/jupyter serverextension enable --py sparkmagic && \
    /opt/jupyterlab/bin/jupyter labextension install \
                                         @jupyter-widgets/jupyterlab-manager && \
    mkdir /home/tinydoop/.sparkmagic 

COPY etc/sparkmagic/config.json /home/tinydoop/.sparkmagic/config.json

RUN chown tinydoop:tinydoop -R /home/tinydoop/.sparkmagic/

USER tinydoop
RUN /opt/jupyterlab/bin/jupyter-kernelspec install /opt/jupyterlab/lib/python3.7/site-packages/sparkmagic/kernels/sparkkernel/ --user && \
    /opt/jupyterlab/bin/jupyter-kernelspec install /opt/jupyterlab/lib/python3.7/site-packages/sparkmagic/kernels/pysparkkernel/ --user && \
    /opt/jupyterlab/bin/jupyter-kernelspec install /opt/jupyterlab/lib/python3.7/site-packages/sparkmagic/kernels/sparkrkernel/ --user
USER root

RUN chkconfig jupyterlab on

EXPOSE 8020
EXPOSE 8088
EXPOSE 2181
EXPOSE 2180
EXPOSE 10000
EXPOSE 8080
EXPOSE 8998
EXPOSE 8090
EXPOSE 8888
EXPOSE 14000
