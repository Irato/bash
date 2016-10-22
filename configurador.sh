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

#Conf manual

#Configuracao manual IPV4

function config_if(){
	dialog	--title "Configuracao Manual" \
		--menu "Escolha uma Interface" 0 0 0 \
	        "Endereçamento IPv4" "Configura interfaces de rede com IPv4" \
	        "Endereçamento IPv6" "Configura interfaces de rede com IPv6" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		case $opt in
		"Endereçamento IPv4")
			config_if4
		;;

		"Endereçamento IPv6")
			config_if6
		;;

		"VOLTAR")
		voltar
		;;

		esac
		}
function config_if4(){
	dialog	--title "Configuracao Manual" \
		--menu "Escolha uma Interface" 0 0 0 \
	        ${interface[1]} "Interface de rede 1" \
	        ${interface[2]} "Interface de rede 2" \
	        ${interface[3]} "Interface de rede 3" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		
		case $opt in

			${interface[1]})
				dialog	--title "Config ${interface[1]}" \
					--inputbox "Favor Digitar um Endereco IP" 0 0 2>/tmp/eth1.conf
					sudo ip addr flush dev ${interface[1]}
					sudo ip link set ${interface[1]} up 
					ip=$(cat /tmp/eth1.conf)
					sudo ip addr add $ip dev ${interface[1]}  
				        sudo ip addr show dev ${interface[1]} >/tmp/eth1.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth1.log 22 70
				;;

			${interface[2]})
				dialog	--title "Config ${interface[2]}" \
					--inputbox "Favor Digitar um Endereco IP" 0 0 2>/tmp/eth2.conf
					sudo ip addr flush dev ${interface[2]}
					sudo ip link set ${interface[2]} up 
					ip=$(cat /tmp/eth2.conf)
					sudo ip addr add $ip dev {$interface[2]}  
				        sudo ip addr show dev ${interface[2]} >/tmp/eth2.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth2.log 22 70
				;;

			${interface[3]})
				dialog	--title "Config ${interface[3]}" \
					--inputbox "Favor Digitar um Endereco IP" 0 0 2>/tmp/eth3.conf
					sudo ip addr flush dev ${interface[3]}
					sudo ip link set ${interface[3]} up 
					ip=$(cat /tmp/eth3.conf)
					sudo ip addr add $ip dev {$interface[3]}  
				        sudo ip link show dev ${interface[3]} >/tmp/eth3.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth3.log 22 70
				;;
			"VOLTAR")
		        config_if	
				;;

			*)
				echo "Opcao Errada"
				;;
			esac
}



#Configuracao manual IPV6

function config_if6(){
	dialog	--title "Configuracao Manual IPv6" \
		--menu "Escolha uma Interface" 0 0 0 \
	        ${interface[1]} "Interface de rede 1" \
	        ${interface[2]} "Interface de rede 2" \
	        ${interface[3]} "Interface de rede 3" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		
		case $opt in

			${interface[1]})
				dialog	--title "Config ${interface[1]}" \
					--inputbox "Favor Digitar um Endereco IP" 0 0 2>/tmp/eth1.conf
					sudo ip addr flush dev ${interface[1]}
					sudo ip link set ${interface[1]} up 
					ip=$(cat /tmp/eth1.conf)
					sudo ip -6 addr add $ip  dev ${interface[1]}  
				    sudo ip -6 addr show dev ${interface[1]} >/tmp/eth1.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth1.log 22 70
				;;

			${interface[2]})
				dialog	--title "Config ${interface[2]}" \
					--inputbox "Favor Digitar um Endereco IP" 0 0 2>/tmp/eth2.conf
					sudo ip addr flush dev ${interface[2]}
					sudo ip link set ${interface[2]} up 
					ip=$(cat /tmp/eth2.conf)
					sudo ip -6 addr add $ip dev {$interface[2]}  
				        sudo ip -6 addr show dev ${interface[2]} >/tmp/eth2.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth2.log 22 70
				;;

			${interface[3]})
				dialog	--title "Config ${interface[3]}" \
					--inputbox "Favor Digitar um Endereco IP" 0 0 2>/tmp/eth3.conf
					sudo ip addr flush dev ${interface[3]}
					sudo ip link set ${interface[3]} up 
					ip=$(cat /tmp/eth3.conf)
					sudo ip -6 addr add $ip dev {$interface[3]}  
				        sudo ip -6 link show dev ${interface[3]} >/tmp/eth3.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth3.log 22 70
				;;
			"VOLTAR")
				config_if	
				;;

			*)
				echo "Opcao Errada"
				;;
		esac
	}

#Funcoes de configuracao automatica
function conf_automatica(){

dialog --title "Configuração automatica do experimento" \
       --menu "Escolha a versao de enderecamento IP " 0 0 0 \
    	IPV4 "Topologia com enderecos  IPV4" \
    	OSPF "Topologia com enderecos  IPV4" \
	ROTAS_IPV4 "Topologia com enderecos  IPV4" \
	IPV6 "Topologia com enderecos  IPV6" \
	ROTAS_IPV6 "Topologia com enderecos  IPV6" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

	  "IPV4")
	automatica_ipv4
        ;;

	  "OSPF")
	conf_ospf	
        ;;

	"ROTAS_IPV4")
	rota_estatica_ipv4
        ;;
	"IPV6")
	automatica_ipv6
        ;;

	"ROTAS_IPV6")
	rota_estatica_ipv6
        ;;

	"VOLTAR")
	voltar
	;;

	*)
	echo "Opcao Errada"
	;;
	
	esac


} #fim da funcao automatica

#Funcao ipv4
function automatica_ipv4(){
dialog --title "Configuracao automatica da topologia IPV4" \
       --menu "Escolha qual sera a sua maquina na topologia: " 0 0 0 \
        HostA "" \
        HostB "" \
        HostC "" \
        HostD "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

        "HostA")
	sudo ip addr flush dev ${interface[1]}
	sudo ip link set ${interface[1]} up 
	sudo ip addr add 10.10.3.2/24 dev ${interface[1]}  
        sudo ip addr show dev ${interface[1]} >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv4

	;;

        "HostB")
	sudo ip addr flush dev ${interface[1]}
	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[1]} up 
	sudo ip link set ${interface[2]} up 
	sudo ip addr add 10.10.3.1/24 dev ${interface[1]}  
	sudo ip addr add 10.10.2.2/24 dev ${interface[2]}  
        sudo ip addr show >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host B" \
               	--textbox /tmp/eth1.log 22 70
        automatica_ipv4
	;;


        "HostC")
	sudo ip addr flush dev ${interface[1]}
	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[1]} up 
	sudo ip link set ${interface[2]} up 
	sudo ip addr add 10.10.2.1/24 dev ${interface[1]}  
	sudo ip addr add 10.10.1.2/24 dev ${interface[2]}  
        sudo ip addr show >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host C" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv4
;;

        "HostD")
	sudo ip addr flush dev ${interface[1]}
	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[1]} up 
	sudo ip link set ${interface[2]} up 
	sudo dhclient ${interface[2]}
	sudo ip addr add 10.10.1.1/24 dev ${interface[1]}  
        sudo ip addr show >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host D" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv4
;;
	"VOLTAR")
	voltar
	;;

	*)
	echo "Opcao Errada"

	;;
	
        esac
}


#Funcao de roteamento estatico IPV4
function rota_estatica_ipv4(){
dialog --title "Configuracao automatica da topologia IPV4" \
       --menu "Escolha qual sera a sua maquina na topologia: " 0 0 0 \
        HostA "" \
        HostB "" \
        HostC "" \
        HostD "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in


        "HostA")
	sudo route add default gw 10.10.3.1 dev ${interface[1]}
        route > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv4	

	;;

        "HostB")
        sudo route add -net 10.10.1.0 netmask 255.255.255.0 dev ${interface[2]}
        route > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host B" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv4	

	;;

        "HostC")
        sudo route add -net 10.10.3.0 netmask 255.255.255.0 dev ${interface[1]}
	dialog	--backtitle "Resultado Configuracao.. Host C" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv4	

	;;

        "HostD")

        sudo route add -net 10.10.3.0 netmask 255.255.255.0 dev ${interface[1]}
        sudo route add -net 10.10.2.0 netmask 255.255.255.0 dev ${interface[1]}
	dialog	--backtitle "Resultado Configuracao.. Host D" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv4	

	;;
	"VOLTAR")
	voltar
	;;

	*)
	echo "Opcao Errada"

	;;
	
        esac
}

#Funcao ipv6
function automatica_ipv6(){
dialog --title "Configuracao automatica da topologia IPV6" \
       --menu "Escolha qual sera a sua maquina na topologia: " 0 0 0 \
        HostH "" \
        HostG "" \
        HostF "" \
        HostE "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

        "HostH")
	sudo ip addr flush dev ${interface[1]}
	sudo ip link set ${interface[1]} up 
	sudo ip -6 addr add 2001:db8:3::2/64  dev ${interface[1]}  
        sudo ip addr show dev ${interface[1]} >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host E" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv6

	;;

        "HostG")
	sudo ip addr flush dev ${interface[1]}
	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[1]} up 
	sudo ip link set ${interface[2]} up 
	sudo ip -6 addr add 2001:db8:3::1/64 dev ${interface[1]}  
	sudo ip -6 addr add 2001:db8:2::2/64 dev ${interface[2]}  
        sudo ip addr show >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host F" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv6
	;;


        "HostF")

	sudo ip addr flush dev ${interface[1]}
	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[1]} up 
	sudo ip link set ${interface[2]} up 
	sudo ip -6 addr add 2001:db8:2::1/64 dev ${interface[1]}  
	sudo ip -6 addr add 2001:db8:1::2/64 dev ${interface[2]}  
        sudo ip addr show >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host G" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv6
;;

        "HostE")
	sudo ip addr flush dev ${interface[1]}
	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[1]} up 
	sudo ip link set ${interface[2]} up 
	sudo dhclient ${interface[2]}
	sudo ip -6 addr add 2001:db8:1::1/64 dev ${interface[1]}  
        sudo ip addr show >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host H" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv6
;;
	"VOLTAR")
	voltar
	;;

	*)
	echo "Opcao Errada"

	;;
	
        esac
}


#Funcao de roteamento estatico IPV6
function rota_estatica_ipv6(){
dialog --title "Configuracao automatica da topologia IPV6" \
       --menu "Escolha qual sera a sua maquina na topologia: " 0 0 0 \
        HostH "" \
        HostG "" \
        HostF "" \
        HostE "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in


        "HostH")
	sudo route -A inet6 add default gw 2001:db8:3::1
        route -6 > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv6	

	;;

        "HostG")
	sudo route -A inet6 add 2001:db8:1::/64 dev ${interface[2]}
	sudo route -A inet6 add 2001:db8:1:ffff::/96 dev ${interface[2]}
        route -6 > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv6	


	;;

        "HostF")
	sudo route -A inet6 add 2001:db8:3::/64 dev ${interface[1]}
	sudo route -A inet6 add 2001:db8:1:ffff::/96 dev ${interface[2]}
        route -6 > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv6	

	;;

        "HostE")
	sudo route -A inet6 add 2001:db8:2::/64 dev ${interface[1]}
	sudo route -A inet6 add 2001:db8:3::/64 dev ${interface[1]}
        route -6 > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv6	

	;;
	"VOLTAR")
	voltar
	;;

	*)
	echo "Opcao Errada"

	;;
	
        esac
}

#Funcao do tayga-NAT64

function conf_NAT64(){

 dialog	--title "Configuracao Manual Tayga" \
		--menu "Insira os parametros de configuracao" 0 0 0 \
	        "Prefixo IPv6 de NAT64" "$PREFIX" \
	        "Pool de mapeamento IPv4" "$TAYGA_IPV4_POOL" \
	        "Endereço IPv4 do Tayga" "$TAYGA_IPV4ADDR" \
	        "Endereço da interface IPv4" "$ifacev4" \
	        "Endereço da interface IPv6" "$ifacev6" \
	        "Iniciar config. do NAT64" "" \
			"VOLTAR" '' 2> /tmp/opt
		opt=$(cat /tmp/opt)

case $opt in
			"Prefixo IPv6 de NAT64")
				dialog	--title "Prefixo NAT64" \
					--inputbox "Favor digitar o prefixo NAT64 com a máscara (/96) (ex.: 2001:db8:1:ffff::/96)" 0 0 2>/tmp/prefixnat64.conf
					PREFIX=$(cat /tmp/prefixnat64.conf)
					conf_NAT64
				;;

			"Pool de mapeamento IPv4")
				dialog	--title "Config. de pool NAT64" \
					--inputbox "Favor Digitar um Endereco IPv4 de rede com a máscara CIDR (ex.: 192.168.255.0/24)" 0 0 2>/tmp/poolnat64.conf
					 TAYGA_IPV4_POOL=$(cat /tmp/poolnat64.conf)
					conf_NAT64
				;;

			"Endereço IPv4 do Tayga")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor Digitar um Endereco IPv4 pertencente ao pool de endereços do NAT64 (ex.: 192.168.255.1)" 0 0 2>/tmp/ipv4nat64.conf
					TAYGA_IPV4ADDR=$(cat /tmp/ipv4nat64.conf)
					conf_NAT64
				;;

			"Endereço da interface IPv4")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv4 do roteador COM a máscara (ex.: 192.168.0.200/24)" 0 0 2>/tmp/ifacev4.conf
					ifacev4=$(cat /tmp/ifacev4.conf)
					echo "${ifacev4%???}" > /tmp/v4nomask
					ipv4nomask=$(cat /tmp/v4nomask)
					conf_NAT64
				;;

			"Endereço da interface IPv6")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv6 do roteador COM a máscara (ex.: 2001:db8:1::3/64)" 0 0 2>/tmp/ifacev6.conf
					ifacev6=$(cat /tmp/ifacev6.conf)
					echo "${ifacev6%???}" > /tmp/v6nomask
					ipv6nomask=$(cat /tmp/v6nomask)
					conf_NAT64
				;;

			"Iniciar config. do NAT64")
				dialog --yesno 'Deseja realizar SNAT para a rede externa?' 0 0
				doNAT=$?
				configIP
				configNAT64
				;;
			"VOLTAR")
				voltar
				;;
			esac
		}

 configIP(){

 	sysctl -w net.ipv6.conf.all.forwarding=1
	sysctl -w net.ipv4.ip_forward=1

 	# Interface IPv4 #####
 	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[2]} up 
	sudo ip addr add $ifacev4 dev ${interface[2]}

	# Interface IPv6 #####
	sudo ip addr flush dev ${interface[1]}
	sudo ip link set ${interface[1]} up 
	sudo ip -6 addr add $ifacev6 dev ${interface[1]}
 }


 configNAT64(){

	DIR_TAYGA=$(find /home -type d -name tayga-0.9.2)

	cd $DIR_TAYGA

	./configure && make && make install

	mkdir -p /var/db/tayga

	echo "tun-device nat64
		ipv4-addr $TAYGA_IPV4ADDR
		prefix $PREFIX
		dynamic-pool $TAYGA_IPV4_POOL
		data-dir /var/db/tayga" > /usr/local/etc/tayga.conf

	tayga --mktun
	ip link set nat64 up
	ip addr add $ifacev4 dev nat64 
	ip addr add $ifacev6 dev nat64   
	ip route add $PREFIX dev nat64
	ip route add  $TAYGA_IPV4_POOL dev nat64
	
	iptables -F 
	
	if [ $doNAT = 0 ]; then
		iptables -t nat -F 
		iptables -t nat -A POSTROUTING -s $TAYGA_IPV4_POOL -o ${interface[2]} -j SNAT --to $ipv4nomask
	fi
	
	iptables -A FORWARD -i ${interface[2]} -o nat64 -m state --state RELATED,ESTABLISHED -j ACCEPT 
	iptables -A FORWARD -i nat64 -o ${interface[2]} -j ACCEPT
	tayga

	echo -e "\n************* Configuração NAT64 completa! *******************\n"
}

 PREFIX="-"
 TAYGA_IPV4ADDR="-"
 TAYGA_IPV4_POOL="-"
 ifacev6="-"
 ifacev4="-"


################### CONFIGURAÇÃO SERVIDOR DNS64 ##########################

function conf_DNS64(){

dialog	--title "Configuração DNS64" \
		--menu "Insira os parametros de configuração" 0 0 0 \
	        "Forwarder IPv4" "$v4Forwarder" \
 	        "Forwarder IPv6" "$v6Forwarder" \
 	        "Prefixo do NAT64" "$PREFIXNAT64" \
 	        "Endereço da interface IPv4" "$ifacev4" \
 	        "Rede IPv6 permitida" "$v6network" \
 	        "Iniciar config. do DNS64" "" \
			"VOLTAR" '' 2> /tmp/opt 
		opt=$(cat /tmp/opt)


	case $opt in
			"Forwarder IPv4")
				dialog	--title "Forwarder IPv4" \
					--inputbox "Favor digitar o Forwarder IPv4 (ex.: 8.8.8.8)" 0 0 2>/tmp/forwarderv4.conf
					v4Forwarder=$(cat /tmp/forwarderv4.conf)
			conf_DNS64		
				;;

			"Forwarder IPv6")
				dialog	--title "Forwarder IPv6" \
					--inputbox "Favor digitar o Forwarder IPv6 (ex.: 2001:4860:4860::8888)" 0 0 2>/tmp/forwarderv6.conf
					v6Forwarder=$(cat /tmp/forwarderv6.conf)
					conf_DNS64
				;;

			"Prefixo do NAT64")
				dialog	--title "Config.  de prefixo NAT64" \
					--inputbox "Favor digitar o prefixo utilizado pelo NAT64 (ex.: 2001:db8:1:ffff::/96)" 0 0 2>/tmp/prefixnat64.conf
					PREFIXNAT64=$(cat /tmp/prefixnat64.conf)
					conf_DNS64
				;;

			"Rede IPv6 permitida")
				dialog	--title "Config.  de prefixo NAT64" \
					--inputbox "Favor digitar o prefixo utilizado pelo NAT64 (ex.: 2001:db8::/64)" 0 0 2>/tmp/v6network.conf
					v6network=$(cat /tmp/v6network.conf)
					conf_DNS64
				;;

			"Endereço da interface IPv4")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv4 do roteador COM a máscara (ex.: 192.168.0.200/24)" 0 0 2>/tmp/ifacev4.conf
					ifacev4=$(cat /tmp/ifacev4.conf)
					echo "${ifacev4%???}" > /tmp/v4nomask
					ipv4nomask=$(cat /tmp/v4nomask)
					conf_DNS64
				;;

			"Iniciar config. do DNS64")
				dialog --yesno 'Deseja realizar autenticação DNSSEC?' 0 0
				doDNSSEC=$?
				dialog --yesno 'Deseja que o DNS responda autoritativamente ao receber respostas NXDOMAIN?' 0 0
				doAUTORITATIVO=$?
				dialog --yesno 'Deseja que o DNS64 retorne apenas endereços IPv4? (prefixo + ipv4)' 0 0
				doEXCLUDE=$?
				write_config
				;;
			"VOLTAR")
				voltar
				;;
			esac
		}
write_config(){

	if [ $doDNSSEC = 0 ]; then
		
		doDNSSECyn="yes"
	
	else

		doDNSSECyn="no"

	fi

	if [ $doAUTORITATIVO = 0 ]; then
		
		doAUTORITATIVOyn="yes"
	
	else

		doAUTORITATIVOyn="no"

	fi

	if [ $doEXCLUDE = 0 ]; then
		
		doEXCLUDEyn="exlude { any; };"
	
	else

		doEXCLUDEyn="#exlude { any; };"

	fi

	echo  "options{
	
	directory \"var/cache/bind\"
	
		forwarders {
			
			$v4Forwarder ;
			$v6Forwarder ;

		};


	dnssec-validation $doDNSSECyn ;

	auth-nxdomain $doAUTORITATIVOyn ;    
	
	listen-on-v6 { any; }; 
	
	allow-query { localnets; localhost; $v6network ; }; 
	
	allow-recursion { localnets; localhost; $v6network ; }; 
	
	dns64 $PREFIXNAT64 { 
	
	clients { any; }; 
	$doEXCLUDEyn

	};
	}" > /etc/bind/named.conf.options
	

	echo -e "\n\nFIM!!!!!!!!!\n\n"
}

v4Forwarder="-"
v6Forwarder="-"
PREFIXNAT64="-"
ifacev4="-"
ifacev6="-"
v6network="-"

##################################################################OSPF IP4##################################################
conf_ospf(){
	#Funcao de roteamento estatico IPV4

dialog --title "Configuracao automatica da topologia IPV4" \
       --menu "Escolha qual sera a sua maquina na topologia: " 0 0 0 \
        HostA "" \
        HostB "" \
        HostC "" \
        HostD "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in


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
	voltar
	;;

	*)
	echo "Opcao Errada"

	;;
	
        esac
}

#Criacao das  funcoes
function voltar(){
dialog	--title "Tela de Controle" \
	--menu "Escolha uma opcao:" 0 0 0 \
	IP "Configuracao  Manual" \
    "Experimento" "Configuracao automatica dos hosts do experimento NAT64/DNS64" \
	NAT64 "Configuração do tayga no host D" \
	"DNS64" "Configuração do BIND no host D"  2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"IP")
			config_if
			;;
		"Experimento")
			conf_automatica	
			;;
		"NAT64")
			conf_NAT64
			;;
		"DNS64")
			conf_DNS64
			;;
		esac
}

#Menu Principal 
dialog	--title "Tela de Controle" \
	--menu "Escolha uma opcao:" 0 0 0 \
	IP "Configuracao  Manual" \
    "Experimento" "Configuracao automatica dos hosts do experimento NAT64/DNS64" \
	"NAT64" "Configuração do tayga no host D" \
	"DNS64" "Configuração do BIND no host D"  2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"IP")
			config_if
			;;
		"Experimento")
			conf_automatica	
			;;
		"NAT64")
			conf_NAT64
			;;
		"DNS64")
			conf_DNS64
			;;
		esac
