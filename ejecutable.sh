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
