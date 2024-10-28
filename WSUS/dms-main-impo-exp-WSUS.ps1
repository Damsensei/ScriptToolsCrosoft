cls
echo "******************************************************************"
echo "*		 Script IMPORT / EXPORT / RESET WSUS"
echo "******************************************************************"
echo ""
echo "******************************************************************"
echo "* 	 Developpé par Damien CHANTEPIE - TOP/SSI					"
echo "* 	 Version 1.0												"
echo "******************************************************************"
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""

# "******************************************************************"
# "*		 Script IMPORT / EXPORT / RESET WSUS"
# "******************************************************************"

#Demande des chemins 

$CheminExport=Read-Host "Quel est le chemin de l'export"
$CheminWSUSContent=Read-Host "Quel est le chemin du WSUSContent"


$Date=get-date -Format "yyyy-MM-dd"
$UserProfile=(Get-Item Env:\USERPROFILE).value
$ComputerName=(Get-Item Env:\COMPUTERNAME).value

$NomDuFichier= ($ComputerName + "_" + $Date)
$DossierExport= ("ExportWSUS_"+$Date)

cls
echo "Que voulez vous faire ?"
echo "(1) Export"
echo "(2) Import"
echo "(3) Désinstallation de WSUS (Administrateur)"
echo "(4) Installation de WSUS (Administrateur)"
echo ""
$Value=Read-Host "Choix (1-2-3-4)"



cls
switch($Value)
{
# "*****DEBUT DU SWITCH***************"
	1
	{
		echo "*********************************"
		echo "*		 EXPORT "
		echo "*********************************"
		
		# EXPORT de la BDD WSUS + Approbation
		#Exportation du dossier
		echo "Copie des fichier"
		&'c:\\windows\\system32\\robocopy.exe' $CheminWSUSContent ($CheminExport + '\' + $DossierExport + '\WsusContent') /MIR /E /R:0 /W:0
		# Exportation de la BDD
		& 'C:\Program Files\Update Services\Tools\wsusutil.exe' export ($CheminExport + '\' + $DossierExport + '\' + $NomDuFichier + '.xml.gz') ($CheminExport + '\' + $DossierExport + '\' + $NomDuFichier + '.log')
		& '.\WsusMigrate\WsusMigrationExport.6.3.exe' ($CheminExport + '\' + $DossierExport + '\'+ 'Approbation_' + $Date + '.xml')
	}
	2
	{
		echo  "*********************************"
		echo  "*		 IMPORT "
		echo  "*********************************"
		
		#Importation du dossier « 
		robocopy ($CheminExport + '\' + $DossierExport + "\WsusContent") $CheminWSUSContent  /MIR /E /R:0 /W:0
		#Importation de la BDD (
		& 'C:\Program Files\Update Services\Tools\wsusutil.exe' import ($CheminExport + '\' + $DossierExport + '\' + $NomDuFichier + '.xml.gz') ($CheminExport + '\' + $DossierExport + '\' + $NomDuFichier + '.log')
		& '.\WsusMigrate\WsusMigrationImport.6.3.exe' ($CheminExport + '\' + $DossierExport + '\'+ 'Approbation_' + $Date + '.xml') + ' ' + 'all none'
	}
	3
	{
		echo "*********************************"
		echo "*		 DESINSTALLATION WSUS "
		echo "/!\ ADMINISTRATEUR UNIQUEMENT /!\"
		echo "*********************************"
		
		del 'C:\Windows\WID\*'
		Uninstall-WindowsFeature -Name UpdateServices,Windows-Internal-Database -Restart
	}
	4
	{	
		echo "*********************************"
		echo "*		 INSTALLATION WSUS "
		echo "/!\ ADMINISTRATEUR UNIQUEMENT /!\"
		echo "*********************************"
		Install-WindowsFeature UpdateServices -Restart
		echo "Erreur de saisie"
	}
# "*****FIN DU SWITCH***************"
}
# "*********************************"
# "*		 FIN DU SCRIPT
# "*********************************"













