:: https://github.com/Tlem33/ConfigLan4Imax3D
:: ConfigLan4Imax3D.cmd - Version 1.0 du 25/11/2020
::
@Echo Off
Cls

:: Pour éviter les problèmes de chemins
SET PATH=%PATH%;%WINDIR%\System32;%WINDIR%\System32\wbem


:: Se place dans le dossier du batch.
:: Si le batch est lancé à partir du réseau, crée un lecteur virtuel.
Pushd "%~dp0"


:: Demande des droits administrateur
Call :GetAdminRight


:: Menu des actions :
:Menu
Cls
Echo     ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo     º                    MENU PRINCIPAL                     º
Echo     ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo.
Echo.
Echo Veuillez choisir l'action … r‚aliser :
Echo.
Echo.
Echo     1 - D‚sactivation du client GigE Vision Filter Driver
Echo.
Echo     2 - D‚sactivation du protocole IPV6 sur une connexion
Echo.
Echo     3 - Voir l'‚tat GigE et IPV6 sur toutes les cartes r‚seau
Echo.
Echo     4 - Quitter
Echo.
Echo.
Set /p Exec="Entrez votre choix (1, 2, 3 ou 4) : "
If /I "%Exec%"=="" Goto :Menu
If /I "%Exec%"=="1" Goto :DisableGigE
If /I "%Exec%"=="2" Goto :DisableIPV6
If /I "%Exec%"=="3" Goto :CheckState
If /I "%Exec%"=="4" Exit
Goto Menu


:: Désactivation de GigE
:DisableGigE
Cls
Set /p Tempo="Entrez la dur‚e en seconde de la temporisation (laissez vide pour action imm‚diate) : "
If /I "%Tempo%"=="" Goto :DisableGigEExec


:: Test si la valeur entrée est un nombre
For /f "Delims=0123456789" %%§ in ("%Tempo%") Do (
    Goto :DisableGigE
   )

:: Temporisation
Echo D‚sactivation de GigE dans %tempo% secondes.
Ping -n %Tempo% 127.0.0.1>Nul


:DisableGigEExec
Cls
Echo.
Echo                                   ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                                   º     D‚sactivation de GigE en cours      º
Echo                                   º  Veuillez patienter quelques instants   º
Echo                                   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo.

Powershell Disable-NetAdapterBinding -Name * -ComponentID "ois_gigevflt"
Echo D‚sactivation termin‚e.
Echo Verifiez dans le tableau ci-dessous que les valeurs de la
Echo colonne Enabled soient … False pour toutes les interfaces.
Powershell Get-NetAdapterBinding -Name *  -ComponentID "ois_gigevflt"
Pause
Goto Menu


:: Désactivation de l'IPV6
:DisableIPV6
Cls
Echo     ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo     º                 Liste des interfaces r‚seau disponibles :                 º
Echo     ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
For /F "Skip=3 Tokens=1,4,5* Delims= " %%a in ('Netsh.exe interface ipv4 show interface^|findstr /I /V /C:"Loopback"') Do (
	Set /A Count+=1
	Echo     Index = %%a		Nom = %%c %%d		Etat = %%b
)
Echo.


:: Choix de l'index de l'interface.
Set /p LanIdx="Veuillez entrer le num‚ro d'index de la carte … modifier : "
If /I "%LanIdx%"=="" Goto :DisableIPV6


:: Test si la valeur entrée est un nombre
For /f "Delims=0123456789" %%§ in ("%LanIdx%") Do (
    Goto :DisableIPV6
   )


:GetInterfaceName
Set SpaceString= String with beginning space
:: Recherche du nom de la carte par rapport a l'index.
Setlocal EnableDelayedExpansion
For /F "Tokens=1-4,5* Delims= " %%a in ('Netsh.exe interface ipv4 show interface') Do (
	If %%a==%LanIdx% (
		If Not "%%f"=="" Set Space=%SpaceString:~0,1%
		Set AdapterName=%%e!Space!%%f
		)
)


:: Verifie que le nom ne soit pas vide.
If "%AdapterName%"=="" (
 Color 0C
 Echo Erreur sur la r‚cup‚ration du nom de la carte
 Echo Appuyez sur une touche pour quitter
 Pause>NUL
 Goto :DisableIPV6
)


:CheckInsterface
:: Vérifie les parametres de l'interface.
Netsh.exe interface ipv4 show interface "%AdapterName%">NUL
If errorlevel 1 (
 Color 0C
 Echo Le nom "%AdapterName%" ne correspond pas … une interface r‚seau valide !
 Echo Appuyez sur une touche pour quitter
 Pause>NUL
 Exit
)

Echo D‚sactivation de l'IPV6 sur la carte %AdapterName%
Set /p Exec="Confirmez votre choix (o, n) : "
If /I "%Exec%"=="" Goto :DisableIPV6
If /I "%Exec%"=="o" Goto :ExecDisableIPV6
If /I "%Exec%"=="n" Goto :Menu
Goto :DisableIPV6


:ExecDisableIPV6
Cls
Echo.
Echo                                   ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
Echo                                   º     D‚sactivation de l'IPV6 en cours      º
Echo                                   º  Veuillez patienter quelques instants     º
Echo                                   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
Echo.
Echo.

Powershell Disable-NetAdapterBinding -Name '"%AdapterName%"' -ComponentID "ms_tcpip6"
Echo D‚sactivation termin‚e.
Echo Verifiez dans la ligne ci-dessous que Enabled soit … False pour l'interfaces.
Powershell Get-NetAdapterBinding -Name '"%AdapterName%"'  -ComponentID "ms_tcpip6"
Pause
Goto Menu


:CheckState
Cls
Echo Etat du client GigE sur l'ensemble des cartes r‚seau :
Powershell Get-NetAdapterBinding -Name *  -ComponentID "ois_gigevflt"
Echo Etat du protocole IPV6 sur l'ensemble des cartes r‚seau :
Powershell Get-NetAdapterBinding -Name *  -ComponentID "ms_tcpip6"
Pause
Goto Menu


:Quit
:: Fermeture du batch
Exit


::=============================================================================
::                                 FONCTIONS
::=============================================================================
:: Demande des droits administrateur
:---------------------------------------------------------------------------------------------------------------
:GetAdminRight
:---------------------------------------------------------------------------------------------------------------
REM --> Contrôle des permissions (Version 29/02/2016).
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> Si erreur, pas de droits Admin ...
If '%errorlevel%' NEQ '0' (
    Echo Demande des privilŠges administratifs ...
    Ping -n 2 127.0.0.1>NUL
    Goto UACPrompt
) Else ( Goto GotAdmin )

:UACPrompt
    Rem CHCP 1250 est utilisé pour les machines dont le 8.3 est désactivé et pour copier les accents.
    CHCP 1250>NUL
    Echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\Getadmin.vbs"
    Echo UAC.ShellExecute "cmd.exe","^/c" ^& """%~s0 %~s1""", "", "runas", 1 >> "%temp%\GetAdmin.vbs"

    Cscript //Nologo "%temp%\GetAdmin.vbs"
    Exit
    ::Exit /B 1

:GotAdmin
    If Exist "%temp%\GetAdmin.vbs" (Del "%temp%\GetAdmin.vbs")
:---------------------------------------------------------------------------------------------------------------
:---------------------------------------------------------------------------------------------------------------
Goto :EOF

:EOF