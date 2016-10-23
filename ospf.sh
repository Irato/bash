#!/bin/bash

#Identificacao de interfaces de rede
ls /sys/class/net > /tmp/if.txt     #Lista as interfaces e escreve no arquivo if.txt
numero=$(wc -l < /tmp/if.txt)       #Conta a quantidade de interfaces(linhas) do sistema 
interface=(inexistente inexistente inexistente inexistente)
#Se a quantidade de interfaces for menor ou igual a 4 escreve nas posicoes de 0 a 3 do vetor de interfaces
if [ $numero -le 4 ];then
contador=1
until [ $contador -eq $numero ];do
interface[$contador]=$(sed -n $contador'p' /tmp/if.txt) 
let contador+=1
done
fi

ospf_menu(){
	dialog --title "Configuracao do protocolo OSPF" \
		--menu "Escolha a configuracao:" 0 0 0 \
	"Redes diretamente conectadas ao dispositivo" "" \
	"Area ao que o dispositivo pertence" "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

		"Redes diretamente conectadas ao dispositivo") 
			ospf_menu
			;;
		"Area ao que o dispositivo pertence")
			ospf_menu
			;;
	esac


}

daemons(){
echo "
zebra=yes
bgpd=no
ospfd=yes
opsf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons
}

conf_ospf(){
	#Funcao de roteamento estatico IPV4

dialog --title "Configuracao automatica da topologia IPV4" \
       --menu "Escolha qual sera a sua maquina na topologia: " 0 0 0 \
        HostX "" \
        HostA "" \
        HostB "" \
        HostC "" \
        HostD "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in


        "HostX")
		ospf_menu
		daemons
		;;
        "HostA")
echo "
! -*- ospf -*-
!
! OSPFd sample configuration file
!
log stdout


hostname RoteadorD
password reverse
log file /var/log/quagga/zebra.log
log stdout
!
debug ospf event
debug ospf packet all
!
!
interface ${interface[1]}
!
interface lo
!
router ospf
!network 172.24.17.0/24 area 0.0.0.0
network 10.10.3.0/24 area 0.10.0.0
!
line vty
" > /etc/quagga/ospfd.conf

#########################################################
echo "
! -*- zebra -*-
!
! zebra sample configuration file
!
! $Id: zebra.conf.sample,v 1.1 2002/12/13 20:15:30 paul Exp $
hostname HostA
password reverse
enable password reverse
log file /var/log/quagga/zebra.log
!
debug zebra events
debug zebra packet
!
interface enp0s3
link-detect
ip address 10.10.3.2/24
ipv6 nd suppress-ra
!
interface lo
!
ip forwarding
!
line vty
!
" > /etc/quagga/zebra.conf

echo "
zebra=yes
bgpd=no
ospfd=yes
opsf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons
;;
        "HostB")

echo "
! -*- ospf -*-
!
! OSPFd sample configuration file
!
log stdout


hostname RoteadorB
password reverse
log file /var/log/quagga/zebra.log
log stdout
!
debug ospf event
debug ospf packet all
!
!
interface ${interface[1]}
interface ${interface[2]}
!
interface lo
!
router ospf
!network 172.24.17.0/24 area 0.0.0.0
network 10.10.2.0/24 area 0.10.0.0
network 10.10.3.0/24 area 0.10.0.0
!
line vty
" > /etc/quagga/ospfd.conf


echo "
! -*- zebra -*-
!
! zebra sample configuration file
!
hostname HostB
password reverse
enable password reverse
log file /var/log/quagga/zebra.log
!
debug zebra events
debug zebra packet
!
interface ${interface[1]}
link-detect
ip address 10.10.3.1/24
ipv6 nd suppress-ra
!
interface ${interface[2]}
link-detect
ip address 10.10.2.2/24
ipv6 nd suppress-ra
interface lo
!
ip forwarding
!
line vty
!
" > /etc/quagga/zebra.conf

echo "
zebra=yes
bgpd=no
ospfd=yes
opsf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons

	;;

        "HostC")


echo "
! -*- ospf -*-
!
! OSPFd sample configuration file
!
log stdout


hostname RoteadorC
password reverse
log file /var/log/quagga/zebra.log
log stdout
!
debug ospf event
debug ospf packet all
!
!
interface ${interface[1]}
interface ${interface[2]}
!
interface lo
!
router ospf
!network 172.24.17.0/24 area 0.0.0.0
network 10.10.1.0/24 area 0.0.0.0
network 10.10.2.0/24 area 0.10.0.0
!
line vty
" > /etc/quagga/ospfd.conf

echo "
! -*- zebra -*-
!
! zebra sample configuration file
!
hostname HostC
password reverse
enable password reverse
log file /var/log/quagga/zebra.log
!
debug zebra events
debug zebra packet
!
interface ${interface[1]}
link-detect
ip address 10.10.2.1/24
ipv6 nd suppress-ra
!
interface ${interface[2]}
link-detect
ip address 10.10.1.2/24
ipv6 nd suppress-ra
interface lo
!
ip forwarding
!
line vty
!
" > /etc/quagga/zebra.conf

echo "
zebra=yes
bgpd=no
ospfd=yes
opsf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons

;;

        "HostD")

dialog	--title "Forwarder IPv4" \
					--inputbox "Favor digitar o Forwarder IPv4 (ex.: 8.8.8.8)" 0 0 2>/tmp/endipv4.conf
					ipborda=$(cat /tmp/endipv4.conf)

echo "
! -*- ospf -*-
!
! OSPFd sample configuration file
!
log stdout
!
hostname RoteadorD
password reverse
log file /var/log/quagga/zebra.log
log stdout
!
debug ospf event
debug ospf packet all
!
!
interface ${interface[1]}
interface ${interface[2]}
!
interface lo
!
router ospf
!network 172.24.17.0/24 area 0.0.0.0
network 10.10.1.0/24 area 0.0.0.0
network $ipborda area 0.0.0.0
!
line vty
" > /etc/quagga/ospfd.conf

echo "
! -*- zebra -*-
!
! zebra sample configuration file
!
hostname RouterD
password zebra
enable password zebra
!
debug zebra events
debug zebra packet
!
interface ${interface[2]}
link-detect
ipv6 nd suppress-ra
!
interface ${interface[1]}
link-detect
ip address 10.10.1.1/24
ipv6 nd suppress-ra
! Static default route sample.
!

!
interface lo
link-detect
ip address 65.0.0.1/32
" > /etc/quagga/zebra.conf

echo "
zebra=yes
bgpd=no
ospfd=yes
opsf6d=no
ripd=no
ripngd=no
isisd=no
" > /etc/quagga/daemons
        
	;;
	"VOLTAR")
		conf_ospf
	;;

	*)
	echo "Opcao Errada"

	;;
	
        esac
}

conf_ospf 
