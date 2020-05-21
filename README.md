#Práctica Agile SysAdmin
Práctica final del módulo denominado "sysadmin" del 2º Bootcamp DevOps de Keepcoding 


#Pre-requisitos
La práctica se ha desarrollado sobre un PC con las siguientes características en lo que a software se refiere

Software: 
- S.O. Ms-Windows 10 Pro (versión 1909) 
- Virtual Box 6.1.2
- Vagrant 2.2.7

Hardware:
- Mínimo 8 GBytes de RAM, con todas las máquinas virtuales levantadas la memoria utilizada en mi equipo se queda 
por debajo de esa cifra (en mi caso tengo 16 GBytes).


#Instalación
Una vez clonado el repositorio de git en local se dispone de los script de shell: 

   up.cmd  
   halt.cmd  
   destroy.cmd
   
que realizan las acciones homónimas de Vagrant sobre cada uno de los directorios del proyecto. 
Para arrancar el proyecto se ejecutará en una ventana de comandos, la shellscript "up.cmd".


#Descripcion de la arquitectura.
El proyecto se ha repartido entre 3 máquinas virtuales aprovionadas mediante scripts de Vagrant.
Las máquinas son las siguientes:

(1) eshost 
Contiene las partes del Stack ELK: LogStash, ElasticSearch
Es la máquina virtual que más memoria necesita siendo configurada con 4GBytes de RAM, pese a ello y con poca carga de logs,
la consola de ElasticSearch la muestra en amarillo.


(2) kihost
Contiene la instalación de Kibana (la K del Stack ELK)
Es una máquina muy ligera con 512 MBytes de RAM.

(3) dbhost
Contiene una instalación de mySql junto con un script de ejecución en Cron que genera errores que se registran en el 
log "error.log".
Mediante el uso de un agente filebeat se envían las escrituras al log de errores a "eshost" para que la información sea 
procesada por LogStash. LogStash la enviará a ElasticSearch.

Elegí el log de errores por ser una tarea de especial interés profesional para mí.


#Detalle del modelo de red elegido

No he sido capaz de centralizar la gestión de los discos en el script comun.sh 
No he sido capaz de echar a andar Vector + Co-Pilot 





