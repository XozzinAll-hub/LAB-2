#!/bin/bash

#punto 1 si es el root
if [ "$EUID" -ne 0 ]; then
	echo "Error: solo el usuario root lo puede ejecutar"
	exit
fi

#punto 2 solo 3 entradas y que sean usuario grupo y la ruta del archivo
if [ $# -ne 3 ]; then 
	echo "el formato de entrada debe de ser usuario grupo /ruta/archivo"
	exit
fi

usuario=$1
grupo=$2
archivo=$3

#punto 3 ver si el archivo existe con la ruta dada

if [ ! -f "$archivo" ]; then
	echo "Error: no se encontro $3"
	exit
fi

#punto 4 varificar grupo y crear si no existe >dato de los grupos almacenado en/etc/gruop

if grep -q "^$grupo:" /etc/group; then
	echo "$grupo ya existe"
else
	groupadd "$grupo"
	echo "nuevo grupo> $grupo"
fi

#punto 5 verificar el usuario> la data de este esta en /dev/null y se busca por id
if id "$usuario" &>/dev/null; then
	echo "$usuario ya existe como usuario"
	usermod -a -G $grupo $usuario
else
	useradd -m -g $grupo $usuario #SI NO EXISTE EL GRUPO -g no va a servir
	echo "el usuario $usuario fue creado correctamente"
fi

#punto 6 cambio de propietario
chown $usuario:$grupo "$archivo"

#punto 7 cambio de los permisos a que el u:rwx , g:r , o: nada (740)
chmod 740 "$archivo"
echo "Se completo la modificacion al archivo"
