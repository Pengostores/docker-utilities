#!/bin/bash
#
# ------------------
# Ejecuta un stack de proyecto Magento2
# ------------------
# @params: [stack string]
# @author: Ivan Miranda @deivanmiranda
# ------------------
#
stack="${1^^}"
stack="${stack}" | sed -e 's/^[ \t]*//'
if [ "$stack" == "" ]; then
    echo "Sin un nombre de stack no podemos continuar"
    exit;
fi
cd "$stack"
docker-compose up -d
cd ..
