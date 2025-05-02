#!/bin/bash 
#

#-------------------------------------------
#Scrit de despliegue entorno de desarrollo en Minikube 
#Autor: Facundo Diaz
#Fecha: 02/05/25
#Descripción: 
#Este ejecutable despliega un entorno simple en minikube. Este entorno muestra una página con contenido estático almacenada en un volumen persistente. Esta página se muestra a través de un service que accede a un pod nginx. 
#USO:
#	./ejecutable.sh

REPO_MANIFIESTOS="https://github.com/<nombre_usuario>/deploymentYaml.git"
REPO_STATIC="https://github.com/<nombre_usuario>/static-website.git"


cd $HOME
mkdir minikube-static-web 
cd minikube-static-web 

#verificar la instalación de git 

git clone $REPO_MANIFIESTOS
git clone $REPO_STATIC

function verificar_herramientas(){
	if ! command -v git &> /dev/null ; then 
		echo "Git no está instalado"
	fi
	if ! command -v kubectl &> /dev/null ; then
                echo "Git no está instalado"
        fi
	if ! command -v minikube &> /dev/null ; then
                echo "Git no está instalado"
        fi
}
verificar_herramientas 
#Crear perfil de minikube con el cluster
minikube start --profile=deploy-web-site
minikube profile deploy-web-site
minikube addons enable metrics-server --profile=deploy-web-site

#Nos posicionames en la carpeta donde están los manifiestos y los aplicamos 
cd minikube-static-web/deploymentYaml/manifiestos
kubectl apply -f namespace.yaml
kubectl apply -f pvc/pv.yaml
kubectl apply -f pvc/pvc.yaml
kubectl apply -f deployment/nginx-deployment.yaml
kubectl apply -f service/nginx-service.yaml
cd $HOME
minikube mount minikube-static-web/static-website:/mnt/data/web-content
#Reiniciamos el deployment para el nginx ahora pueda ver los archivos que aparecieron en el volumen persistente
kubectl rollout restart deployment nginx -n web-site

minikube service nginx-service -n web-site --url
