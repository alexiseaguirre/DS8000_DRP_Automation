#!/bin/bash

#Globales
ds8kmtz="/opt/ibm/dscli/dscli2 -cfg /opt/ibm/dscli/profile/dscli.profile.XXXXXX -user XXXXXXX -passwd XXXXXXXXXX"
ds8ksky="/opt/ibm/dscli/dscli2 -cfg /opt/ibm/dscli/profile/dscli.profile.XXXXXX -user XXXXXXX -passwd XXXXXXXXXX"

#Recolector de basura
rm -r /tmp/seleccion_volgrp && rm -r /tmp/listaluns

#Obtener lista de lss a freezar origen destino
function fase1 () {
    declare -a freeze=($(cat /tmp/listaluns |cut -c 1-2 | sort -u| awk '{print $1":"$1}'))
    declare -a failover=($(grep -i -f /tmp/listaluns /tmp/XXXXXX_PPRC |grep -i full| awk '{print $1}'))
    printf "%s %s %s %s %s %s %s %s %s %s\n" "${failover[@]}" > /tmp/ordenaluns
   
         echo "Realizando Freeze PPRC"         
         echo $ds8kmtz freezepprc -dev IBM.2107-XXXXXXX -remotedev IBM.2107-XXXXXX ${freeze[@]}
         echo ""
         sleep 15s
    
         echo "Realizando Failover replicas DS8870"
         cat /tmp/ordenaluns |while read a
         do                  
         echo "$ds8ksky failoverpprc -dev IBM.2107-XXXXXXX -remotedev IBM.2107-XXXXXXX -type mmir $a" 
         echo ""
         sleep 20s
         done  
                  }

#Obtener listado servidores y su volgrp
grep -i -f /home/alexis/Escritorio/listado_drp.dat /tmp/XXXXXXX_LSVOLGRP > /tmp/seleccion_volgrp

#Obtener la lista de todas las luns de los servidores del DRP
volgrp=$(cat /tmp/seleccion_volgrp |awk '{print $2}')
    for a in $volgrp
        do
          cat /tmp/XXXXXXX_LSFBVOL |grep -w $a |awk '{print $2}' >> /tmp/listaluns
      done

#Cantidad total de luns pprc leidas desde la lista servers
completo=$(cat /tmp/listaluns |wc -l)
estadofull=$(grep -i -f /tmp/listaluns /tmp/XXXXXXX_PPRC |grep -i full |wc -l)

#Condicional para inicar el DRP

if [ "$completo" -eq "$estadofull" ]; then
   echo ""
   echo "CONSISTENT PPRC Check Success!"
   echo ""
   echo "Comenzando Fase 1 (Freeze-Failover DS8K / Escritura SITE)"
   echo ""
   fase1
   echo -e "\e[92m Fase 1 OK \e[0m"
   echo ""
   exit

    else
        echo ""
        echo "CONSISTENT PPRC Check Failed exiting..."
        echo ""
        exit
fi



