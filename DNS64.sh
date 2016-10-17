  #!/bin/bash

################### CONFIGURAÇÃO SERVIDOR DNS64 ##########################


menu(){

dialog	--title "Configuração DNS64" \
		--menu "Insira os parametros de configuração" 0 0 0 \
	        "Forwarder IPv4" "$v4Forwarder" \
 	        "Forwarder IPv6" "$v6Forwarder" \
 	        "Prefixo do NAT64" "$PREFIXNAT64" \
 	        "Endereço da interface IPv4" "$ifacev4" \
 	        "Rede IPv6 permitida" "$v6network" \
			"Iniciar config. do DNS64" '' 2> /tmp/opt
		opt=$(cat /tmp/opt)


	case $opt in
			"Forwarder IPv4")
				dialog	--title "Forwarder IPv4" \
					--inputbox "Favor digitar o Forwarder IPv4 (ex.: 8.8.8.8)" 0 0 2>/tmp/forwarderv4.conf
					v4Forwarder=$(cat /tmp/forwarderv4.conf)
					menu
				;;

			"Forwarder IPv6")
				dialog	--title "Forwarder IPv6" \
					--inputbox "Favor digitar o Forwarder IPv6 (ex.: 2001:4860:4860::8888)" 0 0 2>/tmp/forwarderv6.conf
					v6Forwarder=$(cat /tmp/forwarderv6.conf)
					menu
				;;

			"Prefixo do NAT64")
				dialog	--title "Config.  de prefixo NAT64" \
					--inputbox "Favor digitar o prefixo utilizado pelo NAT64 (ex.: 2001:db8:1:ffff::/96)" 0 0 2>/tmp/prefixnat64.conf
					PREFIXNAT64=$(cat /tmp/prefixnat64.conf)
					menu
				;;

			"Rede IPv6 permitida")
				dialog	--title "Config.  de prefixo NAT64" \
					--inputbox "Favor digitar o prefixo utilizado pelo NAT64 (ex.: 2001:db8::/64)" 0 0 2>/tmp/v6network.conf
					v6network=$(cat /tmp/v6network.conf)
					menu
				;;

			"Endereço da interface IPv4")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv4 do roteador COM a máscara (ex.: 192.168.0.200/24)" 0 0 2>/tmp/ifacev4.conf
					ifacev4=$(cat /tmp/ifacev4.conf)
					echo "${ifacev4%???}" > /tmp/v4nomask
					ipv4nomask=$(cat /tmp/v4nomask)
					menu
				;;

			# "Endereço da interface IPv6")
			# 	dialog	--title "Config.  de endereço" \
			# 		--inputbox "Favor digitar o endereço da interface IPv6 do roteador COM a máscara (ex.: 2001:db8:1::3/64)" 0 0 2>/tmp/ifacev6.conf
			# 		ifacev6=$(cat /tmp/ifacev6.conf)
			# 		echo "${ifacev6%???}" > /tmp/v6nomask
			# 		ipv6nomask=$(cat /tmp/v6nomask)
			# 		menu
			# 	;;

			"Iniciar config. do DNS64")
				dialog --yesno 'Deseja realizar autenticação DNSSEC?' 0 0
				doDNSSEC=$?
				dialog --yesno 'Deseja que o DNS responda autoritativamente ao receber respostas NXDOMAIN?' 0 0
				doAUTORITATIVO=$?
				dialog --yesno 'Deseja que o DNS64 retorne apenas endereços IPv4? (prefixo + ipv4)' 0 0
				doEXCLUDE=$?
				write_config
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
menu
