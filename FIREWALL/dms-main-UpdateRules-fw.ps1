 <#
    Author: DAMIEN CHANTEPIE 
    Reviewed : /
    Version: 1.0
    Date: 2024-10-28
    Description: Mise à jour des FQDN et IP des Règles Firewall
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
    # 1. Récupérer les règles de pare-feu sortantes
    $outboundRules = Get-NetFirewallRule -Direction Outbound

    foreach ($rule in $outboundRules) {
        # 2. Extraire le FQDN du nom de la règle si présent
        if ($rule.DisplayName -match '\[(.*?)\]') {
            $fqdn = $matches[1]  # Capture le FQDN entre les crochets dans le DisplayName

            # 3. Récupérer les nouvelles adresses IP pour ce FQDN
            $newIPAddresses = Get-IPv4FromFQDN -FQDN $fqdn

            if ($newIPAddresses) {
                Write-Log -LogMessage "Mise à jour de la règle pour FQDN : $fqdn avec les nouvelles adresses IP : $newIPAddresses" -LogPath $DirectoryLog

                # 4. Mettre à jour la règle de pare-feu avec les nouvelles adresses IP
                Update-FirewallIPs -FQDN $fqdn -NewIPAddresses $newIPAddresses
            } else {
                Write-Log -LogMessage "Impossible de résoudre des adresses pour le FQDN : $fqdn" -LogPath $DirectoryLog
            }
        } else {
            Write-Log -LogMessage"Aucun FQDN trouvé dans la règle : $($rule.DisplayName)" -LogPath $DirectoryLog
        }
    }

    Write-Log -LogMessage "Code executed successfully" -LogPath $DirectoryLog
} catch {
    Write-Log -LogMessage "Error occured while executing code: $_" -Append:$False -LogPath $DirectoryLog
}
Write-Log  "******************* END *******************" -LogPath $DirectoryLog
