# Afficher le menu
Show-Menu


<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : /
    Version: 1.0
    Date: 2024-10-28
    Description: Template des fichiers Create Rules Firewall
#>


###################### INCLUDE  ###################################

$FunctiontPath = ".\includes\dms-functions-tools-fw.ps1"

if (Test-Path $FunctiontPath) {
    . $FunctiontPath
} else {
    Write-Host "Le fichier de script spécialisé est introuvable à $FunctiontPath" -ForegroundColor Red
    exit
}

###################### VARIABLES  ###################################

$APPS = "WINDOWS Template"
$APPS2 = "CreateFile"

$DirectoryLog = "C:\damscrosoft\LOG\$APPS"+"_"+"$APPS2.log"
$Directory = "C:\damscrosoft\SOURCES\$APPS\$APPS2"


###################### MAIN  ###################################


try {
  
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }
	Write-Log -LogMessage "******************* START *******************" -LogPath $DirectoryLog

	# Prompt de sélection pour l'utilisateur
	function Show-Menu {
		Write-Host "Que voulez-vous faire ?"
		Write-Host "1. Sauvegarder les règles de pare-feu"
		Write-Host "2. Restaurer les règles de pare-feu"
		Write-Host "3. Réinitialiser le pare-feu à la configuration par défaut"
		Write-Host "4. Bloquer toutes les connexions entrantes et sortantes (supprimer toutes les règles)"
		Write-Host "5. Quitter"
		$choice = Read-Host "Entrez le numéro de votre choix"
		
		switch ($choice) {
			1 { Write-Log -LogMessage "Choix 1. Save-FirewallRules." -LogPath $DirectoryLog
			Save-FirewallRules }
			2 { Write-Log -LogMessage "Choix 2. Restore-FirewallRules." -LogPath $DirectoryLog
			Restore-FirewallRules }
			3 { Write-Log -LogMessage "Choix 3. Reset-Firewall." -LogPath $DirectoryLog
			Reset-Firewall }
			4 { Write-Log -LogMessage "Choix 4. Block-AllConnections." -LogPath $DirectoryLog
			Block-AllConnections }
			5 { Write-Log -LogMessage "Sortie..." -LogPath $DirectoryLog ; exit }
			default { 
			Write-Log -LogMessage "Choix invalide. Veuillez réessayer." -LogPath $DirectoryLog ; Show-Menu }
		}
	}
    
    Write-Log -LogMessage "Code executed successfully" -LogPath $DirectoryLog
} catch {
    Write-Log -LogMessage "Error occured while executing code: $_" -Append:$False -LogPath $DirectoryLog
}
Write-Log  "******************* END *******************" -LogPath $DirectoryLog
