#ServicioWeb 1 - Ingles
##APACHE DOCKER AWS-EC2
Primero se debe tener la instancia EC2 creada en AmazonWebServices y tener la key.pem en un lugar al que se pueda acceder facil, ademas la instancia en ec2 debe tener configurado el puerto 80 http para cualquier direccion ip entrante.

Acceder por **ssh** a la instancia de AWS con el siguiente comando
```
$ssh -i /path/key.pem ec2-user@dns.domain
```
Por ejemplo, suponiendo que estemos ubicados en el mismo directorio del key.pem.
El usuario que se debe usar debe ser **ec2-user**, de lo contrario, negara el acceso por ssh.
```
$ssh -i telematica.pem ec2-user@ec2-3-87-176-221.compute-1.amazonaws.com
```
Luego de acceder correctamente a la instancia debemos instalar docker.
```
$sudo amazon-linux-extras install docker
```
Verificamos que haya instalado correctamente
```
#Docker version
$docker --v
#Docker info
$docker info
```
Damos permisos de usuario a *ec2-user* e iniciamos el servicio de docker
```
#Permisos
$sudo usermod -a -G docker ec2-user
#Empezar el servicio
$sudo service docker start
```

Crearemos una carpeta para nuestro contenedor del webService2 y accedemos al directorio
```
$ mkdir webapp1en
$ cd webapp1en
```
Creamos un Dockerfile para crear la configuracion de nuestra imagen
```
/webapp1en$ touch Dockerfile
```
Dentro de este archivo se establecera la configuracion que permitira que el web service de apache se ejecute. Este contenedor correra el SO Ubuntu. Se debe usar editor de texto de preferencia(nano, emacs, vi, vim).
```
FROM ubuntu:16.04
#instalar dependencias
RUN apt-get update

#Instalar apache e indicar cual sera el index.html de la pagina inicial
RUN apt-get -y install apache2
#El archivo index.html esta dentro del mismo directorio webapp
COPY index.html /var/www/html/
#Ademas copiamos el index.js en la misma carpeta, el index.js realizara la conexion a la base de datos
COPY index.js /var/www/html/

#Configurar apache
RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh
RUN echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh
RUN echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh
RUN echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
RUN chmod 755 /root/run_apache.sh

#Exponemos el puerto 80
EXPOSE 80

CDM /root/run_apache.sh

```

Guardamos el archivo y compilamos la imagen de docker con el nombre deseado, en este caso *app-en*
```
/webapp1en$ docker build -t app-en .
```
Luego creamos un contenedor con la imagen creada
```
#El puerto del servidor sera el 80, mapeando el 80 del docker (80:80)
/webapp1en$ docker run -t -i -p 80:80 app-en
```
El servicio empezara a correr en el puerto 80 de nuestra instancia de AWS(ojo debemos tener el puerto 80 activado en nuestra instancia con HTTP, de lo contrario no funcionara).
Podemos observar las imagenes y los contenedores actuales con el siguiente comando
```
#Para mostrar todas las imagenes
$ docker images
#Para mostrar todos los contenedores
$ docker ps -a
```
Se accede al DNS de la instancia de EC2 y se verifica que este funcionando el "Hello World"