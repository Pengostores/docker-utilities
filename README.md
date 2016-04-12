# docker-utilities
Scripts utiles para manejo de Dockers

##newStack.sh
Crea un nuevo stack de desarrollo para Magento2
####Uso:
```
./newStack.sh
```

> Si no se tiene instalado docker-compose se instala y activa el login del Pengo:registry, por lo que será necesario ejecutar de nuevo el script para crear el docker.

##nginxVhost.cfg
Para resolver los nombres de dominios de cada proyecto es necesario usar las funciones de proxy de nginx, para esto crearemos un vhost que envíe cualquier petición del puerto 80 al docker que le corresponde.
> Nota: como siempre hay que dar editar el hosts con el nombre del dominio.

##startStack.sh
Levanta un stack previamente registrado y permite hacer operaciones básicas dentro del contenido del contenedor
####Uso:
```
./startStack.sh nombreStack [-d|--dump] [-s|--static] [-c|--cache]
```
> [dump] Para que se cargue un dump en la base de datos del stack, es necesario que este exista en ./build/dump.slq
> [static] Reconstruye el contenido estático
> [cache] Limpia el cache de magento

##stopStack.sh
Detiene la ejecución de un stack
####Uso:
```
./stopStack.sh nombreStack
```

##rmStack.sh
Elimina un stack (y los directorios asociados)
####Uso:
```
./stopStack.sh nombreStack
```
> Pregunta antes de eliminar el directorio
