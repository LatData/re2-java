#!/bin/bash -l

mkdir -p $LDP_FLUME_HOME/plugins.d/latdata-collect/lib
find -name \*.jar | grep -v source |xargs cp -t $LDP_FLUME_HOME/plugins.d/latdata-collect/lib/
