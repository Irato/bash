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

ospf_menu(){
	dialog --title "Configuracao do protocolo OSPF" \
		--menu "Escolha a configuracao:" 0 0 0 \
	"Redes diretamente conectadas" "" \
	"Area ao que o dispositivo pertence" "" \
	"Configurar OSPF" "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

		"Redes diretamente conectadas")
		m_rede_ospf
			;;
		"Area ao que o dispositivo pertence")
		m_area_ospf
			;;
		"Configurar OSPF")
		conf_ospf
			;;
		"VOLTAR")
	    ospf_menu	
;;
		*)
echo "opção errada"
;;
	esac
}

conf_ospf(){
daemons
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

rede_ospf(){


			if [ "${interface[$1]}" == "lo" ] || [ "${interface[$1]}" == "inexistente" ];then
			rede[$1]="rede local ou inexistente"	

			else
			dialog --title "Digite as redes diretamente conectadas a interface ${interface[$1]}" \
				--backtitle "Configuração OSPF da rede IPV4" \
				--inputbox "Exemplo de rede 192.168.1.0/24" 0 0 2>/tmp/redes
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
			m_rede_ospf
			;;
			"Rede diretamente conectada a interface ${interface[2]}")
			rede_ospf 2
			m_rede_ospf
			;;
			"Rede diretamente conectada a interface ${interface[3]}")
			rede_ospf 3
			m_rede_ospf
			;;
			"Rede diretamente conectada a interface ${interface[4]}")
			rede_ospf 4
			m_rede_ospf
			
;;
		"VOLTAR")
	ospf_menu	
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
				--backtitle "Configuração da area OSPF da rede IPV4" \
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
			m_area_ospf
			;;
				"Area diretamente conectada a interface ${interface[2]}")
			area_ospf 2
			m_area_ospf
			;;
			"Area diretamente conectada a interface ${interface[3]}")
			area_ospf 3
			m_area_ospf
			;;
			"Area diretamente conectada a interface ${interface[4]}")
			area_ospf 4
			m_area_ospf
			
;;
		"VOLTAR")
	ospf_menu	
;;
		*)
echo "opção errada"
;;

esac
}

daemons(){
echo "
zebra=yes
bgpd=no
ospfd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons
}

ospf_menu
