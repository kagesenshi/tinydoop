
AIRFLOW_HOME=/opt/airflow/
PYTHON=/usr/bin/python3.7

virtualenv --python $PYTHON $AIRFLOW_HOME
$AIRFLOW_HOME/bin/pip install --no-index \
    -f /usr/share/tinydoop/eggbasket -r /usr/share/tinydoop/airflow-requirements.txt
