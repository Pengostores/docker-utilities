#!/bin/bash
#
# ------------------
# Ejecuta un stack de proyecto Magento2
# ------------------
# @params: [stack string] [restoreBackup string] [deployStatic string]
# @author: Ivan Miranda @deivanmiranda
# ------------------
#
stack="${1^^}"
stack="${stack}" | sed -e 's/^[ \t]*//'
host=${stack,,}
if [ "$stack" == "" ]; then
    echo "Sin un nombre de stack no podemos continuar"
    exit;
fi
cd "$stack"
docker-compose up -d
if [ "$2" == "-dump" ] || [ "$3" == "-dump" ] || [ "$4" == "-dump" ]; then
	if [ -f "./build/dump.sql" ]; then
		echo "Cargando dump..."
		docker exec -i "$host"_db_1 mysql -upengo -ppengo123 mage2 < ./build/dump.sql
		echo "Base cargada..."
	else
		echo "No existe el archivo build/dump.sql"
	fi
fi
if [ "$2" == "-static" ] || [ "$3" == "-static" ] || [ "$4" == "-static" ]; then
	echo "Recreando contenido estatico"
	docker exec -i "$host"_php_1 bin/magento setup:static-content:deploy
	echo "Aplicando permisos"
	docker exec -i "$host"_web_1 chmod 777 var/ pub/ -R
fi
if [ "$2" == "-cache" ] || [ "$3" == "-cache" ] || [ "$4" == "-cache" ]; then
	echo "Limpiando cache"
	docker exec -i "$host"_php_1 bin/magento cache:clean
	docker exec -i "$host"_php_1 bin/magento cache:flush
fi
cd ..
echo "Stack $stack corriendo"
