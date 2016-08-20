#Identificacao de interfaces de rede
ls /sys/class/net > /tmp/if.txt     #Lista as interfaces e escreve no arquivo if.txt
numero=$(wc -l < /tmp/if.txt)       #Conta a quantidade de interfaces(linhas) do sistema 
interface=(inexistente inexistente inexistente inexistente)
#Se a quantidade de interfaces for menor ou igual a 4 escreve nas posicoes de 0 a 3 do verto de interfaces
if [ $numero -le 4 ];then
contador=1
until [ $contador -eq $numero ];do
interface[$contador]=$(sed -n $contador'p' /tmp/if.txt) 
let contador+=1
done
fi

#Criacao das Funcoes
function voltar(){
dialog	--title "Tela de Controle" \
	--menu "Escolhe uma opcao:" 0 0 0 \
	IP "Configuracao Manual" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"IP")
			config_if
			;;
		"VOLTAR")
			voltar
			;;
		esac
}

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

#Menu Principal 
dialog	--title "Tela de Controle" \
	--menu "Escolhe uma opcao:" 0 0 0 \
	IP "Configuracao Manual" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"IP")
			config_if
			;;
		"Voltar")
			voltar
			;;
		esac


