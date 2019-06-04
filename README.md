# Servicios Web
Esta implementacion es un Servicio Web funcionando sobre *Apache* en un contenedor de *Docker* dentro de una instancia *EC2 de AWS*. Trabajo final de la materia Telematica de la *Universidad EAFIT*.
#### APACHE DOCKER AWS-EC2
Primero se debe tener la instancia EC2 creada en *Amazon Web Services* y tener la *key.pem* en un lugar al que se pueda acceder facil, ademas la instancia en EC2 debe tener configurado algun puerto abierto para acceder desde cualquier direccion ip entrante.

## Docker
### Instalar Docker
##### Ubuntu
```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] 
https://download.docker.com/linux/ubuntu$(lsb_release -cs) stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce
```
##### CentOS
```bash
$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ sudo yum install docker-ce
$ sudo systemctl start docker
$ sudo systemctl enable docker
$ sudo usermod -aG docker user1
$ sudo curl -L https://github.com/docker/compose/releases/download/1.24.0-rc1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```
##### Windows 
Tener en cuenta que Docker solo está disponible para Windows 10 64bit: Pro, Enterprise or Education.
[Docker Desktop para Windows](https://docs.docker.com/docker-for-windows/install/)

##### MacOS
[Docker Desktop para Mac](https://docs.docker.com/docker-for-mac/install/)

### Dockerizando
Creamos un nuevo archivo llamado *Dockerfile*, en este documento se usa para personalizar y configurar una plataforma de contenedores, es decir, aqui realizaremos las operaciones principales que correran en nuestra imagen de Docker.
```bash
FROM ubuntu:16.04
# Instalar dependencias
RUN apt-get update

# Instalar apache e indicar cual sera el index.html de la pagina inicial
RUN apt-get -y install apache2
# El archivo index.html esta dentro del mismo directorio webapp
COPY index.html /var/www/html/
# Ademas si existe un index.js, se copia en la misma carpeta
# COPY index.js /var/www/html/

# Configurar apache
RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh
RUN echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh
RUN echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh
RUN echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
RUN chmod 755 /root/run_apache.sh

# Exponemos el puerto 80
EXPOSE 80

CMD /root/run_apache.sh
```
Guardamos el archivo y ahora crearemos la imagen de Docker que luego sera usada en los contenedores
```bash
docker build -t webservice1 .
```
Luego creamos el contenedor que correra el servidor de la base de datos de mongo
```bash
# Mapeamos el servidor 80 del servidor en el 4000 de docker
#El puerto 4000 es el establecido en el app.js y dockerfile
docker run -i -t -p 80:80 webservice1
```
Una vez verifiquemos que funcione correctamente podemos hacer push a nuestra imagen. 
Primero detenemos el conetenedor que empezamos a correr con el comando anterior.
```bash
# Identificamos que contenedores estamos corriendo
$docker ps
```
Este comando nos retornara algo asi:
```bash
# Identificamos la variable variable NAMES
CONTAINER ID    IMAGE           COMMAND    CREATED          STATUS         PORTS          NAMES
4c01db0b339c    ubuntu:12.04    bash       17 seconds ago   Up 16 seconds  3300-3310/tcp  webapp
```
Una vez identificado el nombre, detenemos el contenedor
```bash
# Detenemos el contenedor
$ docker stop <NAME>
```
Asignarle un tag a la imagen para publicarla
```bash
$ docker tag <imageName> <username/repository:tag>
```
Por ejemplo:
```bash
$ docker tag webservice1 jcmarinn/repoec2:wsimage
```
Realizamos el push
```bash
$ docker push <username/repository:tag>
```
# Corriendo en AWS-EC2 Instance

Acceder por **ssh** a la instancia de AWS con el siguiente comando
```bash
$ ssh -i /path/key.pem ec2-user@dns.domain
```
Por ejemplo, suponiendo que estemos ubicados en el mismo directorio del key.pem.
El usuario que se debe usar debe ser **ec2-user**, de lo contrario, negara el acceso por ssh.
```bash
$ ssh -i telematica.pem ec2-user@ec2-3-85-175-225.compute-1.amazonaws.com
```
Luego de acceder correctamente a la instancia debemos instalar docker.
```bash
$ sudo amazon-linux-extras install docker
```
Verificamos que haya instalado correctamente
```bash
# Docker version
$ docker --v
# Docker info
$ docker info
```
Damos permisos de usuario a **ec2-user** e iniciamos el servicio de docker
```bash
# Permisos
$ sudo usermod -a -G docker ec2-user
# Empezar el servicio
$ sudo service docker start
```
Realizar el pull de la imagen a la que se le hizo push antes
```bash
docker pull <username/repository:tag>
```
Crear y correr el contenedor con nuestra base de datos
```bash
$ docker run -i -t -p 80:80 <username/repository:tag>
```
Ahora podremos acceder al DNS que nos ofrece AWS y encontraremos nuestro index.html corriendo (Hello World).