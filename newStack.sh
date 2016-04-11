#!/bin/bash
#
# ------------------
# Crea un nuevo stack para un proyecto de Magento2
# Antes hay que tener instalado docker y docker-compose
# Debes haber segistrado el Pengo:registry para las imagenes de Docker
# # ------------------
# @author: Ivan Miranda @deivanmiranda
# ------------------
#
create() {
#CARPETA DE VHOST NGINX
    if [ ! -d "./vhosts" ]; then
        mkdir ./vhosts
    fi
#PUERTOS SIGUIENTES
    ports=(`docker ps -a --format '{{.Ports}}' | grep ':[0-9]*' -o`)
    phpPort=9000
    for port in ${ports[*]};do
        if [ $((${port:1})) -gt 8999 ]; then
            if [ $((phpPort)) -lt $((${port:1})) ]; then
                phpPort=$((${port:1}))
            fi
        fi
    done
    phpNextPort=$((phpPort+1))
    nginxPort=8080
    for port in ${ports[*]};do
        if [ $((${port:1})) -lt 8999 ]; then
            if [ $((nginxPort)) -lt $((${port:1})) ]; then
                nginxPort=$((${port:1}))
            fi
        fi
    done
    nginxNextPort=$((nginxPort+1))
#COMPOSE
    if [ ! -f "/usr/local/bin/docker-compose" ]; then
        echo "No tienes instalado docker-compose. Instalarlo? [Y/n]"
        read temp
        if [ "$temp" != "n" ]; then
            echo "Instalando docker-compose..."
            curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
            echo "Acceder al Pengo:registry..."
            docker login https://registry.pengostores.mx/v2
            echo "Ejecuta nuevamente este script para crear un nuevo stack"
            return 1;
        else
            echo "Sin docker-compose no podemos continuar"
            return 0;
        fi
    fi
#CONFIGURACION
    echo "------------------"
    echo "Crear un nuevo stack para Magento2"
    echo "------------------"
    echo "Nombre del nuevo stack: "
    read stack
    stack="${stack^^}"
    stack="${stack}" | sed -e 's/^[ \t]*//'
    host=${stack,,}
    if [ "$stack" == "" ]; then
        echo "Sin un nombre de stack no podemos continuar"
        return 0
    fi
    if [ -d "$stack" ]; then 
        echo "Ya tienes un stack llamado $stack"
        return 0
    fi
    echo "Puerto de PHP: [$phpNextPort]"
    read phpPort
    phpPort="${phpPort}" | sed -e 's/^[ \t]*//'
    if [ "$phpPort" == "" ]; then
        phpPort="$phpNextPort"
    fi
    for port in ${ports[*]};do
        if [ "${port:1}" == "$phpPort" ]; then
            echo "Este puerto ya esta en uso"
            return 0
        fi
    done
    echo "Puerto de Nginx: [$nginxNextPort]"
    read nginxPort
    nginxPort="${nginxPort}" | sed -e 's/^[ \t]*//'
    if [ "$nginxPort" == "" ]; then
        nginxPort="$nginxNextPort"
    fi
    for port in ${ports[*]};do
        if [ "${port:1}" == "$nginxPort" ]; then
            echo "Este puerto ya esta en uso"
            return 0
        fi
    done
    mkdir "$stack"
    if [ -d "$stack" ]; then 
        mkdir "$stack"/build "$stack"/db "$stack"/logs "$stack"/logs/nginx "$stack"/src
        echo "Creando nuevo stack..."
        echo "
php:
    image: registry.pengostores.mx/pengo/php:mage2.0
    ports:
        - $phpPort:9000
    volumes:
        - ./src:/var/www/html
    links:
        - db
web:
    image: registry.pengostores.mx/pengo/nginx:mage2.0
    ports:
        - $nginxPort:80
    volumes:
        - ./logs/nginx:/var/log/nginx
        - ./src:/var/www/html
    environment:
        - PHP_HOST=php
        - PHP_PORT=9000
        - APP_MAGE_MODE=developer
        - VIRTUAL_HOST=webserver
    links:
        - php
        - db
db:
    image: registry.pengostores.mx/pengo/mysql:mage2.0
    volumes:
        - ./db:/var/lib/mysql
    environment:
        - MYSQL_ROOT_PASSWORD=mysql
        - MYSQL_DATABASE=mage2
        - MYSQL_USER=pengo
        - MYSQL_PASSWORD=pengo123" > ./"$stack"/docker-compose.yml
        echo "... $stack creado"
    # ICEBRICK
        echo "Conectar con IceBrick [Y/n]?"
        read temp
        temp="${temp^^}"
        temp="${temp}" | sed -e 's/^[ \t]*//'
        init="no"
        if [ "$temp" != "N" ]; then
            echo "URL del repositorio a clonar"
            read temp
            temp="${temp}" | sed -e 's/^[ \t]*//'
            if [ "$temp" != "" ]; then
                init="yes"
                git clone "$temp" "$stack"/src
            fi
        fi
     # NGINX VHOST
        echo "Crear vhost para Nginx [Y/n]?"
        read temp
        temp="${temp^^}"
        temp="${temp}" | sed -e 's/^[ \t]*//'
        if [ "$temp" != "N" ]; then
            echo "Nombre del dominio (sin http://)"
            read dominio
            dominio="${dominio}" | sed -e 's/^[ \t]*//'
            echo "upstream $dominio { server 127.0.0.1:$nginxPort; }
                server {
                  listen 80;
                  server_name $dominio;
                  access_log /var/log/nginx/$dominio.log;
                  error_log /var/log/nginx/$dominio.err debug;
                  location / {
                    proxy_set_header Access-Control-Allow-Origin $http_origin;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarder-For $proxy_add_x_forwarded_for;
                    proxy_set_header Host $http_host;
                    proxy_set_header X-NginX-Proxy true;
                    proxy_pass http://$dominio;
                    proxy_redirect off;
                  }
                }" > ./vhosts/"$dominio".cfg
            echo "Plantilla de vhost creada en $stack/$dominio.cfg"
        fi
        echo "Con tu stack corriendo, puedes trabajar en http://localhost:$nginxPort"
        return 1
    else
        echo "Faltan permisos para crear directorios"
        return 0
    fi
}

create
