#!/bin/bash

trim() {
	# Desabilitação da verificação do shell=2048,2086
    set -f
    set -- $*
    printf '%s\n' "${*//[[:space:]]/}"
    set +f
}

Ppid(){
	# Obter o ID do processo pai do PID
	ppid="$(grep -i -F "PPid:" "/proc/${1:-$PPID}/status")"
    ppid="$(trim "${ppid/PPid:}")"
    printf "%s" "$ppid"

}

processo_nome() {
    # Obter nome PID.
    nome="$(< "/proc/${1:-$PPID}/comm")"
    printf "%s" "$nome"
}

terminal() {
    # Verificando $PPID para emulador de terminal.
     while [[ -z "$term" ]]; do
        pai="$(Ppid "$pai")"
        [[ -z "$pai" ]] && break
        nome="$(processo_nome "$pai")"

        case ${nome// } in
            "${SHELL/*\/}"|*"sh"|"screen"|"su"*) ;;

            "login"*|*"Login"*|"init"|"(init)")
                term="$(tty)"
            ;;

            "ruby"|"1"|"tmux"*|"systemd"|"sshd"*|"python"*|"USER"*"PID"*|"kdeinit"*|"launchd"*)
                break
            ;;

            "gnome-terminal-") term="gnome-terminal" ;;
            "urxvtd")          term="urxvt" ;;
            *"nvim")           term="Neovim Terminal" ;;
            *"NeoVimServer"*)  term="VimR Terminal" ;;

            *)
                # Corrigir problemas com nomes longos de processos no Linux.
                term="${nome##*/}"
            ;;
        esac
    done
}

display_principal(){
	cont="$[${#texto} + 4]"
	dialog --infobox "$texto" 3 $cont
	sleep 3
	clear
}

terminal

if [ "$USER" != "root" ]; then
	echo "Use comando 'sudo'  ou comando 'su' antes de inicializar o programa."
	exit 1
fi

if ! [ -e "/usr/bin/dialog" ]; then
	echo -e "Dialog não instalado e será instalado...\n"
	apt install -y dialog
fi

pasta_joystick=/usr/share/JoystickXbox360
pasta_icones=/usr/share/pixmaps/JoystickXbox360
texto="Instalador do emulador de joystick Xbox 360 v 1.8.1 (2025)"
cont="$[${#texto} + 4]"
dialog --title "Desenvolvedor" --infobox "Desenvolvido por Marx F. C. Monte\n
Instalador do emulador de joystick Xbox 360 v 1.8.1 (2025)\n
Para a Distribuição Debian 12 e derivados (antiX 23)" 5 $cont
sleep 3
clear
texto="SETAS PARA ESCOLHER E ENTER PARA CONFIRMAR"
cont="$[${#texto} + 4]"
opcao=$(dialog --title "MENU" --menu "$texto" 10 $cont 3 \
"1" "INSTALAR" \
"2" "REMOVER" \
"3" "SAIR" \
--stdout)
clear
case $opcao in
	1)
	texto="PARA CONFIGURAÇÃO COM ANALÓGICOS COM SENTIDO INVERTIDO"
	cont="$[${#texto} + 10]"
	xbox=$(dialog --title "MENU" --menu "ESCOLHA A CONFIGURAÇÃO DESEJADA\n(SETAS PARA ESCOLHER E ENTER PARA CONFIRMAR)" 10 $cont 2 \
"1" "PARA CONFIGURAÇÃO PADRÃO" \
"2" "PARA CONFIGURAÇÃO COM ANALÓGICOS COM SENTIDO INVERTIDO" \
--stdout)
	clear
	case $xbox in
		1|2)
		if [ -d "/usr/share/JoystickXbox360" ]; then
			texto="O diretório JoystickXbox360 existe..."
			display_principal
		else
			texto="O diretório JoystickXbox360 será criado..."
			display_principal
			mkdir $pasta_joystick
		fi
		;;
		*)
		texto="Configuração cancelada..."
		display_principal
		exit 0
	esac
	case $xbox in
		1)
		cat <<EOF > $pasta_joystick/status.conf
configuração padrão...
EOF
		;;
		2)
		cat <<EOF > $pasta_joystick/status.conf
analógicos com sentido invertido...
EOF
		;;
	esac
	configuracao="$(cat $pasta_joystick/status.conf)"
	texto="Opção $xbox selecionada: $configuracao"
	display_principal
	if [ -e "$pasta_joystick/install.conf" ]; then
		texto="A instalação dos pacotes não será necessária..."
		display_principal
	else
		apt update && apt-get upgrade -y
		apt install -y xboxdrv antimicro dialog evtest
	fi
	if [ -e "$pasta_joystick/install.conf" ]; then
		texto="O arquivo install.conf existe..."
		display_principal
	else
		texto="O arquivo install.conf será criado..."
		display_principal
		echo "Pacotes instalados xboxdrv antimicro" > $pasta_joystick/install.conf
	fi
	pkill xboxdrv &
	sleep 5
	i=0
	while true
	do
		udevadm info -a -n /dev/input/event$i > $pasta_joystick/joystick.log
		if ! [ "$(cat $pasta_joystick/joystick.log)" ]; then
			clear
			texto="Porta do joystick não localizada..."
			display_principal
			exit 1
		fi
		udevadm info -a -n /dev/input/event$i | grep -q "Joystick"
		if [ "$?" = "0" ]; then
			texto="Porta do joystick localizada..."
			display_principal
			evtest /dev/input/event$i > /usr/share/JoystickXbox360/controle.conf & pkill evtest
			cat /usr/share/JoystickXbox360/controle.conf | grep -n exit | cut -d ":" -f1 > /usr/share/JoystickXbox360/numero.conf
			numero="$(cat $pasta_joystick/numero.conf)"
			sed -n "1,$numero p" /usr/share/JoystickXbox360/controle.conf >  /usr/share/JoystickXbox360/controle2.conf
			cat /usr/share/JoystickXbox360/controle2.conf | grep ABS_ | cut -d "(" -f2 > /usr/share/JoystickXbox360/controle1.conf
			cat /usr/share/JoystickXbox360/controle2.conf | grep BTN_ | cut -d "(" -f2 >> /usr/share/JoystickXbox360/controle1.conf
			cat /usr/share/JoystickXbox360/controle1.conf | grep ")" | cut -d ")" -f1 > /usr/share/JoystickXbox360/controle.conf
			rm /usr/share/JoystickXbox360/controle1.conf /usr/share/JoystickXbox360/controle2.conf
			var=($(cat $pasta_joystick/controle.conf))
			sleep 3
			clear
			jost=$i
			break
		fi
		i=$[ i + 1 ]
	done
	chmod 664 /dev/input/event$jost
	xboxdrv --evdev /dev/input/event$jost --evdev-absmap ${var[0]}=x1,${var[1]}=y1,${var[2]}=x2,${var[3]}=y2,\
${var[4]}=dpad_x,${var[5]}=dpad_y --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap ${var[6]}=y,${var[7]}=b,\
${var[8]}=a,${var[9]}=x,${var[10]}=lb,${var[11]}=rb,${var[12]}=lt,${var[13]}=rt,${var[14]}=back,${var[15]}=start,\
${var[16]}=tl,${var[17]}=tr --mimic-xpad --silent > /tmp/joystick.log &
	sleep 5
	i=0
	while true
	do
		udevadm info -a -n /dev/input/event$i > $pasta_joystick/joystick.log
		if ! [ "$(cat $pasta_joystick/joystick.log)" ]; then
			clear
			texto="Porta do joystick Xbox 360 emulado não localizada..."
			display_principal
			exit 1
		fi
		udevadm info -a -n /dev/input/event$i | grep -q "Microsoft X-Box 360 pad"
		if [ "$?" = "0" ]; then
			texto="Porta do joystick Xbox 360 emulado localizada..."
			display_principal
			jost1=$i
			break
		fi
		i=$[ i + 1 ]
	done
	chmod 664 /dev/input/event$jost1
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
	case $xbox in
		1)
		cat <<EOF > $pasta_joystick/xboxdrv.conf
--evdev-absmap ${var[0]}=x1,${var[1]}=y1,${var[2]}=x2,${var[3]}=y2,\
${var[4]}=dpad_x,${var[5]}=dpad_y --axismap X1=X1,X2=X2,-Y1=Y1,-Y2=Y2,DPAD_X=DPAD_X,DPAD_Y=DPAD_Y --evdev-keymap ${var[6]}=y,${var[7]}=b,\
${var[8]}=a,${var[9]}=x,${var[10]}=lb,${var[11]}=rb,${var[12]}=lt,${var[13]}=rt,${var[14]}=back,${var[15]}=start,\
${var[16]}=tl,${var[17]}=tr --mimic-xpad --silent
EOF
		;;
		2)
		cat <<EOF > $pasta_joystick/xboxdrv.conf
--evdev-absmap ${var[0]}=x1,${var[1]}=y1,${var[2]}=x2,${var[3]}=y2,\
${var[4]}=dpad_x,${var[5]}=dpad_y --axismap X1=X1,X2=X2,Y1=Y1,Y2=Y2,DPAD_X=DPAD_X,DPAD_Y=DPAD_Y --evdev-keymap ${var[6]}=y,${var[7]}=b,\
${var[8]}=a,${var[9]}=x,${var[10]}=lb,${var[11]}=rb,${var[12]}=lt,${var[13]}=rt,${var[14]}=back,${var[15]}=start,\
${var[16]}=tl,${var[17]}=tr --mimic-xpad --silent
EOF
		;;
	esac
	joystickconf="$(cat /usr/share/JoystickXbox360/xboxdrv.conf)"
	fim="EOF"
	cat <<EOF > $pasta_joystick/MudarControle.sh
#!$SHELL

display_principal(){
	cont="\$[\${#texto} + 4]"
	dialog --infobox "\$texto" 3 \$cont
	sleep 3
	clear
}

cancelar_principal(){
	if [ "\$validacao" = "1" ]; then
		texto="Cancelado pelo usuário."
		display_principal
		sudo chown root:root \$pasta_joystick/*.log
		sudo chown root:root \$pasta_joystick/*.conf
		sudo service joystickxbox360 restart 
		exit 0
	fi
}

pasta_joystick=/usr/share/JoystickXbox360

while true
do
	senha=\$(dialog --title "AUTORIZAÇÃO" --passwordbox "Digite a senha (SUDO):" 8 40 --stdout)
	validacao="\$?"
	cancelar_principal
	if [ -z "\$senha" ]; then
		dialog --colors --title "\Zr\Z1  ERRO                               \Zn" --infobox "A senha (SUDO) não foi digitada." 3 37
		sleep 2
		clear
	else
		break
	fi
done
clear
echo \$senha|sudo -S -p "" chown \$USER:\$USER \$pasta_joystick/*.log
sudo pkill xboxdrv &
sudo touch \$pasta_joystick/joystick1.log
sudo chown \$USER:\$USER \$pasta_joystick/joystick1.log
sudo chown \$USER:\$USER \$pasta_joystick/*.conf
sudo touch \$pasta_joystick/controle1.conf
sudo chown \$USER:\$USER \$pasta_joystick/controle1.conf
sudo touch \$pasta_joystick/controle2.conf
sudo chown \$USER:\$USER \$pasta_joystick/controle2.conf
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > \$pasta_joystick/joystick.log
	if ! [ "\$(cat \$pasta_joystick/joystick.log)" ]; then
		clear
		texto="Porta do joystick não localizada..."
		display_principal
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		texto="Porta do joystick localizada..."
		display_principal
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		jost=\$i
		sudo evtest /dev/input/event\$i > \$pasta_joystick/controle.conf & sudo pkill evtest
		cat \$pasta_joystick/controle.conf | grep -n exit | cut -d ":" -f1 > \$pasta_joystick/numero.conf
		numero="\$(cat /usr/share/JoystickXbox360/numero.conf)"
		sed -n "1,\$numero p" \$pasta_joystick/controle.conf >  \$pasta_joystick/controle2.conf
		cat \$pasta_joystick/controle2.conf | grep ABS_ | cut -d "(" -f2 > \$pasta_joystick/controle1.conf
		cat \$pasta_joystick/controle2.conf | grep BTN_ | cut -d "(" -f2 >> \$pasta_joystick/controle1.conf
		cat \$pasta_joystick/controle1.conf | grep ")" | cut -d ")" -f1 > \$pasta_joystick/controle.conf
		sudo rm \$pasta_joystick/controle1.conf \$pasta_joystick/controle2.conf
		var=(\$(cat \$pasta_joystick/controle.conf))
		sleep 3
		clear
		break
	fi
	i=\$[ i + 1 ]
done
sleep 5
clear
texto="PARA CONFIGURAÇÃO COM ANALÓGICOS COM SENTIDO INVERTIDO"
cont="\$[\${#texto} + 10]"
xbox=\$(dialog --title "MENU" --menu "ESCOLHA A CONFIGURAÇÃO DESEJADA\n(SETAS PARA ESCOLHER E ENTER PARA CONFIRMAR)" 10 \$cont 4 \
"1" "CONFIGURAÇÃO PADRÃO" \
"2" "CONFIGURAÇÃO COM ANALÓGICOS COM SENTIDO INVERTIDO" \
--stdout)
clear
case \$xbox in
	1)
	cat <<$fim > \$pasta_joystick/status.conf
configuração padrão...
$fim
	cat <<$fim > \$pasta_joystick/xboxdrv.conf
--evdev-absmap \${var[0]}=x1,\${var[1]}=y1,\${var[2]}=x2,\${var[3]}=y2,\
\${var[4]}=dpad_x,\${var[5]}=dpad_y --axismap X1=X1,X2=X2,-Y1=Y1,-Y2=Y2,DPAD_X=DPAD_X,DPAD_Y=DPAD_Y --evdev-keymap \${var[6]}=y,\${var[7]}=b,\
\${var[8]}=a,\${var[9]}=x,\${var[10]}=lb,\${var[11]}=rb,\${var[12]}=lt,\${var[13]}=rt,\${var[14]}=back,\${var[15]}=start,\
\${var[16]}=tl,\${var[17]}=tr --mimic-xpad --silent
$fim
	;;
	2)
	cat <<$fim > \$pasta_joystick/status.conf
analógicos com sentido invertido...
$fim
	cat <<$fim > \$pasta_joystick/xboxdrv.conf
--evdev-absmap \${var[0]}=x1,\${var[1]}=y1,\${var[2]}=x2,\${var[3]}=y2,\
\${var[4]}=dpad_x,\${var[5]}=dpad_y --axismap X1=X1,X2=X2,Y1=Y1,Y2=Y2,DPAD_X=DPAD_X,DPAD_Y=DPAD_Y --evdev-keymap \${var[6]}=y,\${var[7]}=b,\
\${var[8]}=a,\${var[9]}=x,\${var[10]}=lb,\${var[11]}=rb,\${var[12]}=lt,\${var[13]}=rt,\${var[14]}=back,\${var[15]}=start,\
\${var[16]}=tl,\${var[17]}=tr --mimic-xpad --silent
$fim
	;;
	*)
	texto="Configuração cancelada..."
	display_principal
	sudo chown root:root \$pasta_joystick/*.log
	sudo chown root:root \$pasta_joystick/*.conf
	sudo service joystickxbox360 restart 
	exit 0
	;;
esac
configuracao="opção \$xbox selecionada: \$(cat \$pasta_joystick/status.conf)"
cont="\$[\${#configuracao} + 4]"
joystickconf="\$(cat \$pasta_joystick/xboxdrv.conf)"
clear
dialog --infobox "Configuração sendo iniciada...\n\$configuracao" 4 \$cont
sudo chmod 664 /dev/input/event\$jost
sudo xboxdrv --evdev /dev/input/event\$jost \$joystickconf > \$pasta_joystick/joystick1.log &
sudo rm \$pasta_joystick/joystick1.log
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > \$pasta_joystick/joystick.log
	if ! [ "\$(cat \$pasta_joystick/joystick.log)" ]; then
		clear
		texto="Porta do joystick Xbox 360 emulado não localizada..."
		display_principal
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		texto="Porta do joystick Xbox 360 emulado localizada..."
		display_principal
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		jost1=\$i
		break
	fi
	i=\$[ i + 1 ]
done
sudo chown root:root \$pasta_joystick/*.log
sudo chown root:root \$pasta_joystick/*.conf
sudo chmod 664 /dev/input/event\$jost1
sleep 6
clear
sudo service joystickxbox360 status
sleep 6
clear
dialog --nocancel --pause "Teste o Joystick Xbox 360 emulado no AntiMicroX caso\n
os analógicos ficarem com sentido invertido,\
 use o aplicativo 'Muda a configuração do joystick Xbox 360': \n
opção escolhida agora - Opção \$xbox." 11 65 20

reset
antimicrox

exit 0

EOF
	cat <<EOF > $pasta_joystick/StartJoystick.sh
#!$SHELL

pasta_joystick=/usr/share/JoystickXbox360

pkill xboxdrv &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > \$pasta_joystick/joystick.log
	if ! [ "\$(cat /usr/share/JoystickXbox360/joystick.log)" ]; then
		clear
		echo -e "\nPorta do joystick não localizada..."
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		echo -e "\nPorta do joystick localizada..."
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		jost=\$i
		break
	fi
	i=\$[ i + 1 ]
done
chmod 664 /dev/input/event\$jost
joystickconf="\$(cat \$pasta_joystick/xboxdrv.conf)"
xboxdrv --evdev /dev/input/event\$jost \$joystickconf > /tmp/joystick.log &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > \$pasta_joystick/joystick.log
	if ! [ "\$(cat /usr/share/JoystickXbox360/joystick.log)" ]; then
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		echo "Porta do joystick Xbox 360 emulado localizada..."
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		jost1=\$i
		break
	fi
	i=\$[ i + 1 ]
done
chmod 664 /dev/input/event\$jost1
sleep 2

exit 0

EOF
	cat <<EOF > $pasta_joystick/RStarJoystick.sh
#!$SHELL

display_principal(){
	cont="\$[\${#texto} + 4]"
	dialog --infobox "\$texto" 3 \$cont
	sleep 3
	clear
}

pasta_joystick=/usr/share/JoystickXbox360

pkill xboxdrv &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > \$pasta_joystick/joystick.log
	if ! [ "\$(cat \$pasta_joystick/joystick.log)" ]; then
		clear
		texto="Porta do joystick não localizada..."
		display_principal
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		echo -e "\nPorta do joystick localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		jost=\$i
		break
	fi
	i=\$[ i + 1 ]
done
joystickconf="\$(cat \$pasta_joystick/xboxdrv.conf)"
xboxdrv --evdev /dev/input/event\$jost \$joystickconf > /tmp/joystick.log &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > \$pasta_joystick/joystick.log
	if ! [ "\$(cat /usr/share/JoystickXbox360/joystick.log)" ]; then
		clear
		texto="Porta do joystick Xbox 360 emulado não localizada..."
		display_principal
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		echo "Porta do joystick Xbox 360 emulado localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." > \$pasta_joystick/joystickxbox360.conf
		jost1=\$i
		sleep 3
		break
	fi
	i=\$[ i + 1 ]
done
chmod 664 /dev/input/event\$jost1
texto="\Z1AGUARDE...\Zn PARA O JOYSTICK SER RECONHECIDO."
cont="\$[\${#texto} + 4]"
dialog --colors --nocancel --pause "\$texto" 8 \$cont 60
clear

exit 0

EOF
	if [ -d "$pasta_icones" ]; then
		texto="O diretório para os icones já existe..."
		display_principal
	else
		texto="O diretório para os icones será criado..."
		display_principal
		mkdir $pasta_icones
		cat <<EOF > $pasta_joystick/xbox360
https://raw.githubusercontent.com/marxfcmonte/Instalador-do-emulador-de-\
joystick-Xbox-em-joystick-generico-de-PC-PS2-PS3-Debian-e-Derivados-antix-\
/refs/heads/main/Icones/xbox360.png
https://raw.githubusercontent.com/marxfcmonte/Instalador-do-emulador-de-\
joystick-Xbox-em-joystick-generico-de-PC-PS2-PS3-Debian-e-Derivados-antix-\
/refs/heads/main/Icones/xbox360preto.png
EOF
		wget -i $pasta_joystick/xbox360 -P /tmp/
		mv /tmp/xbox360.png $pasta_icones
		mv /tmp/xbox360preto.png $pasta_icones
	fi
	cat <<EOF > $pasta_joystick/StopJoystick.sh
#!$SHELL

pasta_joystick=/usr/share/JoystickXbox360

pkill xboxdrv &
sleep 2
echo -e "Joystick Xbox 360\033[31;1m parado\033[0m..." > \$pasta_joystick/joystickxbox360.conf
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
	display_principal
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
	$pasta_joystick/StartJoystick.sh
	cat $pasta_joystick/joystickxbox360.conf
	;;
  stop)
	$pasta_joystick/StopJoystick.sh
	;;
  restart)
	$pasta_joystick/RStarJoystick.sh
	cat $pasta_joystick/joystickxbox360.conf
	;;
  status)
	cat $pasta_joystick/joystickxbox360.conf
	;;
esac

exit 0

EOF
	chmod +x /etc/init.d/joystickxbox360
	update-rc.d joystickxbox360 defaults
	cat /etc/sudoers | grep -q "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360"
	if [ "$?" = "1" ]; then
		texto="As configurações serão atualizadas..."
		display_principal
		sed '/^$/d' /etc/sudoers > /tmp/temp.conf && mv /tmp/temp.conf /etc/sudoers
		echo "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360" >> /etc/sudoers
	else
		texto="As configurações estão atualizadas..."
		display_principal
	fi
	reset
	desktop-menu --write-out-global
	texto="Testanto o serviço Joystickxbox360"
	display_principal
	service joystickxbox360 start
	sleep 6
	clear
	dialog --nocancel --pause "Teste o Joystick Xbox 360 emulado no AntiMicroX caso\n
os analógicos ficarem com sentido invertido,\
 use o aplicativo 'Muda a configuração do joystick Xbox 360': \n
opção escolhida agora - Opção $xbox." 11 65 20
	reset
	antimicrox
	;;
	2)
	if [ -d "$pasta_joystick" ]; then
		texto="O diretório JoystickXbox360 será removido..."
		display_principal
		service joystickxbox360 stop
		update-rc.d joystickxbox360 remove
		rm -rf $pasta_joystick
		rm /etc/init.d/joystickxbox360
	else
		texto="O diretório JoystickXbox360 não encontrado..."
		display_principal
	fi
	if [ -d "$pasta_icones" ]; then
		texto="O diretório ../pixmaps/JoystickXbox360 será removido..."
		display_principal
		rm -rf $pasta_icones
	else
		texto="O diretório ../pixmaps/JoystickXbox360 não encontrado..."
		display_principal
	fi
	if [ -e "/etc/X11/xorg.conf.d/51-joystick.conf" ]; then
		texto="O arquivo 51-joystick.conf será removido..."
		display_principal
		rm /etc/X11/xorg.conf.d/51-joystick.conf
	else
		texto="O arquivo 51-joystick.conf não encontrado..."
		display_principal
	fi
	if [ -e "/usr/share/applications/RStarJoystick.desktop" ]; then
		texto="O arquivo ../applications/RStarJoystick.desktop será removido..."
		display_principal
		rm /usr/share/applications/RStarJoystick.desktop
	else
		texto="O arquivo ../applications/RStarJoystick.desktop não encontrado..."
		display_principal
		clear
	fi
	if [ -e "/usr/share/applications/MudarControle.desktop" ]; then
		texto="O arquivo ../applications/MudarControle.desktop será removido..."
		display_principal
		rm /usr/share/applications/MudarControle.desktop
	else
		texto="O arquivo ../applications/MudarControle.desktop não encontrado..."
		display_principal
	fi
	if [ -e "/usr/share/applications/StopJoystick.desktop" ]; then
		texto="O arquivo ../applications/StopJoystick.desktop será removido..."
		display_principal
		rm /usr/share/applications/StopJoystick.desktop
	else
		texto="O arquivo ../applications/StopJoystick.desktop não encontrado..."
		display_principal
	fi
	if [ -e "/home/$SUDO_USER/Desktop/RStarJoystick.desktop" ]; then
		texto="O arquivo ../Desktop/RStarJoystick.desktop será removido..."
		display_principal
		rm /home/$SUDO_USER/Desktop/RStarJoystick.desktop
	else
		texto="O arquivo ../Desktop/RStarJoystick.desktop não encontrado..."
		display_principal
	fi
	if [ -e "/home/$SUDO_USER/Desktop/StopJoystick.desktop" ]; then
		texto="O arquivo ../Desktop/StopJoystick.desktop será removido..."
		display_principal
		rm /home/$SUDO_USER/Desktop/StopJoystick.desktop
	else
		texto="O arquivo ../Desktop/StopJoystick.desktop não encontrado..."
		display_principal
		clear
	fi
	if [ -e "/home/$SUDO_USER/Desktop/MudarControle.desktop" ]; then
		texto="O arquivo ../Desktop/MudarControle.desktop será removido..."
		cdisplay_principal
		rm /home/$SUDO_USER/Desktop/MudarControle.desktop
	else
		texto="O arquivo ../Desktop/MudarControle.desktop não encontrado..."
		display_principal
		clear
	fi
	cat /etc/sudoers | grep -q "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360"
	if [ "$?" = "1" ]; then
		texto="Configuração não encontrada.."
		display_principal
	else
		texto="A configuração será deletada..."
		display_principal
		awk -F "$SUDO_USER ALL=NOPASSWD: /etc/init.d/joystickxbox360" '{print $1}' /etc/sudoers > /tmp/temp.conf
		mv /tmp/temp.conf /etc/sudoers
		texto="Os arquivos foram removidos..."
		display_principal
		apt remove -y xboxdrv antimicro evtest
		apt autoremove -y
	fi
	;;
	3)
	texto="Saindo do instalador..."
	display_principal
	;;
	*)
	texto="Instalação cancelada..."
	display_principal
	;;
esac

reset

exit 0
