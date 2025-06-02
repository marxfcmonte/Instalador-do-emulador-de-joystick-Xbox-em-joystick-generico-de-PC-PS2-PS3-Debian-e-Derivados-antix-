# Instalador do emulador de joystick Xbox para joystick generico para PC, PS2, PS3 (Debian e Derivados antiX)

Os arquivos InstallJoystickXbox360.sh, InstallJoystickXbox360 e InstallJoystickXbox.deb  devem ser executados no terminal como root, usando o comando sudo ou su. O Programa reconhe joysticks genéricos USB e joysticks genéricos sem fio que usam receptor (wireless) que se conecta na porta USB.

Ele desenvolve três softwares, um para restabelecer a emulação do joystick Xbox 360, um para encerrar o serviço de emulação do joystick Xbox 360 e, por fim, um para configurar o joystick. Além disso, permite que o serviço de emulação do joystick Xbox 360 seja iniciado automaticamente com a inicialização do sistema. (SysV)

Cria atalhos para a Área de trabalho e no menu dos aplicativos do sistema.

## Dependências

- xboxdrv
- antimicro
- evtest
- dialog (A dependênia **dialog** é nativa em diversas distribuições baseadas em Debian, caso não haja será instalada.)
- roxterm (A dependênia **roxterm** é nativa em diversas distribuições baseadas em Debian, caso não haja será instalada)

## Totalmente automatizado.

Ele reconhece o joystick e faz as configurações, apenas solicitando do usuário o perfil do joystick.

Agora com pacote Deb, InstallJoystickXbox.deb, para uma instalação automatizada pelo gerenciador de pacotes Deb sem precisar do terminal.
