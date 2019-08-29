# SPEC file overview:
# https://docs.fedoraproject.org/en-US/quick-docs/creating-rpm-packages/#con_rpm-spec-file-overview
# Fedora packaging guidelines:
# https://docs.fedoraproject.org/en-US/packaging-guidelines/

%global  __brp_mangle_shebangs_exclude python
%global  __brp_mangle_shebangs_exclude_from /opt/

%define debug_package %{nil}
%define _unpackaged_files_terminate_build 0

Name:	    tinydoop
Version:	0.1.0
Release:	0%{?dist}
Summary:	Small hadoop cluster for development purposes

License:	Various
URL:		https://hub.docker.com/r/kagesenshi/tinydoop
Source0:    tinydoop-0.1.0.tar

Source1: hadoop-3.1.2.tar.gz 
Source2: apache-hive-2.3.5-bin.tar.gz 
Source3: spark-2.4.3-bin-without-hadoop.tgz 
Source4: sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz 
Source5: apache-livy-0.6.0-incubating-bin.tar.gz 
Source6: nifi-1.9.2-bin.tar.gz 
Source7: hbase-2.2.0-bin.tar.gz 
Source8: apache-zookeeper-3.5.5-bin.tar.gz 
Source9: spark-hive_2.11-2.4.3.jar

BuildRequires:	python3-virtualenv
Requires:	mariadb-server java-1.8.0-openjdk-devel mysql-connector-java
Requires:   postgresql-jdbc polkit libxcrypt-compat less npm
Requires:   python3 python3-devel python3-virtualenv
Requires:   gcc gcc-c++ postgresql-devel mariadb-devel krb5-devel cyrus-sasl-devel
Requires:   dbus-tools

Requires(pre): shadow-utils
AutoReq: no
AutoProv: no

%description


%prep
%setup -q
%setup -q -T -D -a 1
%setup -q -T -D -a 2
%setup -q -T -D -a 3
%setup -q -T -D -a 4
%setup -q -T -D -a 5
%setup -q -T -D -a 6
%setup -q -T -D -a 7
%setup -q -T -D -a 8

%build


%install
mkdir -p     %{buildroot}/etc/sysconfig \
             %{buildroot}/etc/profile.d \
             %{buildroot}/etc/my.cnf.d \
             %{buildroot}/bin/ \
             %{buildroot}/usr/bin/ \
             %{buildroot}/usr/lib/systemd/system \
             %{buildroot}/usr/lib/systemd/user \
             %{buildroot}/usr/share/tinydoop/eggbasket/ \
             %{buildroot}/usr/share/tinydoop/systemd/ \
             %{buildroot}/opt/ \
             %{buildroot}/var/lib/hadoop/hive_metastore \
             %{buildroot}/var/lib/hadoop/namenode/name \
             %{buildroot}/var/lib/hadoop/namenode/edits \
             %{buildroot}/var/lib/hadoop/datanode \
             %{buildroot}/var/lib/spark/worker \
             %{buildroot}/var/lib/spark/local \
             %{buildroot}/var/lib/nifi/ \
             %{buildroot}/var/log/hadoop/ \
             %{buildroot}/var/log/spark/ \
             %{buildroot}/var/log/livy/ \
             %{buildroot}/var/log/nifi/ \
             %{buildroot}/var/log/hbase/ \
             %{buildroot}/var/lib/zookeeper/ 

mv apache-hive-2.3.5-bin %{buildroot}/opt/hive;
mv hadoop-3.1.2 %{buildroot}/opt/hadoop;
mv spark-2.4.3-bin-without-hadoop %{buildroot}/opt/spark;
mv sqoop-1.4.7.bin__hadoop-2.6.0 %{buildroot}/opt/sqoop;
mv apache-livy-0.6.0-incubating-bin %{buildroot}/opt/livy; 
mv nifi-1.9.2 %{buildroot}/opt/nifi; 
mv hbase-2.2.0 %{buildroot}/opt/hbase; 
mv apache-zookeeper-3.5.5-bin/ %{buildroot}/opt/zookeeper;

find %{buildroot}/opt/nifi -type d -exec chmod a+rx '{}' ';'
find %{buildroot}/opt/nifi -type f -exec chmod a+r '{}' ';'
chmod a+x %{buildroot}/opt/nifi/bin/*

cp %{SOURCE9} %{buildroot}/opt/spark/jars/
cp etc/hadoop/* %{buildroot}/opt/hadoop/etc/hadoop/
cp etc/hive/* %{buildroot}/opt/hive/conf/
cp etc/hbase/* %{buildroot}/opt/hbase/conf/
cp etc/zookeeper/* %{buildroot}/opt/zookeeper/conf/
cp etc/profile.d/hadoop.sh %{buildroot}/etc/profile.d/hadoop.sh
cp init-hdfs.sh %{buildroot}/usr/share/tinydoop/init-hdfs.sh
cp systemd/* %{buildroot}/usr/lib/systemd/system/
cp opt/nifi/bin/nifi-env.sh %{buildroot}/opt/nifi/bin/nifi-env.sh
cp etc/nifi/* %{buildroot}/opt/nifi/conf/
cp init-mysql.sh %{buildroot}/usr/share/tinydoop/init-mysql.sh
cp bin/tinydoop_start.sh %{buildroot}/bin/tinydoop_start.sh
cp etc/sysconfig/livy %{buildroot}/etc/sysconfig/livy
cp etc/my.cnf.d/tinydoop.cnf %{buildroot}/etc/my.cnf.d/tinydoop.cnf

cp etc/airflow/airflow.cfg %{buildroot}/usr/share/tinydoop/airflow.cfg.sample
#cp etc/profile.d/99-airflow.sh %{buildroot}/etc/profile.d/99-airflow.sh
cp init-mysql-airflow.sh %{buildroot}/usr/share/tinydoop/init-mysql-airflow.sh
cp etc/sparkmagic/config.json %{buildroot}/usr/share/tinydoop/sparkmagic-config.json

cp *-requirements.txt %{buildroot}/usr/share/tinydoop/

cp eggbasket/* %{buildroot}/usr/share/tinydoop/eggbasket/

cp systemd-user/* %{buildroot}/usr/lib/systemd/user/

%pre
getent group tinydoop >/dev/null || groupadd -r tinydoop
getent passwd tinydoop >/dev/null || \
    useradd -r -g tinydoop -d /home/tinydoop -m -s /bin/bash tinydoop
exit 0

%post

%files
%defattr(-, root, root, -)

/opt/hadoop
/opt/hbase
/opt/hive
/opt/livy
/opt/nifi
/opt/spark
/opt/sqoop
/opt/zookeeper
/usr/share/tinydoop

%attr(755, root, root) /bin/tinydoop_start.sh
/etc/my.cnf.d/tinydoop.cnf
/etc/profile.d/hadoop.sh
/etc/sysconfig/livy
/usr/lib/systemd/system/datanode.service
/usr/lib/systemd/system/hbase-master.service
/usr/lib/systemd/system/hbase-regionserver.service
/usr/lib/systemd/system/hiveserver2.service
/usr/lib/systemd/system/httpfs.service
/usr/lib/systemd/system/livy.service
/usr/lib/systemd/system/namenode.service
/usr/lib/systemd/system/nifi.service
/usr/lib/systemd/system/nodemanager.service
/usr/lib/systemd/system/resourcemanager.service
/usr/lib/systemd/system/secondarynamenode.service
/usr/lib/systemd/system/zookeeper.service
/usr/lib/systemd/user/airflow-webserver.service
/usr/lib/systemd/user/airflow-scheduler.service
/usr/lib/systemd/user/jupyterlab.service

%attr(-,tinydoop,tinydoop) /var/lib/hadoop/
%attr(-,tinydoop,tinydoop) /var/lib/spark/
%attr(-,tinydoop,tinydoop) /var/lib/nifi/ 
%attr(-,tinydoop,tinydoop) /var/lib/zookeeper/ 

%attr(-,tinydoop,tinydoop) /var/log/hadoop/ 
%attr(-,tinydoop,tinydoop) /var/log/spark/ 
%attr(-,tinydoop,tinydoop) /var/log/livy/ 
%attr(-,tinydoop,tinydoop) /var/log/nifi/ 
%attr(-,tinydoop,tinydoop) /var/log/hbase/ 


%changelog

