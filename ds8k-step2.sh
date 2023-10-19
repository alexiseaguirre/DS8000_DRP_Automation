#!/bin/bash
#Author: Alexis Aguirre
#Mail: ae.aguirre@hotmail.com
#Version: 1.0 

ds8kmtz="/opt/ibm/dscli/dscli2 -cfg /opt/ibm/dscli/profile/dscli.profile.XXXXXXX -user XXXXXXX -passwd XXXXXXXX"
ds8ksky="/opt/ibm/dscli/dscli2 -cfg /opt/ibm/dscli/profile/dscli.profile.XXXXXXX -user XXXXXXX -passwd XXXXXXXX"
rewwnsky="XXXXXXXXXXXXXXXX"
rewwnmtz="XXXXXXXXXXXXXXXX"

#En el mkpprcpath va de sky a mtz y los pasos estan en estado failed
function fase2 () {
    unique=$(cat /tmp/listaluns |cut -c 1-2 | sort -u| awk '{print $1}')
    cat /tmp/listaluns |cut -c 1-2 >> /tmp/comp1
        for a in $unique
            do
            mkpath[$i]=$(grep -iw -f /tmp/comp1 /tmp/XXXXXX_PPRCPATH |grep -w $a |awk '{print $5":"$6}')
            echo "mkpprcpath -dev IBM.2107-XXXXXXX -remotedev IBM.2107-XXXXXX -remotewwnn $rewwnmtz -srclss $a -tgtlss $a" ${mkpath[$i]}
            echo ""
            sleep 5s
         done
                  }
                   
                   
function fase3 () {
    declare -a failback=($(grep -i -f /tmp/listaluns /tmp/XXXXXX_PPRC |grep -i full| awk '{print $1}'))
    printf "%s %s %s %s %s %s %s %s %s %s\n" "${failback[@]}" > /tmp/ordenaluns_fase3

         echo "Realizando Failback SKY --> MTZ"
         cat /tmp/ordenaluns_fase3 |while read a
         do                  
         echo "$ds8ksky failback -dev IBM.2107-XXXXXXXX -remotedev IBM.2107-XXXXXXXX -type mmir $a" 
         echo ""
         sleep 20s
         done 
                   }
#Cantidad total de luns pprc leidas desde la lista servers
#Validaciones pprcpath y failback
completo=$(cat /tmp/listaluns |wc -l)
suspendestate=$(grep -i -f /tmp/listaluns /tmp/XXXXXXX_PPRCFASE2 |grep -i full |wc -l)

if [ "$suspendestate" -eq "$completo" ]; then
   echo ""
   echo "PPRCPATH Check Success! (Suspended state)"
   echo ""
   echo "Comenzando Fase 2 (Crear PPRCPATH DS8K)"
   echo ""
   fase2
   echo ""
   echo -e "\e[92m Fase 2 OK \e[0m"
   echo ""
   echo "Comenzando Fase 3 (Failback DS8K / Vuelta a Site)"
   echo ""
   fase3
   echo ""
   echo -e "\e[92m Fase 3 OK --- DRP Complete ! \e[0m"
   echo ""
  exit   
   
else
   echo ""
   echo "PPRCPATH Check Failed"
   echo ""
   exit
fi   
