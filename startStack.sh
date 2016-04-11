#!/bin/bash
#
# ------------------
# Ejecuta un stack de proyecto Magento2
# ------------------
# @params: [stack string] [restoreBackup string] [deployStatic string]
# @author: Ivan Miranda @deivanmiranda
# ------------------
#
# APLICAR PARAMETROS ADICIONALES
for var in "$@"
do
	if [ "${var:0:1}" != "-" ]; then
		stack="${var^^}"
		stack="${stack}" | sed -e 's/^[ \t]*//'
		host=${stack,,}
	fi
done
if [ "$stack" == "" ]; then
    echo "Sin un nombre de stack no podemos continuar"
    exit;
fi
# LEVANTAR STACK
cd "$stack"
docker-compose up -d
cd ..
docker exec -i "$host"_web_1 chmod +x bin/magento
for var in "$@"
do
#DUMP
	if [ "${var:1}" == "d" ] || [ "${var:2}" == "dump" ]; then
		if [ -f "./build/dump.sql" ]; then
			echo "Cargando dump..."
			docker exec -i "$host"_db_1 mysql -upengo -ppengo123 mage2 < ./build/dump.sql
			echo "Base cargada..."
		else
			echo "No existe el archivo build/dump.sql"
		fi
	fi
#STATIC
	if [ "${var:1}" == "s" ] || [ "${var:2}" == "static" ]; then
		echo "Recreando contenido estatico"
		docker exec -i "$host"_php_1 bin/magento setup:static-content:deploy
		echo "Aplicando permisos"
		docker exec -i "$host"_web_1 chmod 777 var/ pub/ -R
	fi
#CACHE
	if [ "${var:1}" == "c" ] || [ "${var:2}" == "cache" ]; then
		echo "Limpiando cache"
		docker exec -i "$host"_php_1 bin/magento cache:clean
		docker exec -i "$host"_php_1 bin/magento cache:flush
	fi
done
echo "Stack $stack corriendo"
