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

Creación del Directorio de Trabajo: 

En primero lugar, debemos crear un directorio que contendra los siguiente: 
-Manifiestos YAML de despliegue 
-Contenido estático de la página web

Para ello se debe ejecutar el siguiente comando: 
mkdir minikube-static-web 

Luego, para posicionarnos dentro de la carpeta vamos a ejecutar: 
cd minikube-static-web 

Una vez dentro de la carpeta vamos a hacer un git clone a los dos repositorios donde estan los manifiestos y el contenido estático. Para ello vamos a ejecutar los siguientes comandos dentro la carpeta minikube-static-web:
git clone https://github.com/FacunDiaz/deploymentYaml.git
git clone https://github.com/FacunDiaz/static-website.git
Nota: Asegurate de haber configurado correctamente tu conexión SSH con GitHub para poder clonar ambos repositorios. Deberás completar el comando git clone con el nombre de usuario que este asociado con tu cuenta. 

El directorio debería tener la siguiente estructura: 

minikube-static-web/                  # Carpeta raíz del proyecto
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
└── static-website/                  # Carpeta local con el contenido estático del sitio web
    ├── index.html
    ├── assets/
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
Se debería mostrar: minikube profile was successfully set to deploy-web-site

Para comprobar que estemos en el contexto correcto vamos a ejecutar el siguiente comando: 
kubectl config current-context
Se debería mostrar algo como: minikube-deploy-web-site

Es necesario instalar un servidor de métricas para poder recopilar y supervisar los datos de rendimiento de las aplicaciones. Para hacerlo vamos a ejecutar el siguiente comando: 
minikube addons enable metrics-server --profile=deploy-web-site
Se debería obtener: The 'metrics-server' addon is enabled


Una vez hecho esto es hora de aplicar los manifiestos yaml en nuestro cluster. Esto lo conseguiremos posicionandos en la carpeta manifiestos en esta dirección minikube-static-web/deploymentYaml/manifiestos. Luego, se deben ejecutar los siguientes comandos en la terminal de forma secuencial: 
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

Antes de acceder a la web de forma local, es necesario montar un volumen persistente que tendra almacenados los archivos de nuestra página web estática. Esto lo conseguimos ejecutando el siguiente comando 
minikube mount <ruta a la carpeta con el contenido estático>:/mnt/data/web-content
NOTA: la ruta con el contenido debe ser completa como /home/facundou/minikube-static-web/static-website

Este comando monta la carpeta de tu máquina local (en la ruta especificada) dentro del nodo de Minikube, en la ruta /mnt/data/web-content. Esto permite que los archivos estáticos de la página web estén disponibles para ser utilizados dentro del clúster de Kubernetes. Es importante mantener esta terminal abierta mientras el comando se esté ejecutando, ya que si cierras la terminal, se detendrá el montaje, y Kubernetes ya no podrá acceder a los archivos estáticos.
Gracias a ese montaje, el volumen persistente podrá obtener los datos de la página web estática y el contenedor nginx los va poder mostrar gracias a que esta asociado con ese pv. 
Mientras ese comando se este ejecutando, los cambios que hagamos sobre el contenido estático tambien se van a pasar el cluster. Si el comando para de funcionar, la web no podrá mostrar el contenido. 

Importante:
Antes de acceder a la página web, es recomendable reiniciar el deployment para asegurarse de que el contenedor NGINX cargue correctamente los archivos estáticos desde el volumen persistente.
Esto se debe a que el contenido montado con minikube mount puede no estar disponible inmediatamente cuando el contenedor se inicia por primera vez.
Para reiniciar el deployment, ejecuta el siguiente comando:
kubectl rollout restart deployment nginx -n web-site

Una vez que aplicamos todos los manifiestos y montamos la carpeta con el contenido estático en el volumen persistente, ya podemos acceder al servido nginx a través del service que se encuentra en el cluster. 
Para ello debemos ejecutar el siguiente comando para acceder al servidor mediante el service: 
minikube service nginx-service -n web-site --url

Este comando nos va a retornar una url local a la que podremos acceder. Una vez ingresemos a la url podremos ver la página web. 
