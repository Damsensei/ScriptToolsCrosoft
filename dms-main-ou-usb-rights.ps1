<#
    Author      : DAMIEN CHANTEPIE
    Version     : 1.0
    Date        : 2023-02-20
    Description : Script principal pour la gestion des droits USB via des modifications d'OU et des fichiers de suivi CSV.
#>

###################### INCLUDE ######################
. "dms-functions-tools.ps1" # Importation des fonctions utilitaires

###################### VARIABLES ######################
$APPS = "AD"
$APPS2 = "RightUSB"
$DirectoryLog = "C:\PATH\LOG\$APPS"+"_"+"$APPS2.log" # Chemin du fichier de log
$Directory = "C:\PATH\SOURCES\$APPS\$APPS2"           # Répertoire source
$TimeToMove = "0"                                      # Temps avant la suppression des droits USB
$PathRightUSBList = "$Directory\RightUSBList.csv"      # Fichier CSV pour les ordinateurs autorisés
$PathRightUSBListException = "$Directory\RightUSBListException.csv" # Exceptions d'accès USB
$OUsearch = "PorTs USB"                                # Nom de l'OU à rechercher
$Date = get-date -Format "dd/MM/yyyy"

###################### MAIN ######################
Write-Log -LogMessage "******************* START *******************" -LogPath $DirectoryLog

try {
    # Vérifie et crée le répertoire de stockage si nécessaire
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }

    # Initialisation des fichiers CSV RightUSBList.csv et RightUSBListException.csv
    if (Test-Path $PathRightUSBList) {
        Write-Host "Le fichier existe déjà !"
    } else {
        Get-WmiObject win32_service | Out-File $PathRightUSBList
        echo "Computer;Date;OU;" | Set-Content $PathRightUSBList
    }
    if (Test-Path $PathRightUSBListException) {
        Write-Host "Le fichier existe déjà !"
    } else {
        Get-WmiObject win32_service | Out-File $PathRightUSBListException
        echo "Computer" | Set-Content $PathRightUSBListException
    }

    Write-Log -LogMessage "Lancement de $APPS" -LogPath $DirectoryLog

    ###################### PARTIE : Vérification mise à jour des droits USB ######################
    Write-Log -LogMessage "PARTIE : Vérification mise à jour des droits USB" -LogPath $DirectoryLog

    # Récupération de la liste actuelle des ordinateurs avec droits USB depuis le CSV
    [string]$RightUSBList = get-content $PathRightUSBList
    $ImportRightUSBListCSV = Import-Csv -Path $PathRightUSBList -Delimiter ";"
    $OUs = (FindObjectOU -Name "*USB*") # Recherchez toutes les OUs avec "USB" dans le nom

    ForEach ($varOU in $OUs) {
        $OULIst = (FindComputers -Name $varOU -Object Name)
        $count = CountADObjects -OUPath $varOU
        Write-Log -LogMessage "Nombre de postes dans l'OU : $count" -LogPath $DirectoryLog

        ForEach ($Computer in $OULIst) {
            if ($RightUSBList.Contains($Computer)) {
                Write-Log -LogMessage "Ordinateur - $Computer (Existe déjà)" -LogPath $DirectoryLog
            } else {
                Write-Log -LogMessage "Ajout d'ordinateur - $Computer (N'existe pas)" -LogPath $DirectoryLog
                New-Object -TypeName PSCustomObject -Property @{Computer=$Computer; Date=$date; OU=$varOU} | Export-Csv -Delimiter ';' -Append -Force -Path $PathRightUSBList -NoTypeInformation
            }
        }
    }

    # Nettoyage du fichier CSV pour éliminer les espaces et doubles guillemets inutiles
    (Get-Content $PathRightUSBList) | Foreach-Object {$_ -replace '  ', ' '} | Set-Content $PathRightUSBList
    (Get-Content $PathRightUSBList) | Foreach-Object {$_ -replace '"', ''} | Set-Content $PathRightUSBList
    Write-Log -LogMessage "Nettoyage du fichier CSV avec les doubles guillemets" -LogPath $DirectoryLog

    ###################### PARTIE : Suppression des droits USB ######################
    Write-Log -LogMessage "PARTIE : Suppression des droits USB" -LogPath $DirectoryLog

    # Variables pour l’actualisation du CSV des droits USB et des exceptions
    [string]$RightUSBList = get-content $PathRightUSBList
    $ImportRightUSBListCSV = Import-Csv -Path $PathRightUSBList -Delimiter ";"
    $RightUSBListException = get-content $PathRightUSBListException

    ForEach ($Computer in $ImportRightUSBListCSV) {
        $ComputerException = $Computer.Computer
        $ComputerDate = $Computer.Date
        $ComputerOU = $Computer.OU
        $ADComputerOU = (FindObjectOU -Name $ComputerException -Object Name)

        # Calcul du nombre de jours écoulés depuis la date de droit USB
        $totalDays = (New-TimeSpan -Start $ComputerDate -End $Date).TotalDays
        $total = $TimeToMove - $totalDays

        if ($RightUSBListException.Contains($ComputerException)) {
            Write-Log -LogMessage "Ordinateur - $ComputerException ==> Exception USB (Non déplacé)" -LogPath $DirectoryLog
        } else {
            If ($totalDays -gt $TimeToMove) {
                Write-Log -LogMessage "Ordinateur - $ComputerException - Temps dépassé de $total jours (Droits USB révoqués)" -LogPath $DirectoryLog
                If ($ADComputerOU -ieq $ComputerOU) {
                    Write-Log -LogMessage "Ordinateur - $ComputerException déplacé" -LogPath $DirectoryLog
                    MoveObjectParentOU $ComputerException
                } else {
                    Write-Log -LogMessage "Erreur : $ComputerException déjà déplacé" -LogPath $DirectoryLog
                }
                # Suppression de l'ordinateur du CSV des droits USB
                Write-Log -LogMessage "Suppression de la ligne pour $ComputerException dans le CSV" -LogPath $DirectoryLog
                (get-content $PathRightUSBList) | Select-String -pattern "$ComputerException" -notmatch | Set-Content -Force $PathRightUSBList.Trim()
            } else {
                Write-Log -LogMessage "Ordinateur - $ComputerException - Temps restant : $total jours (Non déplacé)" -LogPath $DirectoryLog
            }
        }
    }

    Write-Log -LogMessage "Code exécuté avec succès" -LogPath $DirectoryLog
} catch {
    Write-Log -LogMessage "Erreur lors de l'exécution du code : $_" -LogPath $DirectoryLog
}

Write-Log -LogMessage "******************* END *******************" -LogPath $DirectoryLog
