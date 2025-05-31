#!/bin/bash

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
"1" "PARA INSTALAR" \
"2" "PARA REMOVER" \
"3" "PARA SAIR" \
--stdout)
clear
case $opcao in
	1)
	texto="PARA CONFIGURAÇÃO COM ANALÓGICO ESQUERDO COM SENTIDO INVERTIDO"
	cont="$[${#texto} + 10]"
	xbox=$(dialog --title "MENU" --menu "ESCOLHA A CONFIGURAÇÃO DESEJADA\n(SETAS PARA ESCOLHER E ENTER PARA CONFIRMAR)" 12 $cont 4 \
"1" "PARA CONFIGURAÇÃO PADRÃO" \
"2" "PARA CONFIGURAÇÃO COM ANALÓGICO ESQUERDO COM SENTIDO INVERTIDO" \
"3" "PARA CONFIGURAÇÃO COM ANALÓGICO DIREITO COM SENTIDO INVERTIDO" \
"4" "PARA CONFIGURAÇÃO COM 2 ANALÓGICOS COM SENTIDO INVERTIDO" \
--stdout)
	clear
	case $xbox in
		1|2|3|4)
		if [ -d "/usr/share/JoystickXbox360" ]; then
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
			mkdir /usr/share/JoystickXbox360
		fi
		;;
		1)
		cat <<EOF > /usr/share/JoystickXbox360/status.conf
configuração padrão...
EOF
		;;
		2)
		cat <<EOF > /usr/share/JoystickXbox360/status.conf
analógico esquerdo com sentido invertido...
EOF
		;;
		3)
		cat <<EOF > /usr/share/JoystickXbox360/status.conf
analógico direito com sentido invertido.
EOF
		;;
		4)
		cat <<EOF > /usr/share/JoystickXbox360/status.conf
2 analógicos com sentido invertido...
EOF
		;;
		*)
		texto="Configuração cancelada..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
		exit 0
		;;
	esac
	configuracao="$(cat /usr/share/JoystickXbox360/status.conf)"
	texto="Opção $xbox selecionada: $configuracao"
	cont="$[${#texto} + 4]"
	dialog --infobox "Instalação sendo iniciada...\n$texto" 4 $cont
	sleep 3
	clear
	if [ -e "/usr/share/JoystickXbox360/install.conf" ]; then
		texto="A instalação dos pacotes não será necessária..."
		cont="$[${#texto} + 4]"
		dialog --infobox "$texto" 3 $cont
		sleep 3
		clear
	else
		apt update && apt-get upgrade -y
		apt install -y xboxdrv antimicro dialog
	fi
	if [ -e "/usr/share/JoystickXbox360/install.conf" ]; then
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
		echo "Pacotes instalados xboxdrv antimicro" >\
		 /usr/share/JoystickXbox360/install.conf
	fi
	pkill xboxdrv &
	sleep 5
	i=0
	while true
	do
		udevadm info -a -n /dev/input/event$i > /usr/share/JoystickXbox360/joystick.log
		if ! [ "$(cat "/usr/share/JoystickXbox360/joystick.log")" ]; then
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
	xboxdrv --evdev /dev/input/event$jost --evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=y2,\
ABS_Z=x2,ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap BTN_TOP=x,\
BTN_TRIGGER=y,BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,\
BTN_TOP2=lb,BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent > /tmp/joystick.log &
	sleep 5
	i=0
	while true
	do
		udevadm info -a -n /dev/input/event$i > /usr/share/JoystickXbox360/joystick.log
		if ! [ "$(cat "/usr/share/JoystickXbox360/joystick.log")" ]; then
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
	case $xbox in
		1)
		cat <<EOF > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=y2,ABS_Z=x2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap BTN_TOP=x,\
BTN_TRIGGER=y,BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,\
BTN_TOP2=lb,BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
EOF
		;;
		2)
			cat <<EOF > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=y2,ABS_Z=x2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap Y1=Y1,Y2=Y2 --evdev-keymap BTN_TOP=x,BTN_TRIGGER=y,\
BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,BTN_TOP2=lb,\
BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
EOF
		;;
		3)
		cat <<EOF > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=x2,ABS_Z=y2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap BTN_TOP=x,BTN_TRIGGER=y,\
BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,BTN_TOP2=lb,\
BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
EOF
		;;
		4)
		cat <<EOF > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=x2,ABS_Z=y2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap Y1=Y1,Y2=Y2 --evdev-keymap BTN_TOP=x,BTN_TRIGGER=y,\
BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,BTN_TOP2=lb,\
BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
EOF
		;;
	esac
	joystickconf="$(cat /usr/share/JoystickXbox360/xboxdrv.conf)"
	fim="EOF"
	cat <<EOF > /usr/share/JoystickXbox360/MudarControle.sh
#!$SHELL

senha=\$(dialog --title "AUTORIZAÇÃO" --passwordbox "Digite a senha (SUDO):" 8 40 --stdout)
if [ -z "\$senha" ]; then
	dialog --title "ERRO" --infobox "A senha (SUDO) não foi digitada." 3 40
	sleep 3
	clear
	exit 1
fi
clear
echo \$senha|sudo -S -p "" chown $SUDO_USER:$SUDO_USER /usr/share/JoystickXbox360/joystick.log
sudo pkill xboxdrv &
sudo touch /usr/share/JoystickXbox360/joystick1.log
sudo chown $SUDO_USER:$SUDO_USER /usr/share/JoystickXbox360/joystick1.log
sudo chown $SUDO_USER:$SUDO_USER /usr/share/JoystickXbox360/joystickxbox360.conf
sudo chown $SUDO_USER:$SUDO_USER /usr/share/JoystickXbox360/status.conf
sudo chown $SUDO_USER:$SUDO_USER /usr/share/JoystickXbox360/xboxdrv.conf
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > /usr/share/JoystickXbox360/joystick.log
	if ! [ "\$(cat "/usr/share/JoystickXbox360/joystick.log")" ]; then
		clear
		texto="Porta do joystick não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		  /usr/share/JoystickXbox360/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		dialog --infobox "Porta do joystick localizada..." 3 35
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." >\
		  /usr/share/JoystickXbox360/joystickxbox360.conf
		jost=\$i
		break
	fi
	i=\$[ i + 1 ]
done
sleep 5
clear
texto="PARA CONFIGURAÇÃO COM ANALÓGICO ESQUERDO COM SENTIDO INVERTIDO"
cont="\$[\${#texto} + 10]"
xbox=\$(dialog --title "MENU" --menu "ESCOLHA A CONFIGURAÇÃO DESEJADA\n(SETAS PARA ESCOLHER E ENTER PARA CONFIRMAR)" 12 \$cont 4 \
"1" "PARA CONFIGURAÇÃO PADRÃO" \
"2" "PARA CONFIGURAÇÃO COM ANALÓGICO ESQUERDO COM SENTIDO INVERTIDO" \
"3" "PARA CONFIGURAÇÃO COM ANALÓGICO DIREITO COM SENTIDO INVERTIDO" \
"4" "PARA CONFIGURAÇÃO COM 2 ANALÓGICOS COM SENTIDO INVERTIDO" \
--stdout)
clear
case \$xbox in
	1)
	cat <<$fim > /usr/share/JoystickXbox360/status.conf
configuração padrão...
$fim
	cat <<$fim > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=y2,ABS_Z=x2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap BTN_TOP=x,\
BTN_TRIGGER=y,BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,\
BTN_TOP2=lb,BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
$fim
	;;
	2)
	cat <<$fim > /usr/share/JoystickXbox360/status.conf
analógico esquerdo com sentido invertido...
$fim
	cat <<$fim > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=y2,ABS_Z=x2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap Y1=Y1,Y2=Y2 --evdev-keymap BTN_TOP=x,BTN_TRIGGER=y,\
BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,BTN_TOP2=lb,\
BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
$fim
	;;
	3)
	cat <<$fim > /usr/share/JoystickXbox360/status.conf
analógico direito com sentido invertido...
$fim
	cat <<$fim > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=x2,ABS_Z=y2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap -Y1=Y1,-Y2=Y2 --evdev-keymap BTN_TOP=x,BTN_TRIGGER=y,\
BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,BTN_TOP2=lb,\
BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
$fim
	;;
	4)
	cat <<$fim > /usr/share/JoystickXbox360/status.conf
2 analógicos com sentido invertido...
$fim
	cat <<$fim > /usr/share/JoystickXbox360/xboxdrv.conf
--evdev-absmap ABS_X=x1,ABS_Y=y1,ABS_RZ=x2,ABS_Z=y2,\
ABS_HAT0X=dpad_x,ABS_HAT0Y=dpad_y --axismap Y1=Y1,Y2=Y2 --evdev-keymap BTN_TOP=x,BTN_TRIGGER=y,\
BTN_THUMB2=a,BTN_THUMB=b,BTN_BASE3=back,BTN_BASE4=start,BTN_BASE=lt,BTN_BASE2=rt,BTN_TOP2=lb,\
BTN_PINKIE=rb,BTN_BASE5=tl,BTN_BASE6=tr --mimic-xpad --silent
$fim
	;;
	*)
	texto="Configuração cancelada..."
	cont="\$[\${#texto} + 4]"
	dialog --infobox "\$texto" 3 \$cont
	sleep 3
	clear
	exit 0
	;;
esac
configuracao="opção \$xbox selecionada: \$(cat /usr/share/JoystickXbox360/status.conf)"
cont="\$[\${#configuracao} + 4]"
joystickconf="\$(cat /usr/share/JoystickXbox360/xboxdrv.conf)"
clear
dialog --infobox "Configuração sendo iniciada...\n\$configuracao" 4 \$cont
sudo chmod 775 /dev/input/event\$jost
sudo xboxdrv --evdev /dev/input/event\$jost \$joystickconf > /usr/share/JoystickXbox360/joystick1.log &
sudo rm /usr/share/JoystickXbox360/joystick1.log
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > /usr/share/JoystickXbox360/joystick.log
	if ! [ "\$(cat "/usr/share/JoystickXbox360/joystick.log")"" ]; then
		clear
		texto="Porta do joystick Xbox 360 emulado não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		dialog --infobox "Porta do joystick Xbox 360 emulado localizada..." 3 52
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		jost1=\$i
		break
	fi
	i=\$[ i + 1 ]
done
sudo chown root:root /usr/share/JoystickXbox360/joystick.log
sudo chown root:root /usr/share/JoystickXbox360/joystickxbox360.conf
sudo chown root:root /usr/share/JoystickXbox360/status.conf
sudo chown root:root /usr/share/JoystickXbox360/xboxdrv.conf
sudo chmod 775 /dev/input/event\$jost1
sleep 6
clear
sudo service joystickxbox360 status
sleep 6
clear
dialog --infobox "Teste o Joystick Xbox 360 emulado no AntiMicroX caso algum\n
dos analógicos ficar com sentido invertido,\
 use o aplicativo 'Muda a configuração do joystick Xbox 360': \n
opção escolhida agora - Opção \$xbox." 6 65

sleep 20
reset
antimicrox

exit 0

EOF
	cat <<EOF > /usr/share/JoystickXbox360/StartJoystick.sh
#!$SHELL

pkill xboxdrv &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > /usr/share/JoystickXbox360/joystick.log
	if ! [ "\$(cat "/usr/share/JoystickXbox360/joystick.log")" ]; then
		clear
		texto="Porta do joystick não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		echo -e "\nPorta do joystick localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		jost=\$i
		break
	fi
	i=\$[ i + 1 ]
done
joystickconf="\$(cat /usr/share/JoystickXbox360/xboxdrv.conf)"
xboxdrv --evdev /dev/input/event\$jost \$joystickconf > /tmp/joystick.log &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > /usr/share/JoystickXbox360/joystick.log
	if ! [ "\$(cat "/usr/share/JoystickXbox360/joystick.log")" ]; then
		clear
		texto="Porta do joystick Xbox 360 emulado não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		echo "Porta do joystick Xbox 360 emulado localizada..."
		echo -e "Joystick Xbox 360\033[32;1m iniciado\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		jost1=\$i
		break
	fi
	i=\$[ i + 1 ]
done
chmod 775 /dev/input/event\$jost1
sleep 2

exit 0

EOF
	cat <<EOF > /usr/share/JoystickXbox360/RStarJoystick.sh
#!$SHELL

pkill xboxdrv &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > /usr/share/JoystickXbox360/joystick.log
	if ! [ "\$(cat "/usr/share/JoystickXbox360/joystick.log")" ]; then
		clear
		texto="Porta do joystick não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Joystick"
	if [ "\$?" = "0" ]; then
		echo -e "\nPorta do joystick localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		jost=\$i
		break
	fi
	i=\$[ i + 1 ]
done
joystickconf="\$(cat /usr/share/JoystickXbox360/xboxdrv.conf)"
xboxdrv --evdev /dev/input/event\$jost \$joystickconf > /tmp/joystick.log &
sleep 5
i=0
while true
do
	udevadm info -a -n /dev/input/event\$i > /usr/share/JoystickXbox360/joystick.log
	if ! [ "\$(cat "/usr/share/JoystickXbox360/joystick.log")" ]; then
		clear
		texto="Porta do joystick Xbox 360 emulado não localizada..."
		cont="\$[\${#texto} + 4]"
		dialog --infobox "\$texto" 3 \$cont
		sleep 3
		clear
		echo -e "Joystick Xbox 360\033[31;1m falhou\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		exit 1
	fi
	udevadm info -a -n /dev/input/event\$i | grep -q "Microsoft X-Box 360 pad"
	if [ "\$?" = "0" ]; then
		echo "Porta do joystick Xbox 360 emulado localizada..."
		echo -e "Joystick Xbox 360\033[32;1m reiniciado\033[0m..." >\
		 /usr/share/JoystickXbox360/joystickxbox360.conf
		jost1=\$i
		break
	fi
	i=\$[ i + 1 ]
done
chmod 775 /dev/input/event\$jost1
echo -e "\033[31;1mAGUARDE...\033[0m"
sleep 60

exit 0

EOF
	if [ -d "/usr/share/pixmaps/JoystickXbox360" ]; then
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
		mkdir /usr/share/pixmaps/JoystickXbox360
		cat <<EOF > /usr/share/JoystickXbox360/xbox360
https://raw.githubusercontent.com/marxfcmonte/Instalador-do-emulador-de-\
joystick-Xbox-em-joystick-generico-de-PC-PS2-PS3-Debian-e-Derivados-antix-\
/refs/heads/main/Icones/xbox360.png
https://raw.githubusercontent.com/marxfcmonte/Instalador-do-emulador-de-\
joystick-Xbox-em-joystick-generico-de-PC-PS2-PS3-Debian-e-Derivados-antix-\
/refs/heads/main/Icones/xbox360preto.png
EOF
		wget -i /usr/share/JoystickXbox360/xbox360 -P /tmp/
		mv /tmp/xbox360.png /usr/share/pixmaps/JoystickXbox360
		mv /tmp/xbox360preto.png /usr/share/pixmaps/JoystickXbox360
	fi
	cat <<EOF > /usr/share/JoystickXbox360/StopJoystick.sh
#!$SHELL

pkill xboxdrv &
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
Exec=roxterm -e "bash -c /usr/share/JoystickXbox360/MudarControle.sh"
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
Exec=roxterm -e "sudo service joystickxbox360 restart"
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
Exec=roxterm -e "sudo service joystickxbox360 stop"
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
	dialog --infobox "Teste o Joystick Xbox 360 emulado no AntiMicroX caso algum\n
dos analógicos ficar com sentido invertido,\
 use o aplicativo 'Muda a configuração do joystick Xbox 360': \n
opção escolhida agora - Opção $xbox." 6 65
	sleep 20
	reset
	antimicrox
	;;
	2)
	if [ -d "/usr/share/JoystickXbox360" ]; then
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
	if [ -d "/usr/share/pixmaps/JoystickXbox360" ]; then
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
		apt remove -y xboxdrv antimicro
		apt autoremove -y
		reset
	fi
	;;
	3)
	texto="Saindo do instalador..."
	cont="$[${#texto} + 4]"
	dialog --infobox "$texto" 3 $cont
	sleep 3
	reset
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

exit 0
