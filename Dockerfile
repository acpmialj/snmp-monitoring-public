FROM alpine
RUN apk add --update net-snmp
RUN apk add --update net-snmp-tools
COPY snmpd.conf /etc/snmp
EXPOSE 161/udp
CMD ["snmpd","-f"]
