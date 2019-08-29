#!/bin/bash

set -e 

chmod +x /opt/nifi/bin/*
find /opt/nifi -type d -exec chmod a+rx '{}' ';'
find /opt/nifi -type f -exec chmod a+r '{}' ';'
touch /opt/nifi/.permission_fixed
