#!/bin/bash

trim() {
    set -f
    # Desabilitação da verificação do shell=2048,2086
    set -- $*
    printf '%s\n' "${*//[[:space:]]/}"
    set +f
}

processo_nome() {
    # Obter nome PID.
    nome="$(< "/proc/${1:-$PPID}/comm")"
    printf "%s" "$nome"
}

terminal() {
    # Verificando $PPID para emulador de terminal.
    while [[ -z "$term" ]]; do
		ppid="$(grep -i -F "PPid:" "/proc/${1:-$PPID}/status")"
        parent="$(trim "${ppid/PPid:}")"
        if [ -z "$parent" ]; then
			break
        fi
        nome="$(processo_nome "$parent")"
        case ${na// } in
            "login"*|*"Login"*|"init"|"(init)")
            term="$(tty)"
            ;;
            "gnome-terminal-") 
            term="gnome-terminal" 
            ;;
            "urxvtd")          
            term="urxvt" 
            ;;
            *"nvim")           
            term="Neovim Terminal" 
            ;;
            *"NeoVimServer"*)  
            term="VimR Terminal" 
            ;;
            *)
			# Corrigir problemas com nomes longos de processos no Linux.
            term=$(realpath "/proc/$parent/exe")
			term="${nome##*/}"
        esac
    done
}

if [ "$USER" != "root" ]; then
	echo "Use comando 'sudo'  ou comando 'su' antes de inicializar o programa."
	exit 1
fi

if ! [ -e "/usr/bin/dialog" ]; then
	echo -e "Dialog não instalado e será instalado...\n"
	apt install -y dialog
fi
if ! [ -e "/usr/bin/feh" ]; then
	echo -e "Feh não instalado e será instalado...\n"
	apt install -y feh
fi

terminal
texto="Instalador do emulador de joystick Xbox 360 v 1.8.1 (2025)"
cont="$[${#texto} + 4]"
dialog --title "Desenvolvedor" --infobox "Desenvolvido por Marx F. C. Monte\n
Instalador do emulador de joystick Xbox 360 v 1.8.1 (2025)\n
Para a Distribuição Debian 12 e derivados (antiX 23)" 5 $cont
sleep 3
clear

menu(){
	
texto="SETAS PARA ESCOLHER E ENTER PARA CONFIRMAR"
cont="$[${#texto} + 4]"
opcao=$(dialog --title "MENU" --menu "$texto" 10 $cont 3 \
"1" "PARA INSTALAR" \
"2" "PARA REMOVER" \
"3" "PARA SAIR" \
--stdout)
clear
pastab="/usr/share/pixmaps/JoystickXbox360"
pastaj="/usr/share/JoystickXbox360"
case $opcao in
	1)
	lista=("Y" "B" "A" "X" "LB" "RB" "LT" "RT" "BACK" "START" "LS" "RS"\
 "↔ R" "↕ R" "↔ L" "↕ L" "↔ PAD" "↕ PAD" "↔ PAD" "↕ PAD")
	botoes=("Y" "B" "A" "X" "L1" "R1" "L2" "R2" "SL" "ST" "L3" "R3"\
 "RX" "RY" "LX" "LY" "PADX1" "PADY1" "PADX2" "PADY2")
	texto="Instalação sendo iniciada..."
	cont="$[${#texto} + 4]"
	dialog --infobox "$texto" 3 $cont
	sleep 3
	clear
	if [ -d "$pastaj" ]; then
		texto="O diretório JoystickXbox360 existe..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	else
		texto="O diretório JoystickXbox360 será criado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		mkdir $pastaj
	fi
	if [ -e "$pastaj/install.conf" ]; then
		texto="A instalação dos pacotes não será necessária..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	else
		apt update && apt-get upgrade -y
		apt install -y xboxdrv antimicro evtest
	fi
	if [ -e "$pastaj/install.conf" ]; then
		texto="O arquivo install.conf existe..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	else
		texto="O arquivo install.conf será criado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		echo "Pacotes instalados xboxdrv antimicro evtest" >\
		 $pastaj/install.conf
	fi
	pkill xboxdrv &
	sleep 5
	i=0
	while true
	do
		udevadm info -a -n /dev/input/event$i > "$pastaj"/joystick.log
		if ! [ "$(cat "$pastaj/joystick.log")" ]; then
			clear
			texto="Porta do joystick não localizada..."
			cont="$[${#texto} + 4]"
			dialog --infobox "$texto" 3 $cont
			sleep 3
			clear
			exit 1
		fi
		udevadm info -a -n /dev/input/event$i | grep -q "Joystick"
		if [ "$?" = "0" ]; then
			texto="Porta do joystick localizada..."
			cont="$[${#texto} + 4]"
			dialog --infobox "$texto" 3 $cont
			sleep 3
			clear
			jost=$i
			break
		fi
		i=$[ i + 1 ]
	done
	chmod 775 /dev/input/event$jost
	
	if [ -e "$pastaj/drvconf.conf" ]; then
		rm $pastaj/drvconf.conf
	fi
	if [ -d "$pastab" ]; then
		texto="O diretório para os icones já existe..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	else
		texto="O diretório para os icones será criado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		mkdir $pastab
		cat <<EOF > "$pastaj"/xbox360
https://raw.githubusercontent.com/marxfcmonte/Instalador-do-emulador-de-\
joystick-Xbox-em-joystick-generico-de-PC-PS2-PS3-Debian-e-Derivados-antix-\
/refs/heads/main/Icones/xbox360.png
https://raw.githubusercontent.com/marxfcmonte/Instalador-do-emulador-de-\
joystick-Xbox-em-joystick-generico-de-PC-PS2-PS3-Debian-e-Derivados-antix-\
/refs/heads/main/Icones/xbox360preto.png
https://raw.githubusercontent.com/marxfcmonte/Instalador-do-emulador-de-\
joystick-Xbox-em-joystick-generico-de-PC-PS2-PS3-Debian-e-Derivados-antix-\
/refs/heads/main/Icones/Botoes.tar.gz
EOF
		wget -i $pastaj/xbox360 -P /tmp/
		mv /tmp/xbox360.png $pastab
		mv /tmp/xbox360preto.png $pastab
		mv /tmp/Botoes.tar.gz $pastab
		tar -xf $pastab/Botoes.tar.gz -C $pastab
		rm $pastab/Botoes.tar.gz
	fi
	j=0
	while true
	do	
		evtest /dev/input/event$jost > $pastaj/testecon.conf &
		feh $pastab/Botoes/xbox${botoes[$j]}.jpg &
		texto="Atribua um botão ou analógico..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		while true
		do
			if [ "$(cat $pastaj/testecon.conf | grep -n exit)" ]; then 
				cat $pastaj/testecon.conf | grep -n exit | cut -d ":" -f1 > $pastaj/nome.conf
				numero=$(cat $pastaj/nome.conf)
			else
				numero=100
			fi
			sed -n "1,$numero p" $pastaj/testecon.conf > $pastaj/textocont.conf 
			numbt=$(cat $pastaj/textocont.conf | grep -c BTN_)
			numabs=$(cat $pastaj/textocont.conf | grep -c ABS_)
			tot=$[$numbt + $numabs - 1] 
			echo "$tot" > $pastaj/total.conf
			sed "1,$numero d" $pastaj/testecon.conf > $pastaj/textogeral.conf 
			sleep 1
			if [ "$(cat $pastaj/textogeral.conf)" ]; then
				break
			fi
		done
		pkill evtest
		pkill feh
		sleep 1
		cat $pastaj/textogeral.conf | grep value | cut -d "," -f3 |  cut -d "(" -f2 | cut -d ")" -f1 > $pastaj/testecon1.conf
		mv $pastaj/testecon1.conf $pastaj/testecon.conf
		awk -F "MSC_SCAN" '{print $1}' $pastaj/testecon.conf > $pastaj/temp.conf; mv $pastaj/temp.conf $pastaj/testecon.conf
		sed '/^$/d' $pastaj/testecon.conf > $pastaj/temp.conf && mv $pastaj/temp.conf $pastaj/testecon.conf 
		configu=$(head -n 1 $pastaj/testecon.conf)
		echo "$configu" | sed 's/ //g' > $pastaj/temp.conf; mv $pastaj/temp.conf $pastaj/testecon.conf
		if [ "$(cat $pastaj/testecon.conf)" ]; then
			sleep 1
			clear
			nome=$(cat $pastaj/testecon.conf)
			texto="Função atribuída: $nome..."
			cont="$[${#texto} + 4]"
			dialog --infobox "$texto" 3 $cont 
			sleep 1
			clear
		fi
		cat $pastaj/testecon.conf >> $pastaj/drvconf.conf
		if [ "$j" -eq "$tot" ]; then
			texto="Configuração terminada..."
			cont="$[${#texto} + 4]"
			dialog --nocancel ---pause "$texto" 8 $cont 20 
			clear
			break
		fi
		j=$[ j + 1 ]
	done
	configu=$(cat $pastaj/drvconf.conf)
	echo "$configu" | sed 's/ //g' > $pastaj/drvconf.conf
	controle=($(cat $pastaj/drvconf.conf))
	var=($(cat $pastaj/drvconf.conf))

	texto=$(echo -e "\nHá alguma configuraçao se repitindo?\n
$(
i=0
j=9
printf "%1s\n" "**********************"
while true
do
	texto="${controle[$i]} = ${lista[$i]}"
	cont="$[40 - ${#texto}]"
	printf "%0s %"$cont"s\n" "${controle[$i]} = ${lista[$i]}" "${controle[$j]} = ${lista[$j]}"
	if [ "$j" -eq "$tot" ]; then
		break
	fi
	i=$[ i + 1 ]
	j=$[ j + 1 ]
done
printf "%1s\n" "**********************"
)
Sim para sair e Não para continuar como a configuração.")

	dialog --no-collapse --defaultno --title "Configurações preliminares" --yesno "$texto" 0 0 

	if ! [ "$?" = "0" ]; then
		texto="O analógico esquerdo invertido do eixo Y - Sim (MARCADDO)"
		cont="$[${#texto} + 13]"
		opcao=$(dialog --no-cancel --title "MENU" --checklist \
"Qual das direções estão invertidas?" 13 $cont 6 \
"0" "O analógico direito invertido do eixo X - Sim (MARCADDO)" OFF \
"1" "O analógico direito invertido do eixo Y - Sim (MARCADDO)" ON \
"2" "O analógico esquerdo invertido do eixo X - Sim (MARCADDO)" OFF \
"3" "O analógico esquerdo invertido do eixo Y - Sim (MARCADDO)" ON \
"4" "O analógico PAD invertido do eixo X - Sim (MARCADDO)" OFF \
"5" "O analógico PAD invertido do eixo Y - Sim (MARCADDO)" OFF \
--stdout)
		clear
		analogico_invertido=("-X1=X1" "-Y1=Y1" "-X2=X2" "-Y2=Y2" "-DPAD_X=DPAD_X" "-DPAD_Y=DPAD_Y")
		analogico=("X1=X1" "Y1=Y1" "X2=X2" "Y2=Y2" "DPAD_X=DPAD_X" "DPAD_Y=DPAD_Y")
		if [ -e "$pastaj"/config.conf ]; then
			rm "$pastaj"/config.conf
		fi
		num="0 1 2 3 4 5"
		for p in $(echo "$opcao")
		do	
			echo "${analogico_invertido[$p]} " >> "$pastaj"/config.conf
			num=$(echo "$num" | sed "s/[$p-$p]//g")
		done
		for p in $(echo "$num")
		do	
			echo "${analogico[$p]} " >> "$pastaj"/config.conf
		done
		config=($(cat "$pastaj"/config.conf))
		pkill xboxdrv
		sleep 5
		xboxdrv --evdev /dev/input/event$jost --evdev-absmap ${var[12]}=x1,${var[13]}=y1,${var[14]}=x2,${var[15]}=y2,\
${var[16]}=dpad_x,${var[17]}=dpad_y --axismap ${config[0]},${config[1]},${config[2]},${config[3]},${config[4]},\
${config[5]}  --evdev-keymap ${var[0]}=y,${var[1]}=b,${var[2]}=a,${var[3]}=x,${var[4]}=lb,${var[5]}=rb,${var[6]}=lt,\
${var[7]}=rt,${var[8]}=back,${var[9]}=start,${var[10]}=tl,${var[11]}=tr --mimic-xpad --silent > /tmp/joystick.log &
		clear
		texto="Configurações atribuídas: 

$(cat $pastaj/config.conf)"
		cont="$[${#texto} + 4]"
		dialog --nocancel --pause "$texto" 15 29 60 
		clear
		i=0
		while true
		do
			udevadm info -a -n /dev/input/event$i > /usr/share/JoystickXbox360/joystick.log
			if ! [ "$(cat "$pastaj/joystick.log")" ]; then
				clear
				texto="Porta do joystick Xbox 360 emulado não localizada..."
				cont="$[${#texto} + 4]"
				dialog --infobox "$texto" 3 $cont
				sleep 3
				clear
				exit 1
			fi
			udevadm info -a -n /dev/input/event$i | grep -q "Microsoft X-Box 360 pad"
			if [ "$?" = "0" ]; then
				texto="Porta do joystick Xbox 360 emulado localizada..."
				cont="$[${#texto} + 4]"
				dialog --infobox "$texto" 3 $cont
				sleep 3
				clear
				jost1=$i
				break
			fi
			i=$[ i + 1 ]
		done
	else
		texto="Tente novamente"
		cont="$[${#texto} + 4]"
		dialog --msgbox "$texto" 5 $cont
		clear
		menu
	fi
	chmod 775 /dev/input/event$jost1
	sleep 2
	cat <<EOF > /etc/X11/xorg.conf.d/51-joystick.conf
Section "InputClass"
	Identifier "joystick catchall"
	MatchIsJoystick "on"
	MatchDevicePath "/dev/input/event$jost"
	Driver "joystick"
	Option "StartKeysEnabled" "False"
	Option "StartMouseEnabled" "False"
EndSection

Section "InputClass"
	Identifier "joystick catchall"
	MatchIsJoystick "on"
	MatchDevicePath "/dev/input/event$jost1"
	Driver "joystick"
	Option "StartKeysEnabled" "False"
	Option "StartMouseEnabled" "False"
EndSection
EOF
	cat <<EOF > "$pastaj"/jyt.conf 
--evdev-absmap ${var[12]}=x1,${var[13]}=y1,${var[14]}=x2,${var[15]}=y2,\
${var[16]}=dpad_x,${var[17]}=dpad_y --axismap ${config[0]},${config[1]},${config[2]},${config[3]},${config[4]},\
${config[5]} --evdev-keymap ${var[0]}=y,${var[1]}=b,${var[2]}=a,${var[3]}=x,${var[4]}=lb,${var[5]}=rb,${var[6]}=lt,\
${var[7]}=rt,${var[8]}=back,${var[9]}=start,${var[10]}=tl,${var[11]}=tr --mimic-xpad --silent
EOF
	fim="EOF"
	cat <<EOF > $pastaj/MudarControle.sh
#!$SHELL

senha=\$(dialog --title "AUTORIZAÇÃO" --passwordbox "Digite a senha (SUDO):" 8 40 --stdout)
if [ -z "\$senha" ]; then
	dialog --title "ERRO" --infobox "A senha (SUDO) não foi digitada." 3 40
	sleep 3
	clear
	exit 1
fi
clear
echo \$senha|sudo -S -p "" chown $SUDO_USER:$SUDO_USER $pastaj/*.log
sudo pkill xboxdrv &
sudo chown $SUDO_USER:$SUDO_USER $pastaj/*.conf
sleep 5
clear
j=0
texto1="PARA COFIGURAR SOMENTE AS DIREÇÕES DOS ANALÓGICOS"
texto="SETAS PARA ESCOLHER E ENTER PARA CONFIRMAR"
cont="\$[\${#texto1} + 4]"
opcao=\$(dialog --title "MENU" --menu "\$texto" 10 \$cont 3 \
"1" "PARA COFIGURAR TODAS AS CONFIGARAÇÕES" \
"2" "PARA COFIGURAR SOMENTE AS DIREÇÕES DOS ANALÓGICOS" \
"3" "PARA SAIR" \
--stdout)
clear
case \$opcao in
	1)
	i=0
	while true
	do
		udevadm info -a -n /dev/input/event\$i > $pastaj/joystick.log
		if ! [ "\$(cat "$pastaj/joystick.log")" ]; then
			clear
			texto="Porta do joystick não localizada..."
			cont="\$[\${#texto} + 4]"
			dialog --infobox "\$texto" 3 \$cont
			sleep 3
			clear
			echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
			  $pastaj/joystickxbox360.conf
			exit 1
		fi
		udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
		if [ "\$?" = "0" ]; then
			dialog --infobox "Porta do joystick localizada..." 3 35
			echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." >\
			  $pastaj/joystickxbox360.conf
			jost=\$i
			sleep 3
			clear
			break
		fi
		i=\$[ i + 1 ]
	done
	sudo chmod 775 /dev/input/event\$jost
	sleep 5
	while true
	do	
		sudo evtest /dev/input/event\$jost > $pastaj/testecon.conf &
		feh $pastab/Botoes/xbox\${botoes[\$j]}.jpg &
		texto="Atribua um botão ou analógico..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		while true
		do
			if [ "\$(cat $pastaj/testecon.conf | grep -n exit)" ]; then 
				cat $pastaj/testecon.conf | grep -n exit | cut -d ":" -f1 > $pastaj/nome.conf
				numero=\$(cat $pastaj/nome.conf)
			else
				numero=100
			fi
			sed -n "1,\$numero p" $pastaj/testecon.conf > $pastaj/textocont.conf 
			numbt=\$(cat $pastaj/textocont.conf | grep -c BTN_)
			numabs=\$(cat $pastaj/textocont.conf | grep -c ABS_)
			tot=\$[\$numbt + \$numabs - 1] 
			echo "\$tot" > $pastaj/total.conf
			sed "1,\$numero d" $pastaj/testecon.conf > $pastaj/textogeral.conf 
			sleep 1
			if [ "\$(cat "$pastaj/textogeral.conf")" ]; then
				break
			fi
		done
		sudo pkill evtest
		sudo pkill feh
		sleep 1
		cat $pastaj/textogeral.conf | grep "value" | cut -d "," -f3 |  cut -d "(" -f2 | cut -d ")" -f1 > "$pastaj"/testecon1.conf
		mv $pastaj/testecon1.conf $pastaj/testecon.conf
		awk -F "MSC_SCAN" '{print \$1}' $pastaj/testecon.conf > $pastaj/temp.conf; mv $pastaj/temp.conf $pastaj/testecon.conf
		sed '/^\$/d' $pastaj/testecon.conf > $pastaj/temp.conf && mv $pastaj/temp.conf $pastaj/testecon.conf 
		configu=\$(head -n 1 $pastaj/testecon.conf)
		echo "\$configu" | sed 's/ //g' > $pastaj/temp.conf; mv $pastaj/temp.conf $pastaj/testecon.conf
		if [ "\$(cat $pastaj/testecon.conf)" ]; then
			sleep 1
			clear
			nome=\$(cat $pastaj/testecon.conf)
			texto="Função atribuída: \$nome..."
			cont="\$[\${#texto} + 4]"
			dialog --infobox "\$texto" 3 \$cont 
			sleep 1
			clear
		fi
		cat $pastaj/testecon.conf >> $pastaj/drvconf.conf
		if [ "\$j" -eq "\$tot" ]; then
			texto="Configuração terminada..."
			cont="\$[\${#texto} + 4]"
			dialog --nocancel --pause "\$texto" 8 \$cont 20 
			clear
			break
		fi
		j=\$[ j + 1 ]
	done
	configu=\$(cat $pastaj/drvconf.conf)
	echo "\$configu" | sed 's/ //g' > $pastaj/drvconf.conf
	controle=(\$(cat $pastaj/drvconf.conf))
	var=(\$(cat $pastaj/drvconf.conf))

	texto=\$(echo -e "\nHá alguma configuraçao se repitindo?\n
\$(
i=0
j=9
printf "%1s\n" "**********************"
while true
do
	texto="\${controle[\$i]} = \${lista[\$i]}"
	cont="\$[40 - \${#texto}]"
	printf "%0s %"\$cont"s\n" "\${controle[\$i]} = \${lista[\$i]}" "\${controle[\$j]} = \${lista[\$j]}"
	if [ "\$j" -eq \$tot ]; then
		break
	fi
	i=\$[ i + 1 ]
	j=\$[ j + 1 ]
done
printf "%1s\n" "**********************"
)
Sim para sair e Não para continuar como a configuração.")

	dialog --no-collapse --defaultno --title "Configurações preliminares" --yesno "\$texto" 0 0 

	if ! [ "\$?" = "0" ]; then
		texto="O analógico esquerdo invertido do eixo Y - Sim (MARCADDO)"
		cont="\$[\${#texto} + 13]"
		opcao=\$(dialog --no-cancel --title "MENU" --checklist \
"Qual das direções estão invertidas?" 13 \$cont 6 \
"0" "O analógico direito invertido do eixo X - Sim (MARCADDO)" OFF \
"1" "O analógico direito invertido do eixo Y - Sim (MARCADDO)" ON \
"2" "O analógico esquerdo invertido do eixo X - Sim (MARCADDO)" OFF \
"3" "O analógico esquerdo invertido do eixo Y - Sim (MARCADDO)" ON \
"4" "O analógico PAD invertido do eixo X - Sim (MARCADDO)" OFF \
"5" "O analógico PAD invertido do eixo Y - Sim (MARCADDO)" OFF \
--stdout)
		clear
		analogico_invertido=("-X1=X1" "-Y1=Y1" "-X2=X2" "-Y2=Y2" "-DPAD_X=DPAD_X" "-DPAD_Y=DPAD_Y")
		analogico=("X1=X1" "Y1=Y1" "X2=X2" "Y2=Y2" "DPAD_X=DPAD_X" "DPAD_Y=DPAD_Y")
		if [ -e "$pastaj"/config.conf ]; then
			rm $pastaj/config.conf
		fi
		num="0 1 2 3 4 5"
		for p in \$(echo "\$opcao")
		do	
			echo "\${analogico_invertido[\$p]} " >> $pastaj/config.conf
			num=\$(echo "\$num" | sed "s/[\$p-\$p]//g")
		done
		for p in \$(echo "\$num")
		do	
			echo "\${analogico[\$p]} " >> $pastaj/config.conf
		done
		config=(\$(cat $pastaj/config.conf))
		pkill xboxdrv
		sleep 5
		sudo xboxdrv --evdev /dev/input/event\$jost --evdev-absmap \${var[12]}=x1,\${var[13]}=y1,\${var[14]}=x2,\${var[15]}=y2,\
\${var[16]}=dpad_x,\${var[17]}=dpad_y --axismap \${config[0]},\${config[1]},\${config[2]},\${config[3]},\${config[4]},\
\${config[5]}  --evdev-keymap \${var[0]}=y,\${var[1]}=b,\${var[2]}=a,\${var[3]}=x,\${var[4]}=lb,\${var[5]}=rb,\${var[6]}=lt,\
\${var[7]}=rt,\${var[8]}=back,\${var[9]}=start,\${var[10]}=tl,\${var[11]}=tr --mimic-xpad --silent > /tmp/joystick.log &
		clear
		texto="Configurações atribuídas: 

\$(cat $pastaj/config.conf)"
		cont="\$[\${#texto} + 4]"
		dialog --nocancel --pause "\$texto" 15 29 60 
		clear
		i=0
		while true
		do
			udevadm info -a -n /dev/input/event\$i > $pastaj/joystick.log
			if ! [ "\$(cat $pastaj/joystick.log)" ]; then
				clear
				texto="Porta do joystick Xbox 360 emulado não localizada..."
				cont="\$[\${#texto} + 4]"
				dialog --infobox "\$texto" 3 \$cont
				sleep 3
				clear
				exit 1
			fi
			udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
			if [ "\$?" = "0" ]; then
				texto="Porta do joystick Xbox 360 emulado localizada..."
				cont="\$[\${#texto} + 4]"
				dialog --infobox "\$texto" 3 \$cont
				sleep 3
				clear
				jost1=\$i
				break
			fi
			i=\$[ i + 1 ]
		done
	cat <<$fim > $pastaj/jyt.conf 
--evdev-absmap \${var[12]}=x1,\${var[13]}=y1,\${var[14]}=x2,\${var[15]}=y2,\
\${var[16]}=dpad_x,\${var[17]}=dpad_y --axismap \${config[0]},\${config[1]},\${config[2]},\${config[3]},\${config[4]},\
\${config[5]} --evdev-keymap \${var[0]}=y,\${var[1]}=b,\${var[2]}=a,\${var[3]}=x,\${var[4]}=lb,\${var[5]}=rb,\${var[6]}=lt,\
\${var[7]}=rt,\${var[8]}=back,\${var[9]}=start,\${var[10]}=tl,\${var[11]}=tr --mimic-xpad --silent
$fim
clear
sudo chown root:root $pastaj/*.log
sudo chown root:root $pastaj/*.conf
sudo chmod 775 /dev/input/event\$jost1
	sleep 6
	clear
	sudo service joystickxbox360 status
	sleep 6
	clear
	dialog --nocancel --pause "Teste o Joystick Xbox 360 emulado no AntiMicroX caso\n
os analógicos ficarem com sentido invertido,\
 use o aplicativo 'Muda a configuração do joystick Xbox 360'." 10 65 20

	reset
	antimicrox
	;;
	2)
	var=(\$(cat $pastaj/drvconf.conf))
	texto="O analógico esquerdo invertido do eixo Y - Sim (MARCADDO)"
	cont="\$[\${#texto} + 13]"
	opcao=\$(dialog --no-cancel --title "MENU" --checklist \
"Qual das direções estão invertidas?" 13 \$cont 6 \
"0" "O analógico direito invertido do eixo X - Sim (MARCADDO)" OFF \
"1" "O analógico direito invertido do eixo Y - Sim (MARCADDO)" ON \
"2" "O analógico esquerdo invertido do eixo X - Sim (MARCADDO)" OFF \
"3" "O analógico esquerdo invertido do eixo Y - Sim (MARCADDO)" ON \
"4" "O analógico PAD invertido do eixo X - Sim (MARCADDO)" OFF \
"5" "O analógico PAD invertido do eixo Y - Sim (MARCADDO)" OFF \
--stdout)
	clear
	analogico_invertido=("-X1=X1" "-Y1=Y1" "-X2=X2" "-Y2=Y2" "-DPAD_X=DPAD_X" "-DPAD_Y=DPAD_Y")
	analogico=("X1=X1" "Y1=Y1" "X2=X2" "Y2=Y2" "DPAD_X=DPAD_X" "DPAD_Y=DPAD_Y")
	if [ -e $pastaj/config.conf ]; then
		rm $pastaj/config.conf
	fi
	num="0 1 2 3 4 5"
	for p in \$(echo "\$opcao")
	do	
		echo "\${analogico_invertido[\$p]} " >> $pastaj/config.conf
		num=\$(echo "\$num" | sed "s/[\$p-\$p]//g")
	done
	for p in \$(echo "\$num")
	do	
		echo "\${analogico[\$p]} " >> $pastaj/config.conf
	done
	config=(\$(cat $pastaj/config.conf))
	pkill xboxdrv
	sleep 5
	sudo xboxdrv --evdev /dev/input/event\$jost --evdev-absmap \${var[12]}=x1,\${var[13]}=y1,\${var[14]}=x2,\${var[15]}=y2,\
\${var[16]}=dpad_x,\${var[17]}=dpad_y --axismap \${config[0]},\${config[1]},\${config[2]},\${config[3]},\${config[4]},\
\${config[5]}  --evdev-keymap \${var[0]}=y,\${var[1]}=b,\${var[2]}=a,\${var[3]}=x,\${var[4]}=lb,\${var[5]}=rb,\${var[6]}=lt,\
\${var[7]}=rt,\${var[8]}=back,\${var[9]}=start,\${var[10]}=tl,\${var[11]}=tr --mimic-xpad --silent > /tmp/joystick.log &
	clear
	texto="Configurações atribuídas: 

\$(cat $pastaj/config.conf)"
	cont="\$[\${#texto} + 4]"
	dialog --nocancel --pause "\$texto" 15 29 60 
	clear
	i=0
	while true
	do
		udevadm info -a -n /dev/input/event\$i > $pastaj/joystick.log
		if ! [ "\$(cat "$pastaj/joystick.log")" ]; then
			clear
			texto="Porta do joystick Xbox 360 emulado não localizada..."
			cont="\$[\${#texto} + 4]"
			dialog --infobox "\$texto" 3 \$cont
			sleep 3
			clear
			exit 1
		fi
		udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
		if [ "\$?" = "0" ]; then
			texto="Porta do joystick Xbox 360 emulado localizada..."
			cont="\$[\${#texto} + 4]"
			dialog --infobox "\$texto" 3 \$cont
			sleep 3
			clear
			jost1=\$i
			break
		fi
		i=\$[ i + 1 ]
	done
	cat <<$fim > $pastaj/jyt.conf 
--evdev-absmap \${var[12]}=x1,\${var[13]}=y1,\${var[14]}=x2,\${var[15]}=y2,\
\${var[16]}=dpad_x,\${var[17]}=dpad_y --axismap \${config[0]},\${config[1]},\${config[2]},\${config[3]},\${config[4]},\
\${config[5]} --evdev-keymap \${var[0]}=y,\${var[1]}=b,\${var[2]}=a,\${var[3]}=x,\${var[4]}=lb,\${var[5]}=rb,\${var[6]}=lt,\
\${var[7]}=rt,\${var[8]}=back,\${var[9]}=start,\${var[10]}=tl,\${var[11]}=tr --mimic-xpad --silent
$fim
clear
sudo chown root:root $pastaj/*.log
sudo chown root:root $pastaj/*.conf
sudo chmod 775 /dev/input/event\$jost1
	sleep 6
	clear
	sudo service joystickxbox360 status
	sleep 6
	clear
	dialog --nocancel --pause "Teste o Joystick Xbox 360 emulado no AntiMicroX caso\n
os analógicos ficarem com sentido invertido,\
 use o aplicativo 'Muda a configuração do joystick Xbox 360'" 10 65 20

	reset
	antimicrox
	;;
	3)
	sudo chown root:root $pastaj/*.log
	sudo chown root:root $pastaj/*.conf
	sudo service joystickxbox360 restart 
	texto="Saindo da configuração..."
	cont="\$[\${#texto} + 4]"
	dialog --infobox "\$texto" 3 \$cont
	sleep 3
	reset
	exit 0
	;;
	*)
	sudo chown root:root $pastaj/*.log
	sudo chown root:root $pastaj/*.conf
	sudo service joystickxbox360 restart 
	texto="Configuração cancelada..."
	cont="\$[\${#texto} + 4]"
	dialog --infobox "\$texto" 3 \$cont
	sleep 3
	reset
	exit 0
	;;
esac
	
exit 0

EOF
	cat <<EOF > $pastaj/StartJoystick.sh
#!$SHELL

pkill xboxdrv &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > $pastaj/joystick.log
	if ! [ "\$(cat "$pastaj/joystick.log")" ]; then
		clear
		echo -e "\nPorta do joystick não localizada..."
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		echo -e "\nPorta do joystick localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		jost=\$i
		break
	fi
	i=\$[ i + 1 ]
done
joystickconf="\$(cat $pastaj/jyt.conf)"
xboxdrv --evdev /dev/input/event\$jost \$joystickconf > /tmp/joystick.log &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > $pastaj/joystick.log
	if ! [ "\$(cat "$pastaj/joystick.log")" ]; then
		clear
		echo -e "Porta do joystick Xbox 360 emulado não localizada..."
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		echo "Porta do joystick Xbox 360 emulado localizada..."
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		jost1=\$i
		break
	fi
	i=\$[ i + 1 ]
done
chmod 775 /dev/input/event\$jost1
sleep 2

exit 0

EOF
	cat <<EOF > $pastaj/RStarJoystick.sh
#!$SHELL

pkill xboxdrv &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > $pastaj/joystick.log
	if ! [ "\$(cat "$pastaj/joystick.log")" ]; then
		clear
		texto="Porta do joystick não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		echo -e "\nPorta do joystick localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		jost=\$i
		break
	fi
	i=\$[ i + 1 ]
done
joystickconf="\$(cat $pastaj/jyt.conf)"
xboxdrv --evdev /dev/input/event\$jost \$joystickconf > /tmp/joystick.log &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > $pastaj/joystick.log
	if ! [ "\$(cat "$pastaj/joystick.log")" ]; then
		clear
		texto="Porta do joystick Xbox 360 emulado não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		echo "Porta do joystick Xbox 360 emulado localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." >\
		 $pastaj/joystickxbox360.conf
		jost1=\$i
		sleep 3
		break
	fi
	i=\$[ i + 1 ]
done
chmod 775 /dev/input/event\$jost1
texto="AGUARDE... PARA O JOYSTICK SER RECONHECIDO."
cont="\$[\${#texto} + 4]"
dialog --nocancel --pause "\$texto" 8 \$cont 60
clear

exit 0

EOF
	cat <<EOF > $pastaj/StopJoystick.sh
#!$SHELL

pkill xboxdrv &
sleep 2

echo -e "Joystick Xbox 360\033[31;1m parado\033[0m..." > \
$pastaj/joystickxbox360.conf
echo -e "Joystick Xbox 360\033[31;1m parado\033[0m..."
sleep 2

exit 0

EOF

	cat <<EOF > /usr/share/applications/MudarControle.desktop
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Muda a configuração do joystick Xbox 360
Name[pt_BR]=Muda a configuração do joystick Xbox 360
Exec=$term -e "bash -c /usr/share/JoystickXbox360/MudarControle.sh"
Terminal=false
StartupNotify=true
Comment=Muda a configuração do joystick Xbox 360
Comment[pt_BR]=Muda a configuração do joystick Xbox 360
Categories=GTK;System;
Keywords=joystick;calibration;
Keywords[pt_BR]=joystick;calibration;
GenericName=Restart joystick Xbox 360
GenericName[pt_BR]=Restart do joystick Xbox 360
Icon=/usr/share/pixmaps/JoystickXbox360/xbox360.png

EOF
	cat <<EOF > /usr/share/applications/RStarJoystick.desktop
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Restart do joystick Xbox 360
Name[pt_BR]=Restart do joystick Xbox 360
Exec=$term -e "sudo service joystickxbox360 restart"
Terminal=false
StartupNotify=true
Comment=Reinicia o joystick Xbox 360
Comment[pt_BR]=Reinicia o joystick Xbox 360
Categories=GTK;System;
Keywords=joystick;calibration;
Keywords[pt_BR]=joystick;calibration;
GenericName=Restart joystick Xbox 360
GenericName[pt_BR]=Restart do joystick Xbox 360
Icon=/usr/share/pixmaps/JoystickXbox360/xbox360.png

EOF

	cat <<EOF > /usr/share/applications/StopJoystick.desktop
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=Finaliza o joystick Xbox 360
Name[pt_BR]=Finaliza o joystick Xbox 360
Exec=$term -e "sudo service joystickxbox360 stop"
Terminal=false
StartupNotify=true
Comment=Finaliza o joystick Xbox 360
Comment[pt_BR]=Finaliza o joystick Xbox 360
Categories=GTK;System;
Keywords=joystick;calibration;
Keywords[pt_BR]=joystick;calibration;
GenericName=Restart do joystick Xbox 360
GenericName[pt_BR]=Restart do joystick Xbox 360
Icon=/usr/share/pixmaps/JoystickXbox360/xbox360preto.png

EOF

	cp /usr/share/applications/MudarControle.desktop /home/$SUDO_USER/Desktop
	cp /usr/share/applications/RStarJoystick.desktop /home/$SUDO_USER/Desktop
	cp /usr/share/applications/StopJoystick.desktop /home/$SUDO_USER/Desktop
	texto="Os atalhos na Àrea de trabalho foram criados..."
	cont="$[${#texto} + 4]"
	dialog --infobox "$texto" 3 $cont
	sleep 3
	clear
	chmod +x /usr/share/JoystickXbox360/*.sh /usr/share/applications/*.desktop
	chmod 775 /home/$SUDO_USER/Desktop/*.desktop
	chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/Desktop/*.desktop
	cat <<EOF >  /etc/init.d/joystickxbox360
#!/bin/sh

### BEGIN INIT INFO
# Provides:		joystickxbox360
# Required-Start:	$null
# Required-Stop:	$null
# Should-Start:		$null
# Should-Stop:
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	Emulação de joystick Xbox 360
# Description:		Emulação de joystick Xbox 360
#
### END INIT INFO

. /lib/lsb/init-functions

case "\$1" in
  start)
	sleep 3
	/usr/share/JoystickXbox360/StartJoystick.sh
	;;
  stop)
	/usr/share/JoystickXbox360/StopJoystick.sh
	;;
  restart)
	/usr/share/JoystickXbox360/RStarJoystick.sh
	;;
  status)
	cat /usr/share/JoystickXbox360/joystickxbox360.conf
	;;
esac

exit 0

EOF
	chmod +x /etc/init.d/joystickxbox360
	update-rc.d joystickxbox360 defaults
	cat /etc/sudoers | grep -q "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360"
	if [ "$?" = "1" ]; then
		texto="As configurações serão atualizadas..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		reset
		sed '/^$/d' /etc/sudoers > /tmp/temp.conf && mv /tmp/temp.conf /etc/sudoers
		echo "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360" >> /etc/sudoers
	else
		texto="As configurações estão atualizadas..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		reset
	fi
	desktop-menu --write-out-global
	texto="Testanto o serviço Joystickxbox360"
	cont="$[${#texto} + 4]"
	dialog --infobox "$texto" 3 $cont
	sleep 3
	clear
	service joystickxbox360 start
	service joystickxbox360 status
	sleep 6
	clear
	dialog --nocancel --pause "Teste o Joystick Xbox 360 emulado no AntiMicroX caso\n
os analógicos ficarem com sentido invertido,\
 use o aplicativo 'Muda a configuração do joystick Xbox 360'." 10 65 20
	reset
	antimicrox
	;;
	2)
	if [ -d "$pastaj" ]; then
		texto="O diretório JoystickXbox360 será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		service joystickxbox360 stop
		update-rc.d joystickxbox360 remove
		rm -rf /usr/share/JoystickXbox360
		rm /etc/init.d/joystickxbox360
	else
		texto="O diretório JoystickXbox360 não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -d "$pastab" ]; then
		texto="O diretório ../pixmaps/JoystickXbox360 será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm -rf /usr/share/pixmaps/JoystickXbox360
	else
		texto="O diretório ../pixmaps/JoystickXbox360 não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -e "/etc/X11/xorg.conf.d/51-joystick.conf" ]; then
		texto="O arquivo 51-joystick.conf será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm /etc/X11/xorg.conf.d/51-joystick.conf
	else
		texto="O arquivo 51-joystick.conf não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -e "/usr/share/applications/RStarJoystick.desktop" ]; then
		texto="O arquivo ../applications/RStarJoystick.desktop será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm /usr/share/applications/RStarJoystick.desktop
	else
		texto="O arquivo ../applications/RStarJoystick.desktop não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -e "/usr/share/applications/MudarControle.desktop" ]; then
		texto="O arquivo ../applications/MudarControle.desktop será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm /usr/share/applications/MudarControle.desktop
	else
		texto="O arquivo ../applications/MudarControle.desktop não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -e "/usr/share/applications/StopJoystick.desktop" ]; then
		texto="O arquivo ../applications/StopJoystick.desktop será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm /usr/share/applications/StopJoystick.desktop
	else
		texto="O arquivo ../applications/StopJoystick.desktop não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -e "/home/$SUDO_USER/Desktop/RStarJoystick.desktop" ]; then
		texto="O arquivo ../Desktop/RStarJoystick.desktop será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm /home/$SUDO_USER/Desktop/RStarJoystick.desktop
	else
		texto="O arquivo ../Desktop/RStarJoystick.desktop não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -e "/home/$SUDO_USER/Desktop/StopJoystick.desktop" ]; then
		texto="O arquivo ../Desktop/StopJoystick.desktop será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm /home/$SUDO_USER/Desktop/StopJoystick.desktop
	else
		texto="O arquivo ../Desktop/StopJoystick.desktop não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	if [ -e "/home/$SUDO_USER/Desktop/MudarControle.desktop" ]; then
		texto="O arquivo ../Desktop/MudarControle.desktop será removido..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		rm /home/$SUDO_USER/Desktop/MudarControle.desktop
	else
		texto="O arquivo ../Desktop/MudarControle.desktop não encontrado..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	fi
	cat /etc/sudoers | grep -q "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360"
	if [ "$?" = "1" ]; then
		texto="Configuração não encontrada.."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		reset
	else
		texto="A configuração será deletada..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		awk -F "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360" '{print $1}' /etc/sudoers > /tmp/temp.conf
		mv /tmp/temp.conf /etc/sudoers
		texto="Os arquivos foram removidos..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		reset
		apt remove -y xboxdrv antimicro evtest
		apt autoremove -y
		reset
	fi
	exit 0
	;;
	3)
	texto="Saindo do instalador..."
	cont="$[${#texto} + 4]"
	dialog --infobox "$texto" 3 $cont
	sleep 3
	reset
	exit 0
	;;
	*)
	texto="Instalação cancelada..."
	cont="$[${#texto} + 4]"
	dialog --infobox "$texto" 3 $cont
	sleep 3
	reset
	exit 0
	;;
esac
	
}

menu


exit 0
