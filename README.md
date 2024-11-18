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
### snmpwalk
Ejecutamos en el shell del contenedor
```
snmpwalk -v2c -c public snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public -On snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public -Of snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public 192.168.0.1 1.3.6.1.2.1.1
```
