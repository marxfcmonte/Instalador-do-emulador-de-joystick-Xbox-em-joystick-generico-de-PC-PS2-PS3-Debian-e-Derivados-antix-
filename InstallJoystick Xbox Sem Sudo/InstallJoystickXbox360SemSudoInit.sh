#!/bin/bash

if ! [ -e "/usr/bin/dialog" ]; then
	senha=read -p "Dialog não instalado, digite a senha (SUDO): "
	echo $senha|sudo -S -p "" apt install -y dialog
else
	senha=$(dialog --title "AUTORIZAÇÃO" --passwordbox "Digite a senha (SUDO):" 8 40 --stdout)
fi

if [ -z "$senha" ]; then
	dialog --title "ERRO" --infobox "A senha (SUDO) não foi digitada." 3 40
	sleep 3
	clear
	exit 1
fi
clear

local="$(pwd)"

if ! [ -e "$local/InstalljoystickXbox360SemSudo" ]; then
	if ! [ -e "/bin/shc" ]; then
		echo $senha|sudo -S -p "" apt install -y shc libc6-dev
		shc -f "$local/InstallJoystickXbox360SemSudo.sh" -o "$local/InstalljoystickXbox360SemSudo"
		sudo bash -c "$local/InstalljoystickXbox360SemSudo"
	else
		shc -f "$local/InstallJoystickXbox360SemSudo.sh" -o "$local/InstalljoystickXbox360SemSudo"
		echo $senha|sudo -S -p "" bash -c "$local/InstalljoystickXbox360SemSudo"
	fi
fi

