#Criacao das Funcoes
function auto_ip(){
	echo "Configuracao das Interfaces de Rede:" > /tmp/log.tmp
	sudo ifconfig eth0 up 
	sudo ifconfig eth1 up 
	sudo ifconfig eth0 172.24.1.1/24 
	sudo ifconfig eth1 192.168.1.1/24 
	sudo ifconfig >> /tmp/log.tmp
	echo "Roteamento:" >> /tmp/log.tmp
	sudo route -n >> /tmp/log.tmp
}
function voltar(){
dialog	--title "Tela de Controle" \
	--menu	"Escolhe uma opcao" 0 0 0 \
	AUTOIP "Escolhe uma opcao" \
	IP "Configuracao Manual" \
	PROC "Listar e Matar Processos" \
	VOLTAR '' 2> /tmp/opcao
}

function config_if(){
	dialog	--title "Configuracao Manual" \
		--menu "Escolha uma Interface" 0 0 0 \
		ETH0 "Interface Ethernet 0" \
		ETH1 "Interface Ethernet 1" \
		ETH2 "Interface Ethernet 2" \
		ROUTE "Default Gateway e Roteamento" \
		DNS "Domain Name Server" \
		VOLTAR '' 2> /tmp/opcao
		opt=$(cat /tmp/opcao)
		
		case $opt in
			"ETH0")
				dialog	--title "Config ETH0..." \
					--inputbox "Favor Digitar um Endereco IP" 0 0 2>/tmp/eth0.conf
					sudo ifconfig eth0 up	
					ip=$(cat /tmp/eth0.conf)
					sudo ifconfig eth0 $ip/24 
					ifconfig eth0 > /tmp/eth0.log
					dialog	--backtitle "Resultado Configuracao.." \
						--textbox /tmp/eth0.log 22 70
				;;
			*)
				echo "Opcao Errada"
				;;
			esac
}

# Relacao de Menu Simples
dialog	--title "Tela de Controle" \
	--menu "Escolhe uma opcao:" 0 0 0 \
	AUTOIP "Configuracao Automatico" \
	IP "Configuracao Manual" \
	PROC "Listar e Matar Processos" \
	CRON "Configurar Crontab" \
	VOLTAR '' 2> /tmp/opcao
	opt=$(cat /tmp/opcao)
	case $opt in
		"AUTOIP")
			auto_ip
			dialog	--title "Configuracoes Aplicadas" \
				--textbox /tmp/log.tmp 22 70
			;;
		"IP")
			config_if
			;;
		"Voltar")
			voltar
			;;
		esac


