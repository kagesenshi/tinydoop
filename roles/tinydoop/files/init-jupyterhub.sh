#!/bin/bash

set -e 

JUPYTER_HOME=/opt/jupyterhub/
PYTHON=/usr/bin/python3.7
SPARK_HOME=/opt/spark
PYTHON_SITE_DIR=$JUPYTER_HOME/lib/`basename $PYTHON`/site-packages

virtualenv --python /usr/bin/python3.7 $JUPYTER_HOME

pushd $SPARK_HOME/python/
$JUPYTER_HOME/bin/python setup.py sdist
$JUPYTER_HOME/bin/pip install $SPARK_HOME/python/dist/*.tar.gz
$JUPYTER_HOME/bin/pip install jupyterlab==1.1.0
$JUPYTER_HOME/bin/pip install jupyterhub==1.0.0 
$JUPYTER_HOME/bin/pip install sparkmagic==0.12.9 
$JUPYTER_HOME/bin/pip install optimuspyspark==2.2.7 

$JUPYTER_HOME/bin/jupyter nbextension enable --py --sys-prefix widgetsnbextension
$JUPYTER_HOME/bin/jupyter serverextension enable --py sparkmagic 
$JUPYTER_HOME/bin/jupyter labextension install @jupyter-widgets/jupyterlab-manager 

pushd $PYTHON_SITE_DIR
$JUPYTER_HOME/bin/jupyter-kernelspec install sparkmagic/kernels/sparkkernel/ 
$JUPYTER_HOME/bin/jupyter-kernelspec install sparkmagic/kernels/pysparkkernel/
$JUPYTER_HOME/bin/jupyter-kernelspec install sparkmagic/kernels/sparkrkernel/ 
popd

#$JUPYTER_HOME/bin/pip install jupyterlab_sql==0.3.0
#$JUPYTER_HOME/bin/jupyter serverextension enable jupyterlab_sql --py --sys-prefix
$JUPYTER_HOME/bin/pip install bokeh==1.3.4
$JUPYTER_HOME/bin/jupyter labextension install jupyterlab_bokeh

$JUPYTER_HOME/bin/pip install altair==3.2.0 vega-datasets==0.7.0

$JUPYTER_HOME/bin/pip install jupyterlab_iframe==0.2.1
$JUPYTER_HOME/bin/jupyter serverextension enable jupyterlab_iframe --py --sys-prefix

$JUPYTER_HOME/bin/jupyter lab build
