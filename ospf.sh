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

rede=( - - - - - )
area=( - - - - - )
id= "-"

mp_ospf(){
	dialog --title "Configuracao de protocolo OSPF" \
			--menu "Escolha o protocolo IP para configuracao OSPF" 0 0 0 \
			"Protocolo IPv4" "" \
			"Protocolo IPv6" '' 2>/tmp/opcao
	        opt=$(cat /tmp/opcao)
			case $opt in

				"Protocolo IPv4")
				rede=( - - - - - )
				area=( - - - - - )
				id=( - - - - - )
				ospf_menu 4	
					;;
					"Protocolo IPv6") 
					rede=( - - - - - )
					area=( - - - - - )
					id=( - - - - - )
					ospf_menu 6
						;;
				*)
					echo "fim de script"
					;;
			esac
}

ospf_menu(){

	dialog --title "Configuracao do protocolo OSPF" \
		--menu "Escolha a configuracao:" 0 0 0 \
	"Redes diretamente conectadas" "" \
	"Area ao que o dispositivo pertence" "" \
	"Id do dispositivo" "" \
	"Configurar OSPF" "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

		"Redes diretamente conectadas")
		m_rede_ospf $1
			;;
		"Area ao que o dispositivo pertence")
		m_area_ospf $1
			;;
		"Id do dispositivo")
		m_id_ospfv6 $1
			;;
		"Configurar OSPF")
			if [ $1 -eq 4 ]; then
		conf_ospf
	else
		conf_ospfv6
			fi	
			;;
		"VOLTAR")
	    mp_ospf	
;;
		*)
echo "opção errada"
;;
	esac
}

m_id_ospfv6(){

			dialog --title "ID  do dispositivo}" \
				--backtitle "ID do dispositivo para configuracao do OSPF" \
				--inputbox " Exemplo de rede ID 0.0.0.1 " 0 0 2>/tmp/id
			id=$(cat /tmp/id)

	ospf_menu $1
}

conf_ospf(){
daemons 4
nome=$(hostname)

echo "
! -*- ospf -*-
!
log stdout
!
hostname $nome
password admin
log file /var/log/quagga/zebra.log
log stdout
!
debug ospf event
debug ospf packet all
!
interface lo
!
" > /etc/quagga/ospfd.conf

contador=1
until [ $contador -gt $numero ];do
	if [ "${rede[$contador]}" == "-" ] || [ "${rede[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "!
interface ${interface[$contador]}
!
router ospf
network ${rede[$contador]} area ${area[$contador]}" >> /etc/quagga/ospfd.conf
    fi
let contador+=1
done

}

conf_ospfv6(){
daemons 6
nome=$(hostname)

echo "
!
hostname $nome
password admin
log stdout
service advanced-vty
!
debug ospf6 neighbor state
!
interface lo0
ipv6 ospf6 cost 1
ipv6 ospf6 hello-interval 10
ipv6 ospf6 dead-interval 40
ipv6 ospf6 retransmit-interval 5
ipv6 ospf6 priority 1
ipv6 ospf6 transmit-delay 1
ipv6 ospf6 instance-id 0
!
" > /etc/quagga/ospf6d.conf

contador=1
until [ $contador -gt $numero ];do
	if [ "${rede[$contador]}" == "-" ] || [ "${rede[$contador]}" == "rede local ou inexistente" ];then
    echo 1 
	else
echo "!
interface ${interface[$contador]}
!
router ospf6
router-id ${id[$contador]}
redistribute static
redistribute connected
area  ${area[$contador]} range ${rede[$contador]}
interface ${interface[$contador]} area ${area[$contador]}
access-list access4 permit 127.0.0.1/32
!" >> /etc/quagga/ospf6d.conf
    fi
let contador+=1
done

echo "!
ipv6 access-list access6 permit 3ffe:501::/32
ipv6 access-list access6 permit 2001:200::/48
ipv6 access-list access6 permit ::1/128
!
ipv6 prefix-list test-prefix seq 1000 deny any
!
route-map static-ospf6 permit 10
match ipv6 address prefix-list test-prefix
set metric-type type-2
set metric 2000
!
line vty
access-class access4
ipv6 access-class access6
exec-timeout 0 0
!
" >> /etc/quagga/ospf6d.conf

}

rede_ospf(){


			if [ "${interface[$1]}" == "lo" ] || [ "${interface[$1]}" == "inexistente" ];then
			rede[$1]="rede local ou inexistente"	

			else
			dialog --title "Digite as redes diretamente conectadas a interface ${interface[$1]}" \
				--backtitle "Configuração OSPF " \
				--inputbox "Exemplo de rede 192.168.1.0/24 ou 2001:db8:1:1::/64" 0 0 2>/tmp/redes
			rede[$1]=$(cat /tmp/redes)
			fi
}
m_rede_ospf(){


		dialog --title "Configuração de redes OSPF" \
			--menu "Digite as redes diretamente conectadas as interfaces" 0 0 0 \
			"Rede diretamente conectada a interface ${interface[1]}" "${rede[1]}" \
			"Rede diretamente conectada a interface ${interface[2]}" "${rede[2]}" \
			"Rede diretamente conectada a interface ${interface[3]}" "${rede[3]}" \
			"Rede diretamente conectada a interface ${interface[4]}" "${rede[4]}" \
		        VOLTAR '' 2> /tmp/opcao
			opt=$(cat /tmp/opcao)
			case $opt in
			
			"Rede diretamente conectada a interface ${interface[1]}")
			rede_ospf 1
			m_rede_ospf $1
			;;
			"Rede diretamente conectada a interface ${interface[2]}")
			rede_ospf 2
			m_rede_ospf $1
			;;
			"Rede diretamente conectada a interface ${interface[3]}")
			rede_ospf 3
			m_rede_ospf $1
			;;
			"Rede diretamente conectada a interface ${interface[4]}")
			rede_ospf 4
			m_rede_ospf $1
			;;
		"VOLTAR")
	ospf_menu $1
;;
		*)
echo "opção errada"
;;

esac
}

area_ospf(){


			if [ "${interface[$1]}" == "lo" ] || [ "${interface[$1]}" == "inexistente" ];then
			area[$1]="rede local ou inexistente"	

			else
			dialog --title "Digite a area da interface ${interface[$1]}" \
				--backtitle "Configuração da area OSPF" \
				--inputbox "Exemplo de rede 0.0.0.0" 0 0 2>/tmp/area
			area[$1]=$(cat /tmp/area)
			fi

}

m_area_ospf(){


		dialog --title "Configuração de redes OSPF" \
			--menu "Digite a área OSPF onde estao conectadas as interfaces" 0 0 0 \
			"Area diretamente conectada a interface ${interface[1]}" "${area[1]}" \
			"Area diretamente conectada a interface ${interface[2]}" "${area[2]}" \
			"Area diretamente conectada a interface ${interface[3]}" "${area[3]}" \
			"Area diretamente conectada a interface ${interface[4]}" "${area[4]}" \
		        VOLTAR '' 2> /tmp/opcao
			opt=$(cat /tmp/opcao)
			case $opt in
			
				"Area diretamente conectada a interface ${interface[1]}")
			area_ospf 1
			m_area_ospf $1
			;;
				"Area diretamente conectada a interface ${interface[2]}")
			area_ospf 2
			m_area_ospf $1
			;;
			"Area diretamente conectada a interface ${interface[3]}")
			area_ospf 3
			m_area_ospf $1
			;;
			"Area diretamente conectada a interface ${interface[4]}")
			area_ospf 4
			m_area_ospf $1
			
;;
		"VOLTAR")
	ospf_menu $1
;;
		*)
echo "opção errada"
;;

esac
}

daemons(){

	if [ $1 -eq 6 ]; then
echo "
zebra=yes
bgpd=no
ospfd=no
ospf6d=yes
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons

else

echo "
zebra=yes
bgpd=no
ospfd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons

	fi
}

mp_ospf
