#!/bin/bash 
#
#Si algun comando falla, se va a parar la ejecución del script
set -e 
#-----------------------------------------
#Scrit de despliegue entorno de desarrollo en Minikube 
#Autor: Facundo Diaz
#Fecha: 02/05/25
#Descripción: 
#Este ejecutable despliega un entorno simple en minikube. Este entorno muestra una página con contenido estático almacenada en un volumen persistente. Esta página se muestra a través de un service que accede a un pod nginx. 
#USO:
#	./ejecutable.sh

REPO_MANIFIESTOS="https://github.com/FacunDiaz/deploymentYaml.git"
REPO_STATIC="https://github.com/FacunDiaz/static-website.git" 
MINIKUBE_PROFILE="deploy-web-site"

function verificar_herramientas(){
	if ! command -v git &> /dev/null ; then 
		echo "Git no está instalado"
		exit 1
	fi
	if ! command -v kubectl &> /dev/null ; then
                echo "Kubeclt no está instalado"
		exit 1
        fi
	if ! command -v minikube &> /dev/null ; then
                echo "Minikube no está instalado"
		exit 1
        fi
}
#Ejecutamos la función para verificar las dependencias
verificar_herramientas 

#Verificar que no haya otra carpeta con el mismo nombre 
cd "$HOME" || exit 1  

#Verificamos de que el directorio no exista
if [ -d minik-static-web ]; then
    echo "El directorio minik-static-web ya existe. Limpiando el contenido..."
    rm -rf minik-static-web/*   # Borramos el contenido del directorio
else
    mkdir minik-static-web      # Si no existe, lo creamos
fi

cd minik-static-web

#Clonamos los repos dentro de la carpeta
git clone "$REPO_MANIFIESTOS" || {echo "Fallo al clonar el repositorio de manifiestos";exit 1 }
git clone "$REPO_STATIC" || {echo "Fallo al clonar el repositorio del contenido estático";exit 1 }

#Crear perfil de minikube con el cluster
minikube start --profile=$MINIKUBE_PROFILE||{echo "Error iniciando MINIKUBE";exit 1 }
minikube profile $MINIKUBE_PROFILE
minikube addons enable metrics-server --profile=$MINIKUBE_PROFILE

#Nos posicionames en la carpeta donde están los manifiestos y los aplicamos 
cd "$HOME"/minik-static-web/deploymentYaml/manifiestos
kubectl apply -f namespace.yaml
kubectl apply -f pvc/pv.yaml
kubectl apply -f pvc/pvc.yaml
kubectl apply -f deployment/nginx-deployment.yaml
kubectl apply -f service/nginx-service.yaml

#Montamos la carpeta con el contenido estático en el volumen persistente (comando en segundo plano) 
nohup minikube mount "$HOME"/minik-static-web/static-website:/mnt/data/web-content &> /dev/null &
sleep 2
#Reiniciamos el deployment para el nginx ahora pueda ver los archivos que aparecieron en el volumen persistente
kubectl rollout restart deployment nginx -n web-site
sleep 2
minikube service nginx-service -n web-site --url
