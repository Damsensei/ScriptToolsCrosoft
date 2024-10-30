<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : ChatGPT
    Version: 2.0
    Date: 2023-02-14
    Description: Divers fonction pour intéragir avec l'active directory
        - Extraire les comptes utilisateurs ou ordinateur
        - Compte le nombre d'objet
        - Set un mot de passe
        - Move un objet
        - ...
    
    Release:
        - ?
    Ce fichier doit être inclu dans les autres fichiers powershell "c:\Chemin\Du\Fichier\FonctionScriptAD.ps1"
#>


#########################################################  
#############		VARIABLES				#############
#########################################################

clear
$PSDefaultParameterValues['*:Encoding'] = 'utf8'


#########################################################  
#############		FUNCTIONS				#############
#########################################################

###################### LOG FUNCTIONS ##########################

<#
    .SYNOPSIS
        Écrit un message de log dans un fichier texte et l'affiche dans la console.
    .PARAMETER LogMessage
        Message à écrire dans le log.
    .PARAMETER LogPath
        Chemin complet du fichier de log (défaut : C:\Scripts\log.txt).
    .PARAMETER Append
        Si défini, le message sera ajouté à la fin du fichier (défaut : $True).
    .EXAMPLE
        Write-Log -LogMessage "Démarrage du script"
        Write-Log -LogMessage "Erreur" -LogPath "C:\Logs\error.log" -Append:$False
#>

try {

function Write-Log {
    param (
        [string]$LogMessage,
        [string]$LogPath = "C:\Scripts\log.txt",
        [switch]$Append = $True
    )

    # On récupère le dossier parent du fichier de log et on vérifie s'il existe
    $Directory = Split-Path $LogPath -Parent
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }

    # On affiche le message de log dans la console
    write-host "$LogMessage"


        # On ajoute le message de log au fichier
        if ($Append) {
            #Add-Content $LogPath -Value "$(Get-Date -Format "yyyyMMdd-HHmmss") : $LogMessage"
            "$(Get-Date -Format "yyyyMMdd-HHmmss") : $LogMessage" |�Out-File $LogPath -Append
        } else {
            Set-Content $LogPath -Value "$(Get-Date -Format "yyyyMMdd-HHmmss") : $LogMessage"
        }
    }
} 
catch {
    Write-Host "Error occured while writing to log file"
}
