#!/bin/bash

#funcoes
function fisico(){
dialog --title "Menu de physical volume" \
	--menu "Escolha a opcao" 0 0 0 \
	MostrarPV "Mostar volumes fisicos presentes no disco" \
	CriarPV "Crie um PV" \
	2> /tmp/menufisico
	opt_fisico=$(cat /tmp/menufisico)
	case $opt_fisico in

		"MostrarPV")
			sudo pvdisplay > /tmp/pv_display
			dialog --backtitle "Volumes fisicos do disco" \
				--textbox /tmp/pv_display 22 70 
			;;

		"CriarPV")
			;;

	esac

}



#principal


dialog --title "Menu principal " \
	--menu "Escolha a opcao:" 0 0 0 \
        FISICO "Visualizar ou criar volume fisico" \
        LOGICO "Vizualizar ou criar volume logico" \
        GRUPO "Vizualiar ou criar grupo de disco" \
        VOLTAR 	' ' 2> /tmp/opcao
        opt=$(cat /tmp/opcao)
	case $opt in 

		"FISICO")
                fisico
			;;
                
		"LOGICO") 
		logico	
			;; 
		"GRUPO")
		grupo
			;;

		"VOLTAR")

			;;
		esac

