#!/bin/bash

#Identificacao de interfaces de rede
ls /sys/class/net > /tmp/if.txt     #Lista as interfaces e escreve no arquivo if.txt
numero=$(wc -l < /tmp/if.txt)       #Conta a quantidade de interfaces(linhas) do sistema 
interface=(inexistente inexistente inexistente inexistente inexistente)
#Se a quantidade de interfaces for menor ou igual a 4 escreve nas posicoes de 0 a 3 do vetor de interfaces
if [ $numero -le 4 ];then
contador=1
until [ $contador -gt $numero ];do
interface[$contador]=$(sed -n $contador'p' /tmp/if.txt) 
let contador+=1
done
fi

zebra=( - - - - - )
flag= 4

inf_zebra(){


			if [ "${interface[$1]}" == "lo" ] || [ "${interface[$1]}" == "inexistente" ];then
			zebra[$1]="rede local ou inexistente"	

			else
			dialog --title "Digite o endereço IP da interface ${interface[$1]}" \
				--backtitle "Configuração da interface de rede IPV4" \
				--inputbox "Digite ENDERECO_IP/(CIDR)" 0 0 2>/tmp/zebra
			zebra[$1]=$(cat /tmp/zebra)
			fi
}
m_zebra(){


		dialog --title "Configuração de zebra" \
			--menu "Digite as endereço da interface de rede" 0 0 0 \
			"Endereço da interface ${interface[1]}" "${zebra[1]}" \
			"Endereço da interface ${interface[2]}" "${zebra[2]}" \
			"Endereço da interface ${interface[3]}" "${zebra[3]}" \
			"Endereço da interface ${interface[4]}" "${zebra[4]}" \
			"Configurar zebra" "" \
		        VOLTAR '' 2> /tmp/opcao
			opt=$(cat /tmp/opcao)
			case $opt in
			
			"Endereço da interface ${interface[1]}")
			inf_zebra 1
			m_zebra
			;;
		"Endereço da interface ${interface[2]}")
			inf_zebra 2
			m_zebra
			;;
		"Endereço da interface ${interface[3]}")
			inf_zebra 3
			m_zebra
			;;
		"Endereço da interface ${interface[4]}")
			inf_zebra 4
			m_zebra
;;
        "Configurar zebra")
			conf_zebra
	;;
		"VOLTAR")
			m_zebra
;;
		*)
echo "opção errada"
;;

esac
}

conf_zebra(){
daemons
nome=$(hostname)

echo "
! -*- zebra -*-
!
hostname $nome
password admin 
enable password admin
log file /var/log/quagga/zebra.log
!
debug zebra events
debug zebra packet
!
interface lo
!
!" > /etc/quagga/zebra.conf
if [ ${flag} -eq 4 ]; then
contador=1
until [ $contador -gt $numero ];do
	if [ "${zebra[$contador]}" == "-" ] || [ "${zebra[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "ip forwarding
!
interface ${interface[$contador]}
link-detect
ip address ${zebra[$contador]}
ipv6 nd suppress-ra
!" >> /etc/quagga/zebra.conf
    fi
let contador+=1
done

else
contador=1
until [ $contador -gt $numero ];do
	if [ "${zebra[$contador]}" == "-" ] || [ "${zebra[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "ipv6 forwarding
!
interface ${interface[$contador]}
link-detect
no ipv6 nd suppress-ra
ipv6 nd ra-interval 10
ipv6 address ${zebra[$contador]}
!" >> /etc/quagga/zebra.conf
    fi
let contador+=1
done
fi

}

mp_zebra(){
	dialog --title "Configuracao de  intefaces via zebra" \
			--menu "Escolha o protocolo IP para configuracao" 0 0 0 \
			"Protocolo IPv4" "" \
			"Protocolo IPv6" '' 2>/tmp/opcao
	        opt=$(cat /tmp/opcao)
			case $opt in

				"Protocolo IPv4")
					flag=4
					m_zebra
					;;
					"Protocolo IPv6") 
					flag=6
					m_zebra
						;;
				*)
					echo "fim de script"
					;;
			esac
}

mp_zebra
