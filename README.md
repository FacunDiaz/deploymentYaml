# deploymentYaml
Manifiestos yaml

Manual de Despliegue de un Cluster en Minikube

Objetivos: 
Aprender a desplegar un cluster de minikube, incluyendo: 
-Agregar una extensión de un servidor de métricas para ver los recursos consumidos por los pods 
-Crear un namespace en donde poner los pods
-Llevar el contenido estático de la página web y montarlo en un volumen
-Despliegue de manifiestos YAML para la creación de distintos objetos

Requisitos Previos
Para crear un cluster de Minikube deberá tener instaladas las siguientes herramientas:  
-Kubectl 
-Minikube 
-virtualización(docker, virtualbox, otro) 


El primer paso es ejecutar el siguiente comando para crear un cluster de minikube con el nombre "deploy-web-site": 
minikube start --profile=deploy-web-site
El último mensaje debería decir: 
Done! kubectl is now configured to use "deploy-web-site" cluster and "default" namespace by default  

Una vez creado, para ubicarnos dentro de ese cluster con kubectl, usamos el siguiente comando: 
minikube profile deploy-web-site
Se debería mostrar: 
 minikube profile was successfully set to deploy-web-site

Para comprobar que estemos en el contexto correcto vamos a ejecutar el siguiente comando: 
kubectl config current-context
Se debería mostrar algo como: 
minikube-deploy-web-site

Es necesario instalar un servidor de métricas para poder recopilar y supervisar los datos de rendimiento de las aplicaciones. Para hacerlo vamos a ejecutar el siguiente comando: 
minikube addons enable metrics-server --profile=deploy-web-site
Se debería obtener: 
The 'metrics-server' addon is enabled
 
Y por último, vamos a crear un namespace con el nombre "web-site" donde desplegaremos todos nuestros manifiestos yaml. Los namespaces nos permiten organizar recursos en grupos lógicos, lo que facilita la gestión de aplicaciones y clusteres. Para crearlo, vamos a ejecutar el siguiente comando:
kubectl create namespace web-site
Se debería mostrar algo como el siguiente mensaje: 
namespace/web-site created

Para ver la lista de todos los namespace de nuestro cluster podemos usar el comando: 
kubectl get ns 

Antes de aplicar los manifiestos de forma secuencial, es necesario montar un volumen persistente que tendra almacenados los archivos de nuestra página web estática. Esto lo conseguimos ejecutando el siguiente comando 
minikube mount <ruta a la carpeta con el contenido estático>:/mnt/data/web-content
Una vez montado nos debería aparecer un mensaje de que la operación fue exitosa, debemos mantener esa terminal abierta para que el proceso siga funcionando. 

Una vez hecho esto es hora de aplicar los manifiestos yaml en nuestro cluster. Esto lo conseguiremos posicionandos en la carpeta manifiestos y ejecutando los siguientes comandos en la terminal de forma secuencial: 
kubectl apply -f namespace.yaml
kubectl apply -f pvc/pv.yaml
kubectl apply -f pvc/pvc.yaml
kubectl apply -f deployment/nginx-deployment.yaml
kubectl apply -f service/ngix-service.yaml


