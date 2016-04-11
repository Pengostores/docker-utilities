# docker-utilities
Scripts utiles para manejo de Dockers

##newStack.sh
###Uso:
```
./newStack.sh
```

> Si no se tiene instalado docker-compose se instala y activa el login del Pengo:registry, por lo que será necesario ejecutar de nuevo el script para crear el docker.

##nginxVhost.cfg
Para resolver los nombres de dominios de cada proyecto es necesario usar las funciones de proxy de nginx, para esto crearemos un vhost que envíe cualquier petición del puerto 80 al docker que le corresponde.
> Nota: como siempre hay que dar editar el hosts con el nombre del dominio.
