#!/bin/bash
#
# ------------------
# Elimina un stack
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
docker rm $(docker ps -f=name=$stack -a -q)
stack="${stack^^}"
echo "Stack $stack eliminado"
echo "Borrar directorio [Y/n]?"
read temp
temp="${temp^^}"
temp="${temp}" | sed -e 's/^[ \t]*//'
stack="${stack^^}"
if [ "$temp" != "N" ]; then
	rm ./"$stack" -Rf
	echo "Se han borrado los datos"
fi
