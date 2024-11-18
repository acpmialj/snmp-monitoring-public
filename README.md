# Monitorización SNMP
Creamos una red snmp-net
```
docker network create snmp-net
```
## Creación de imagen con snmp-net
### Versión Alpine
* Dockerfile
* Requiere snmpd.conf (la configuración del agente SNMP)
Se construye con
```
docker build -f ./Dockerfile -t snmpdalp .
```
Se ejecuta con 
```
docker run --rm -d --network snmp-net --name snmpd snmpdalp
````
Accedemos a un shell en el contenedor con 
```
docker exec -it snmpd sh
```

### Versión Ubuntu
Similar a lo anterior, pero:
* Dockerfile_ubuntu
* Requiere snmpd.conf (la configuración del agente SNMP)

Se construye con
```
docker build -f ./Dockerfile_ubuntu -t snmpdub .
```
Se ejecuta con 
```
docker run --rm -d --network snmp-net --name snmpd snmpdub
````
Accedemos a un shell en el contenedor con 
```
docker exec -it snmpd bash
```
### snmpwalk
Ejecutamos en el shell del contenedor
```
snmpwalk -v2c -c public snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public -On snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public -Of snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public 192.168.0.1 1.3.6.1.2.1.1
```

## Uso de MIKROTIK-MIB
Es una MIB que no tiene pre-instalada. Por lo tanto, no se pueden ver los nombres como texto cuando se ejecuta snmpwalk, tan solo los números. Lo primero es importar la MIB. En el contenedor
```
cd /usr/share/snmp/mibs
wget https://raw.githubusercontent.com/librenms/librenms/refs/heads/master/mibs/mikrotik/MIKROTIK-MIB
```
Por omisión, los comandos de net-snmp miran solamente una colección pre-determinada de MIBs, entre las que no está la nueva. Para obligar a que se lea, se usa la opción "+m" de snmpwalk. En concreto:
``` 
snmpwalk -m +MIKROTIK-MIB -v2c -c public  192.168.0.1 .1.3.6.1.4.1.14988
```
