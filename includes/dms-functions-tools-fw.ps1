<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : ChatGPT
    Version: 0.1
    Date: 2024-10-28
    Description: 
        - Création d'une règle FW
		- Update d'une règle FW
		- Lookup IP / FQDN
    
    Release:
        - ...
#>

#########################################################  
#############		Vérification en-tete    #############
#########################################################

#$FunctiontPath = "dms-functions-tools-logs.ps1"

$FunctiontPath = Join-Path -Path $PSScriptRoot -ChildPath ".\dms-functions-tools-logs.ps1"
if (Test-Path $FunctiontPath) {
    . $FunctiontPath
} else {
    Write-Host "Le fichier de script spécialisé est introuvable à $FunctiontPath" -ForegroundColor Red
    exit
}


#########################################################  
#############		VARIABLES				#############
#########################################################

$PSDefaultParameterValues['*:Encoding'] = 'utf8'


#########################################################  
#############		FUNCTIONS				#############
#########################################################


###################### INPUT CHECK ######################
# Liste des FQDN pour Windows Update (à personnaliser si nécessaire)
$windowsUpdateFQDNs = @(
    'windowsupdate.microsoft.com',
    'update.microsoft.com',
    'windowsupdate.com',
    'download.windowsupdate.com',
    'download.microsoft.com',
    'wustat.windows.com',
    'windows.com',
    'microsoft.com',
    'ntservicepack.microsoft.com',
    'mozilla.org',
    'settings-win.data.microsoft.com',
    'stats.microsoft.com'
)


# -------------------
# Partie Fonction
# -------------------


# Fonction pour sauvegarder les règles du pare-feu
function Save-FirewallRules {
    $backupPath = "C:\BackupFirewallRules.wfw"
    netsh advfirewall export $backupPath
    Write-Host "Les règles de pare-feu (entrantes et sortantes) ont été sauvegardées dans $backupPath"
}

# Fonction pour restaurer les règles du pare-feu
function Restore-FirewallRules {
    $backupPath = "C:\BackupFirewallRules.wfw"
    if (Test-Path $backupPath) {
        netsh advfirewall import $backupPath
        Write-Host "Les règles de pare-feu ont été restaurées depuis $backupPath"
    } else {
        Write-Host "Aucune sauvegarde trouvée à $backupPath. Impossible de restaurer."
    }
}

# Fonction pour réinitialiser les règles du pare-feu aux paramètres par défaut
function Reset-Firewall {
    netsh advfirewall reset
    Write-Host "Le pare-feu a été réinitialisé aux paramètres par défaut."
}

# Fonction pour bloquer toutes les connexions entrantes et sortantes et effacer toutes les règles
function Block-AllConnections {
    # Supprimer toutes les règles existantes
    netsh advfirewall firewall delete rule name=all
    Write-Host "Toutes les règles de pare-feu (entrantes et sortantes) ont été supprimées."

    # Récupérer toutes les adresses dynamiques associées aux règles de pare-feu
$dynamicFQDNs = Get-NetFirewallDynamicKeywordAddress -AllAutoResolve

# Vérifier s'il existe des adresses dynamiques
if ($dynamicFQDNs) {
    Write-Host "Suppression de toutes les règles dynamiques associées aux FQDN..."

    # Boucle pour supprimer chaque adresse dynamique
    foreach ($fqdnEntry in $dynamicFQDNs) {
        try {
            # Supprimer l'adresse dynamique en utilisant son ID
            Remove-NetFirewallDynamicKeywordAddress -Id $fqdnEntry.Id
        }
        catch {
            Write-Host "Erreur lors de la suppression de FQDN : $($fqdnEntry.Keyword)"
        }
    }
    
    Write-Host "Toutes les règles dynamiques ont été supprimées."
} else {
    Write-Host "Aucune règle dynamique trouvée."
}

    # Bloquer toutes les connexions entrantes et sortantes par défaut
    netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
    Write-Host "Toutes les connexions entrantes et sortantes sont désormais bloquées, sauf les exceptions définies."
}

# Fonction pour résoudre les adresses IPv4 d'un FQDN
function Get-IPv4FromFQDN {
    param (
        [string]$FQDN
    )
    try {
        # Résoudre les adresses IPv4 uniquement pour le FQDN donné
        $ipAddresses = (Resolve-DnsName -Name $FQDN -DNSOnly -ErrorAction Stop | Where-Object { $_.QueryType -eq "A" }).IPAddress -join ','
        Write-Host "Get-IPv4FromFQDN List IPAdresses : $ipAddresses"
        return $ipAddresses
    } catch {
        Write-Host "Impossible de résoudre le FQDN : $FQDN" -ForegroundColor Red
        return $null
    }
}

function Get-OutboundFirewallFQDNs {
    param (
        [string]$FQDNPattern = '\[(.*?)\]'
    )

    # Récupère toutes les règles de pare-feu sortantes
    $outboundRules = Get-NetFirewallRule -Direction Outbound

    # Extraire les FQDN présents dans les noms de règles
    $fqdnList = $outboundRules | ForEach-Object {
        if ($_.DisplayName -match $FQDNPattern) {
            $matches[1]  # Récupère le FQDN capturé entre les crochets
        }
    }

    # Filtrer pour n'afficher que les FQDN non vides et distincts
    $fqdnList | Where-Object { $_ } | Sort-Object -Unique
}

function Get-OutboundFirewallRemoteAddresses {
    param (
        [string]$FQDN  # Le FQDN à rechercher dans les règles de pare-feu
    )

    # Récupère toutes les règles de pare-feu sortantes correspondant au FQDN donné
    $outboundRules = Get-NetFirewallRule -Direction Outbound | Where-Object { $_.DisplayName -like "*$FQDN*" }

    # Vérifie si une règle a été trouvée
    if ($outboundRules) {
        $outboundRules | ForEach-Object {
            $rule = $_
            $ruleDetails = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule

            # Si la règle a des adresses distantes spécifiées, les retourner sous forme de tableau séparé par des virgules
            if ($ruleDetails.RemoteAddress) {
                $remoteAddresses = $ruleDetails.RemoteAddress -join ','
                Write-Host "FQDN : $FQDN, Adresses IP : $remoteAddresses"
                return $remoteAddresses  # Retourne la liste des adresses IP en tant que tableau séparé par des virgules
            }
        }
    } else {
        Write-Host "Aucune règle trouvée pour le FQDN : $FQDN" -ForegroundColor Red
        return $null
    }
}

# Fonction pour créer une règle de pare-feu pour un FQDN avec toutes les adresses IP résolues
function Create-FirewallRuleStatic {
    param (
        [string]$FQDN,
        [string]$IPAddresses
    )

    # Combiner toutes les adresses IP en une seule chaîne séparée par des virgules
    $ipAddressList = $IPAddresses


Write-Host "Create-FirewallRule List ipAddressList : $ipAddressList"

    # Vérifie si une règle de pare-feu existe déjà pour ce FQDN
    $existingRule = FirewallRuleExists -FQDN $FQDN

    if ($existingRule) {
            

    } else {

                # Crée une règle de pare-feu pour autoriser uniquement les connexions sortantes vers toutes les adresses IP résolues
        New-NetFirewallRule -DisplayName "Allow [$FQDN]" -Action Allow -Direction Outbound -RemoteAddress $ipAddressList.Split(',')
        Write-Host "Règle ajoutée pour $FQDN avec les adresses : $ipAddressList" -ForegroundColor Green
    }
}

# Fonction pour créer une règle de pare-feu pour un FQDN avec toutes les adresses IP résolues
function Create-FirewallRuledynamic {
    param (
        [string]$FQDN,
        [string]$IPAddresses
    )

    # Combiner toutes les adresses IP en une seule chaîne séparée par des virgules
    $ipAddressList = $IPAddresses


Write-Host "Create-FirewallRule List ipAddressList : $ipAddressList"

    # Vérifie si une règle de pare-feu existe déjà pour ce FQDN
    $existingRule = FirewallRuleExists -FQDN $FQDN

    if ($existingRule) {
            

    } else {
                $id = '{' + (new-guid).ToString() + '}'

                # Crée une règle de pare-feu pour autoriser uniquement les connexions sortantes vers toutes les adresses IP résolues
                New-NetFirewallDynamicKeywordAddress -id $id -Keyword $FQDN -AutoResolve $true
                # New-NetFirewallRule -DisplayName "Allow [$FQDN] for Windows Update" -Action Allow -Direction Outbound -RemoteAddress $ipAddressList.Split(',')
                New-NetFirewallRule -DisplayName "Allow [$FQDN] for Windows Update" -Action Allow -Direction Outbound -RemoteDynamicKeywordAddresses $id

                Write-Host "Règle ajoutée pour $FQDN avec les adresses : $ipAddressList" -ForegroundColor Green
    }
}

# Fonction pour autoriser les connexions DNS sortantes
function Allow-DNSOutbound {
    # Autoriser les connexions DNS sortantes (UDP et TCP port 53)
    if (-not (Get-NetFirewallRule -DisplayName "Allow DNS Outbound (UDP)" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName "Allow DNS Outbound (UDP)" -Action Allow -Direction Outbound -Protocol UDP -RemotePort 53
        Write-Host "Règle DNS Outbound (UDP) ajoutée"
    }

    if (-not (Get-NetFirewallRule -DisplayName "Allow DNS Outbound (TCP)" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName "Allow DNS Outbound (TCP)" -Action Allow -Direction Outbound -Protocol TCP -RemotePort 53
        Write-Host "Règle DNS Outbound (TCP) ajoutée"
    }
}

function Update-FirewallIPs {
    param (
        [string]$FQDN,             # Le FQDN à rechercher dans les règles
        [array]$NewIPAddresses     # Les nouvelles adresses IP à ajouter (sous forme de tableau)
    )

    # Étape 1 : Rechercher la règle de pare-feu existante contenant le FQDN dans le nom
    #$existingRule = Get-NetFirewallRule -DisplayName "*$FQDN*"
    $existingRule = FirewallRuleExists -FQDN $FQDN

    if ($existingRule) {
        # Étape 2 : Récupérer les adresses IP actuelles associées à la règle
        #$addressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $existingRule
        $RulesName = Get-NetFirewallRule -Direction Outbound | Where-Object { $_.DisplayName -match "\[$FQDN\]" }
        $RulesIP = Get-OutboundFirewallRemoteAddresses -FQDN $FQDN

        if ($RulesName) {

            Write-Host "Adresses IP actuelles pour $FQDN : $RulesName"
        } else {
            Write-Host "Aucune adresse IP distante spécifiée pour cette règle."
        }

        # Étape 3 : Ajouter les nouvelles adresses IP (en évitant les doublons)
        $combinedIPs = $RulesIP.Split(',') + $NewIPAddresses.Split(',')  # Combiner les deux listes d'IP
        $distinctIPs = $combinedIPs | Sort-Object -Unique  # Éliminer les doublons

        # Ne pas joindre les IP en une chaîne mais les passer sous forme de tableau
        Write-Host "Nouvelles adresses IP combinées pour $FQDN : $($distinctIPs -join ',')"

        # Étape 4 : Modifier la règle de pare-feu avec les anciennes et les nouvelles adresses IP sous forme de tableau
        try {
            Set-NetFirewallRule -Name $RulesName -RemoteAddress $distinctIPs
            Write-Host "Règle mise à jour avec succès pour $FQDN avec les adresses IP : $($distinctIPs -join ',')"
        } catch {
            Write-Host "Erreur lors de la mise à jour de la règle pour $FQDN. Détails : $_" -ForegroundColor Red
        }
    } 
}

function FirewallRuleExists {
    param (
        [string]$FQDN  # Le FQDN à rechercher dans le nom de la règle, entre crochets
    )

    # Recherche une règle de pare-feu dont le DisplayName contient le FQDN entre crochets
    $existingRule = Get-NetFirewallRule -Direction Outbound | Where-Object { $_.DisplayName -match "\[$FQDN\]" }

    if ($existingRule) {
        Write-Host "Règle existante trouvée pour $FQDN : $($existingRule.DisplayName)" -ForegroundColor Yellow
        return $true
    } else {
        Write-Host "Aucune règle trouvée pour le FQDN : [$FQDN]"
        return $false
    }
}

function Get-ResolvedNamesOnly {
    param (
        [string]$FQDN  # Le FQDN à résoudre
    )

    # Initialiser le tableau pour stocker les noms résolus
    $resolvedNames = @()

    try {
        # Résoudre toutes les informations DNS pour le FQDN
        $dnsRecords = Resolve-DnsName -Name $FQDN -DnsOnly -ErrorAction Stop

        foreach ($record in $dnsRecords) {
            # Ajouter le nom si c'est un enregistrement CNAME, A, ou AAAA et qu'il n'est pas vide
            if ($record.QueryType -in @("CNAME", "A", "AAAA") -and $record.NameHost) {
                $resolvedNames += $record.NameHost
                Write-Host "Nom résolu : $($record.NameHost)" -ForegroundColor Cyan
            }
        }

        # Supprimer les doublons et retourner les noms en tant que tableau unique
        return $resolvedNames | Sort-Object -Unique

    } catch {
        Write-Host "Erreur lors de la résolution DNS pour $FQDN : $_" -ForegroundColor Red
        return $null
    }
}
