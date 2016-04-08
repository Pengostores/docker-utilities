#!/bin/bash
#
# ------------------
# Detiene un stack en ejecucion
# ------------------
# @params: [stack string]
# @author: Ivan Miranda @deivanmiranda
# ------------------
#
stack="$1"
stack="${stack}" | sed -e 's/^[ \t]*//'
if [ "$stack" == "" ]; then
    echo "Sin un nombre de stack no podemos continuar"
    exit;
fi
docker stop $(docker ps -f=name=$stack -a -q)
