#!/bin/bash


interfaces(){

	ls /sys/class/net > /tmp/iface.txt     #Lista as interfaces e escreve no arquivo if.txt
	numero=$(wc -l < /tmp/iface.txt)     #Conta a quantidade de interfaces(linhas) do sistema 
	interface=(inexistente inexistente inexistente inexistente)
	#Se a quantidade de interfaces for menor ou igual a 4 escreve nas posicoes de 0 a 3 do verto de interfaces
	if [ $numero -le 4 ];then
	contador=1
	until [ $contador -eq $numero ];do
	interface[$contador]=$(sed -n $contador'p' /tmp/iface.txt) 
	let contador+=1
	
	done
	fi

}

menu(){

 dialog	--title "Configuracao Manual Tayga" \
		--menu "Insira os parametros de configuracao" 0 0 0 \
	        "Prefixo IPv6 de NAT64" "$PREFIX" \
	        "Pool de mapeamento IPv4" "$TAYGA_IPV4_POOL" \
	        "Endereço IPv4 do Tayga" "$TAYGA_IPV4ADDR" \
	        "Endereço da interface IPv4" "$ifacev4" \
	        "Endereço da interface IPv6" "$ifacev6" \
			"Iniciar config. do NAT64" '' 2> /tmp/opt
		opt=$(cat /tmp/opt)

case $opt in
			"Prefixo IPv6 de NAT64")
				dialog	--title "Prefixo NAT64" \
					--inputbox "Favor digitar o prefixo NAT64 com a máscara (/96) (ex.: 2001:db8:1:ffff::/96)" 0 0 2>/tmp/prefixnat64.conf
					PREFIX=$(cat /tmp/prefixnat64.conf)
					menu
				;;

			"Pool de mapeamento IPv4")
				dialog	--title "Config. de pool NAT64" \
					--inputbox "Favor Digitar um Endereco IPv4 de rede com a máscara CIDR (ex.: 192.168.255.0/24)" 0 0 2>/tmp/poolnat64.conf
					 TAYGA_IPV4_POOL=$(cat /tmp/poolnat64.conf)
					menu
				;;

			"Endereço IPv4 do Tayga")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor Digitar um Endereco IPv4 pertencente ao pool de endereços do NAT64 (ex.: 192.168.255.1)" 0 0 2>/tmp/ipv4nat64.conf
					TAYGA_IPV4ADDR=$(cat /tmp/ipv4nat64.conf)
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

			"Endereço da interface IPv6")
				dialog	--title "Config.  de endereço" \
					--inputbox "Favor digitar o endereço da interface IPv6 do roteador COM a máscara (ex.: 2001:db8:1::3/64)" 0 0 2>/tmp/ifacev6.conf
					ifacev6=$(cat /tmp/ifacev6.conf)
					echo "${ifacev6%???}" > /tmp/v6nomask
					ipv6nomask=$(cat /tmp/v6nomask)
					menu
				;;

			"Iniciar config. do NAT64")
				dialog --yesno 'Deseja realizar SNAT para a rede externa?' 0 0
				doNAT=$?
				configIP
				configNAT64
				;;
			esac

 }

 configIP(){

 	sysctl -w net.ipv6.conf.all.forwarding=1
	sysctl -w net.ipv4.ip_forward=1

 	# Interface IPv4 #####
 	sudo ip addr flush dev ${interface[1]}
	sudo ip link set ${interface[1]} up 
	sudo ip addr add $ifacev4 dev ${interface[1]}

	# Interface IPv6 #####
	sudo ip addr flush dev ${interface[2]}
	sudo ip link set ${interface[2]} up 
	sudo ip -6 addr add $ifacev6 dev ${interface[2]}
 }


 configNAT64(){
	
 	ifconfig 

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
		iptables -t nat -A POSTROUTING -s $TAYGA_IPV4_POOL -o ${interface[1]} -j SNAT --to $ipv4nomask
	fi
	
	iptables -A FORWARD -i ${interface[1]} -o nat64 -m state --state RELATED,ESTABLISHED -j ACCEPT 
	iptables -A FORWARD -i nat64 -o ${interface[1]} -j ACCEPT

	echo -e "\n************* Configuração NAT64 completa! *******************\n"
}

 PREFIX="-"
 TAYGA_IPV4ADDR="-"
 TAYGA_IPV4_POOL="-"
 ifacev6="-"
 ifacev4="-"
 interfaces
 menu




	



	       
