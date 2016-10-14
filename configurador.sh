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

#Configuracao manual IPV4

function config_if(){
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
		        	voltar
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
	ROTAS_IPV4 "Topologia com enderecos  IPV4" \
	IPV6 "Topologia com enderecos  IPV6" \
	ROTAS_IPV6 "Topologia com enderecos  IPV6" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

	"IPV4")
	automatica_ipv4
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
	sudo route add default gw 10.10.3.1/24 dev ${interface[1]}
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
        HostE "" \
        HostF "" \
        HostG "" \
        HostH "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in

        "HostE")
	sudo ip addr flush dev ${interface[1]}
	sudo ip link set ${interface[1]} up 
	sudo ip -6 addr add 2001:db8:3::2/64  dev ${interface[1]}  
        sudo ip addr show dev ${interface[1]} >/tmp/eth1.log
	dialog	--backtitle "Resultado Configuracao.. Host E" \
               	--textbox /tmp/eth1.log 22 70
	automatica_ipv6

	;;

        "HostF")
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


        "HostG")

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

        "HostH")
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
        HostE "" \
        HostF "" \
        HostG "" \
        HostH "" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in


        "HostE")
	sudo route -A inet6 add 2001:db8:2::/64 gw 2001:db8:3::1/64
	sudo route -A inet6 add 2001:db8:1::/64 gw 2001:db8:3::1/64
        route -6 > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv6	

	;;

        "HostF")
	sudo route -A inet6 add 2001:db8:1::/64 dev ${interface[2]}
        route -6 > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv6	


	;;

        "HostG")
	sudo route -A inet6 add 2001:db8:3::/64 dev ${interface[1]}

        route -6 > /tmp/route.log
	dialog	--backtitle "Resultado Configuracao.. Host A" \
               	--textbox /tmp/route.log 22 70
	rota_estatica_ipv6	

	;;

        "HostH")
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

#Criacao das Funcoes
function voltar(){
dialog	--title "Tela de Controle" \
	--menu "Escolhe uma opcao:" 0 0 0 \
	IP "Configuracao Manual" \
	E "Configuracao dos hosts do experimento NAT64/DNS64" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"IP")
			config_if
			;;
		"E")
			conf_automatica	
			;;
		"VOLTAR")
			voltar
			;;
		esac
}

#Menu Principal 
dialog	--title "Tela de Controle" \
	--menu "Escolhe uma opcao:" 0 0 0 \
	IP "Configuracao  Manual" \
        E "Configuracao dos hosts do experimento NAT64/DNS64" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"IP")
			config_if
			;;
		"E")
			conf_automatica	
			;;
		"VOLTAR")
			voltar
			;;
		esac

