<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : /
    Version: 1.0
    Date: 2024-10-28
    Description: Création des règles FW en fonction des FQDN choisi
#>


###################### INCLUDE  ###################################

$FunctiontPath = "..\includes\dms-functions-tools-fw.ps1"

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

Write-Log -LogMessage "******************* START *******************" -LogPath $DirectoryLog
try {
  
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }

    Write-Log -LogMessage "Create File" -LogPath $DirectoryLog 
    
	# Autoriser les connexions DNS sortantes
Allow-DNSOutbound

# Résolution des adresses IPv4 pour chaque FQDN et création des règles de pare-feu
foreach ($fqdn in $windowsUpdateFQDNs) {
    Write-Log -LogMessage  "Résolution des adresses IPv4 pour : $fqdn" -LogPath $DirectoryLog
    $ipAddresses = Get-IPv4FromFQDN -FQDN $fqdn

    if ($ipAddresses) {
        Write-Log -LogMessage  "Adresses IPv4 pour $fqdn : $($ipAddresses -join ', ')" -LogPath $DirectoryLog
        # Appeler la fonction pour créer une règle de pare-feu avec toutes les adresses IP
        Create-FirewallRule -FQDN $fqdn -IPAddresses $ipAddresses
    } else {
        Write-Log -LogMessage  "Aucune adresse IPv4 trouvée pour $fqdn" -LogPath $DirectoryLog
    }
}

# Résolution des adresses IPv4 pour chaque FQDN et création des règles de pare-feu
foreach ($fqdn in $windowsUpdateFQDNs) {
    Write-Log -LogMessage  "Résolution des adresses IPv4 pour : $fqdn" -LogPath $DirectoryLog
    $ipAddresses = Get-IPv4FromFQDN -FQDN $fqdn

    if ($ipAddresses) {
        Write-Log -LogMessage  "Adresses IPv4 pour $fqdn : $($ipAddresses -join ', ')" -LogPath $DirectoryLog
        # Appeler la fonction pour créer une règle de pare-feu avec toutes les adresses IP
        Create-FirewallRuleStatic -FQDN $fqdn -IPAddresses $ipAddresses
    } else {
        Write-Log -LogMessage  "Aucune adresse IPv4 trouvée pour $fqdn" -LogPath $DirectoryLog
    }

    $resolvedNames = Get-ResolvedNamesOnly -FQDN $fqdn

    if ($resolvedNames) {
        foreach ($resolvedName in $resolvedNames) {
            $ipadresses = Get-IPv4FromFQDN $resolvedName 
            Create-FirewallRuleStatic -FQDN $resolvedName -IPAddresses $ipadresses
        }

    } else {
        Write-Log -LogMessage "Aucune adresse IPv4 trouvée pour $fqdn" -LogPath $DirectoryLog
    }

}

	Write-Log -LogMessage "Vérification des règles de pare-feu terminée." -LogPath $DirectoryLog
    Write-Log -LogMessage "Code executed successfully" -LogPath $DirectoryLog
} catch {
    Write-Log -LogMessage "Error occured while executing code: $_" -Append:$False -LogPath $DirectoryLog
}
Write-Log  "******************* END *******************" -LogPath $DirectoryLog
