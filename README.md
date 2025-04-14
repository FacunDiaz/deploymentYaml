# deploymentYaml
Manifiestos yaml

Manual de Despliegue de un Cluster en Minikube

Objetivos: 
Desplegar un cluster de minikube, incluyendo: 
-Clonar un repositorio git 
-Crear un cluster en Minikube
-Agregar una extensión de un servidor de métricas para ver los recursos consumidos por los pods 
-Despliegue de manifiestos YAML para la creación de un namespace, un deployment, volúmen persistente y un service.
-Llevar el contenido estático de la página web y montarlo en un volumen

Requisitos Previos
Para crear un cluster de Minikube deberá tener instaladas las siguientes herramientas:  
-Kubectl 
-Minikube 
-virtualización(docker, virtualbox, otro) 

Descripción de procesos: 

En primero lugar, debemos crear un directorio en el cual vamos a almacenar dos herramientas esenciales: 
-Manifiestos YAML de despliegue 
-Contenido estático de la página web
Para ello se debe ejecutar el siguiente comando: 
mkdir Webpage

Y dentro de la carpeta vamos a hacer un git clone de este repositorio para tener una copia local. Lo que va a generar un carpeta donde están todos los manifiestos yaml. 
Y también dentro de la carpeta webpage vamos a hacer un git clone del repositorio donde se encuentran los archivos de la página web estática. Para poder recibir y aplicar los cambios en el el repositorio remoto es importante que hayamos creado una conexión shh.

El directorio debería tener la siguiente estructura: 

mi-proyecto-k8s/                  # Carpeta raíz del proyecto
├── deploymentYaml/               # Repositorio Git clonado con manifiestos y documentación
│   ├── README.md                 # Manual o guía de despliegue
│   └── manifiestos/              # Manifiestos YAML organizados
│       ├── namespace.yaml
│       ├── pvc/
│       │   ├── pv.yaml
│       │   └── pvc.yaml
│       ├── deployment/
│       │   └── nginx-deployment.yaml
│       └── service/
│           └── nginx-service.yaml
│
└── static-site/                  # Carpeta local con el contenido estático del sitio web
    ├── index.html
    ├── estilos.css
    └── imagenes/
        └── logo.png

Una vez creado el directorio sobre el cual vamos a trabajar vamos a poder comenzar con la creación y configuración del cluster de Minikube.   

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

Este comando monta la carpeta de tu máquina local (en la ruta especificada) dentro del nodo de Minikube, en la ruta /mnt/data/web-content. Esto permite que los archivos estáticos de la página web estén disponibles para ser utilizados dentro del clúster de Kubernetes. Es importante mantener esta terminal abierta mientras el comando se esté ejecutando, ya que si cierras la terminal, se detendrá el montaje, y Kubernetes ya no podrá acceder a los archivos estáticos.
Gracias a ese montaje, el volumen persistente podrá obtener los datos de la página web estática y el contenedor nginx los va poder mostrar gracias a que esta asociado con ese pv. 


Una vez hecho esto es hora de aplicar los manifiestos yaml en nuestro cluster. Esto lo conseguiremos posicionandos en la carpeta manifiestos y ejecutando los siguientes comandos en la terminal de forma secuencial: 
kubectl apply -f namespace.yaml
kubectl apply -f pvc/pv.yaml
kubectl apply -f pvc/pvc.yaml
kubectl apply -f deployment/nginx-deployment.yaml
kubectl apply -f service/nginx-service.yaml

Cada uno de estos manifiestos realiza distintas acciones: 
    Crear el Namespace (namespace.yaml).
    Crear el Persistent Volume (pv.yaml) y el Persistent Volume Claim** (pvc.yaml).
    Desplegar el Deployment que contiene un pod con el contenedor NGINX para servir la página estática.
    Crear el Service (nginx-service.yaml) que expondrá el contenedor NGINX.

El Deployment configurado en nginx-deployment.yaml tiene un contenedor que funciona como un servidor web NGINX, y el PersistentVolumeClaim (pvc.yaml) se vincula al contenedor para que este sirva los archivos estáticos.

Una vez que aplicamos todos los manifiestos, ya podemos acceder al servido nginx a través del service que se encuentra en el cluster. 
Para ello debemos ejecutar el siguiente comando para acceder al servidor mediante el service: 
minikube service nginx -n web-site --url

Este comando nos va a retornar una url local a la que podremos acceder. Una vez ingresemos a la url podremos la página web. 
