<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : /
    Version: 1.0
    Date: 2024-10-28
    Description: Mise à jour des FQDN et IP des Règles Firewall
#>

###################### INCLUDE  ###################################

$FunctiontPath = Join-Path -Path $PSScriptRoot -ChildPath "..\includes\dms-functions-tools-fw.ps1"

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

###################### MAIN ###################################
###################### MAIN ###################################

Write-Log -LogMessage "******************* START *******************" -LogPath $DirectoryLog

try {
    # Vérifier et créer le répertoire de logs si nécessaire
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }

    Write-Log -LogMessage "Création du fichier" -LogPath $DirectoryLog

    # Récupérer les règles de pare-feu sortantes existantes
    $outboundRules = Get-NetFirewallRule -Direction Outbound

    # Pour chaque règle existante, traiter le FQDN associé
    foreach ($rule in $outboundRules) {
        $fqdn = $rule.DisplayName -replace '.*\[(.*?)\].*', '$1'  # Extraire le FQDN entre crochets
        Write-Log -LogMessage "Traitement du FQDN : $fqdn" -LogPath $DirectoryLog

        # Récupérer les adresses IP pour le FQDN
        $ipAddresses = Get-IPv4FromFQDN -FQDN $fqdn

        if ($ipAddresses) {
            Write-Log -LogMessage "Adresses IPv4 pour $fqdn : $($ipAddresses -join ', ')" -LogPath $DirectoryLog

            # Chercher une règle existante pour ce FQDN
            $existingRule = $outboundRules | Where-Object { $_.DisplayName -match "\[$fqdn\]" }

            if ($existingRule) {
                # Si une règle existe, mettre à jour les adresses IP
                Write-Log -LogMessage "Mise à jour de la règle pour FQDN : $fqdn avec les nouvelles adresses IP" -LogPath $DirectoryLog
                Update-FirewallIPs -FQDN $fqdn -NewIPAddresses $ipAddresses
            } else {
                # Sinon, créer une nouvelle règle pour ce FQDN
                Write-Log -LogMessage "Création d'une nouvelle règle pour le FQDN : $fqdn" -LogPath $DirectoryLog
                Create-FirewallRuleStatic -FQDN $fqdn -IPAddresses $ipAddresses
            }
        } else {
            Write-Log -LogMessage "Aucune adresse IPv4 trouvée pour $fqdn" -LogPath $DirectoryLog
        }

        # Optionnel : traiter les noms résolus supplémentaires pour chaque FQDN
        $resolvedNames = Get-ResolvedNamesOnly -FQDN $fqdn
        if ($resolvedNames) {
            foreach ($resolvedName in $resolvedNames) {
                $ipAddresses = Get-IPv4FromFQDN $resolvedName
                if ($ipAddresses) {
                    Write-Log -LogMessage "Création d'une règle pour le nom résolu $resolvedName avec IP : $($ipAddresses -join ', ')" -LogPath $DirectoryLog
                    Create-FirewallRuleStatic -FQDN $resolvedName -IPAddresses $ipAddresses
                } else {
                    Write-Log -LogMessage "Aucune adresse IPv4 trouvée pour le nom résolu $resolvedName" -LogPath $DirectoryLog
                }
            }
        }
    }

    Write-Log -LogMessage "Code exécuté avec succès" -LogPath $DirectoryLog

} catch {
    Write-Log -LogMessage "Erreur lors de l'exécution du code : $_" -Append:$False -LogPath $DirectoryLog
}

Write-Log -LogMessage "******************* END *******************" -LogPath $DirectoryLog
