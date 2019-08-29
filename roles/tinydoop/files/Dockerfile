FROM kagesenshi/fedora-systemd-sshd:latest

RUN dnf install -y mariadb-server java-1.8.0-openjdk-devel mysql-connector-java \
    postgresql-jdbc polkit libxcrypt-compat less npm python3 python3-devel python3-virtualenv \
    gcc gcc-c++ postgresql-devel mariadb-devel krb5-devel cyrus-sasl-devel && \
    dnf clean all

COPY tinydoop-0.1.0-0.fc30.x86_64.rpm /root/
RUN dnf install -y /root/tinydoop-0.1.0-0.fc30.x86_64.rpm
RUN rm /root/tinydoop-0.1.0-0.fc30.x86_64.rpm

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

RUN bash /usr/share/tinydoop/init-mysql.sh

USER tinydoop
RUN bash /usr/share/tinydoop/init-hdfs.sh

RUN virtualenv --python /usr/bin/python3.7 /home/tinydoop/opt/airflow/ && \
    /home/tinydoop/opt/airflow/bin/pip install --no-index \
        -f /usr/share/tinydoop/eggbasket \
        -r /usr/share/tinydoop/airflow-requirements.txt 

RUN mkdir -p /home/tinydoop/opt/airflow/etc/airflow/dags \
    /home/tinydoop/opt/airflow/etc/airflow/plugins \
    /home/tinydoop/opt/airflow/logs 

COPY etc/airflow/airflow.cfg /home/tinydoop/opt/airflow/etc/airflow/airflow.cfg

RUN systemctl --user enable airflow-webserver; \
    systemctl --user enable airflow-scheduler; 

USER root

RUN bash /usr/share/tinydoop/init-mysql-airflow.sh
RUN rm /var/lib/mysql/mysql.sock

#RUN virtualenv --python /usr/bin/python3.7 /opt/jupyterlab/ && \
#    cd /opt/spark/python/ && /opt/jupyterlab/bin/python setup.py sdist && \
#    /opt/jupyterlab/bin/pip install /opt/spark/python/dist/*.tar.gz && \
#    /opt/jupyterlab/bin/pip install jupyterlab==1.0.2 && \
#    /opt/jupyterlab/bin/pip install jupyterhub==1.0.0 && \
#    /opt/jupyterlab/bin/pip install sparkmagic==0.12.9 && \
#    /opt/jupyterlab/bin/pip install optimuspyspark==2.2.7 && \
#    /opt/jupyter/bin/pip freeze > /root/jupyterlab-requirements.txt
#
#RUN /opt/jupyterlab/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
#    /opt/jupyterlab/bin/jupyter serverextension enable --py sparkmagic && \
#    /opt/jupyterlab/bin/jupyter labextension install \
#                                         @jupyter-widgets/jupyterlab-manager && \
#    mkdir /home/tinydoop/.sparkmagic 
#
#COPY etc/sparkmagic/config.json /home/tinydoop/.sparkmagic/config.json
#
#RUN chown tinydoop:tinydoop -R /home/tinydoop/.sparkmagic/
#
#USER tinydoop
#RUN /opt/jupyterlab/bin/jupyter-kernelspec install /opt/jupyterlab/lib/python3.7/site-packages/sparkmagic/kernels/sparkkernel/ --user && \
#    /opt/jupyterlab/bin/jupyter-kernelspec install /opt/jupyterlab/lib/python3.7/site-packages/sparkmagic/kernels/pysparkkernel/ --user && \
#    /opt/jupyterlab/bin/jupyter-kernelspec install /opt/jupyterlab/lib/python3.7/site-packages/sparkmagic/kernels/sparkrkernel/ --user
#USER root
#
#RUN chkconfig jupyterlab on
#
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
