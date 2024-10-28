@echo off
echo.
echo.
echo  _____________________________________________________________________
echo /                                                                     \
echo                       Auteur: Damien CHANTEPIE
echo 			   Version: V2.0                             
echo \_____________________________________________________________________/
echo.
echo.


echo ***********************************************************************
echo *************************  SCRIPT SAUVEGARDE **************************
echo ***********************************************************************




set RepertoireUser=%userprofile%
set NomDisqueSauvegarde=Dams-Sauvegarde
set RepertoireSauvegardeDisque=-_- Sauvegarde Damien -_-
set FichierLog=%userprofile%\SCRIPT\sauvegarde.bat.log

echo *********************************************************************** >>%FichierLog%
echo *                       DEBUT : %DATE% - %TIME%                       * >>%FichierLog%
echo *********************************************************************** >>%FichierLog%


:sofAuto

set ScriptAuto=o
set choix=o
set choixLancerTC=n

echo.
echo.
echo  _____________________________________________________________________
echo /                                                                     \
echo                        SAUVEGARDE AUTOMATIQUE                              
echo \_____________________________________________________________________/
echo.
echo.
echo.
echo       Appuyer sur la touche [ M ] pour sauvegarder maunellement         
echo.
echo.
echo.

choice /C AM /T 30 /D A /N
if %errorlevel%==1 (goto DisqueNonMonte)
if %errorlevel%==2 (goto sof)

:sof

set ScriptAuto=n
set choix=
set choixLancerTC=

:question
cls

echo  _____________________________________________________________________
echo /                                                                     \
echo                        SAUVEGARDE MANUELLE                              
echo \_____________________________________________________________________/
echo.
set /p choix=Voulez vous sauvegarder [O/n] ? : 
echo.
set /p ChoixLancerApplication=Voulez vous Relancer Keepass apres la sauvegarde [O/n] ? : 

echo Choix : %choix% >>%FichierLog%
echo ChoixLancerApplication : %ChoixLancerApplication% >>%FichierLog%

if /I "%choix%"=="n" (goto eof)
if /I "%choix%"=="o" (goto TesterDisqueSauvegarde)
goto ErreurSaisie


:ErreurSaisie
echo "Erreur de saisie, seul les touches [O,o,N,n] sont autorisÃ©es"
cls
goto question

:TesterDisqueSauvegarde
for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (vol %%a: | find "%NomDisqueSauvegarde%"
cls
if not errorlevel 1 set MonDisqueSauvegarde=%%a:)
if "%MonDisqueSauvegarde%"=="" (echo %MonDisqueSauvegarde% Disque Dur non trouve >>%FichierLog%
if "%ScriptAuto%"=="o" (echo "Auto : Disque Non Monté" >>%FichierLog%
goto eof)
goto DisqueNonMonte) else (
echo Lecteur Du Disque "%MonDisqueSauvegarde%">>%FichierLog%)
)

goto TesterKeePass

rem **************************************************************
rem *****************    Sauvegarde Disque Dur   *****************
rem **************************************************************


:SauvegardeRepertoireUser
:::ULTIMATE COPY PROGRESSBAR
:::By SachaDee (2014)
:::DEFINITION DE LA SOURCE DE COPY
:::EN METTANT *.* IL COPIE EGALEMENT LES SOUS-DOSSIERS


:::DEFINITION DE LA DESTINATION
rem **************************************************************
rem *****************    Sauvegarde User Profile   *****************
rem **************************************************************
echo Sauvegarde KeePass >>%FichierLog%
if exist %RepertoireScript%progressUserProfile.vbs del %RepertoireScript%progressUserProfile.vbs
(echo Const ProgressBar = ^&H0^&
 echo strTargetFolder = "%$destination%"
echo Set objShell = CreateObject^(^"Shell.Application^"^)
 echo Set objFolder = objShell.NameSpace^(strTargetFolder^)
echo objFolder.CopyHere ^"%RepertoireUser%^", 16) >>%RepertoireScript%progressUserProfile.vbs



ECHO TRAITEMENT EN COURS VEUILLEZ PATIENTER...


goto LancerApplication



:TesterKeePass
tasklist | find "keepass.exe" /C /i > nul
if %errorlevel%==0 goto KillKeePass
if %errorlevel%==1 goto SauvegardeRepertoireUser
goto eof

:KillKeePass
tskill keepass
goto SauvegardeFonctionKeepass

:DisqueNonMonte

echo.
echo  _____________________________________________________________________
echo /                                                                     \
echo           VEUILLEZ BRANCHER LE DISQUE DE SAUVEGARDE                  
echo \_____________________________________________________________________/
echo.
echo.
echo.
timeout /t 60
goto TesterDisqueSauvegarde

:LancerApplication

cls
tasklist | find "wscript.exe" /C /i > nul
if %errorlevel%==0 (
timeout /t 60
goto LancerApplication)

echo.
echo  _____________________________________________________________________
echo /                                                                     \
echo                 LANCEMENT DES APPLICATIONS FERME                  
echo \_____________________________________________________________________/
echo.


if /I "%choixLancerTC%"=="o" (start "Keepass" "C:\Program Files (x86)\KeePass Password Safe\KeePass.exe")

goto eof


:eof

cls

echo *********************************************************************** >>%FichierLog%
echo *                       FIN : %DATE% - %TIME%                         * >>%FichierLog%
echo *********************************************************************** >>%FichierLog%
echo "fin"
exit
