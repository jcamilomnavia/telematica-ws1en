FROM ubuntu:16.04
# Instalar dependencias
RUN apt-get update

# Instalar apache e indicar cual sera el index.html de la pagina inicial
RUN apt-get -y install apache2
# El archivo index.html esta dentro del mismo directorio webapp
COPY index.html /var/www/html/
# Ademas copiamos el index.js en la misma carpeta, el index.js realizara la conexion a la base de datos
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