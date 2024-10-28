<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : /
    Version: 1.0
    Date: 2024-10-28
    Description: Template des fichiers Create Rules Firewall
#>


###################### INCLUDE  ###################################

$FunctiontPath = "..\includes\dms-functions-tools-XX.ps1"

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


$HeartbeatFile = Join-Path $Directory $APPS2
Set-Content $HeartbeatFile -Value (Get-Date -Format "yyyyMMdd-HHmmss")


###################### MAIN  ###################################

Write-Log -LogMessage "******************* START *******************" -LogPath $DirectoryLog
try {
  
    if (!(Test-Path $Directory)) {
        New-Item -ItemType Directory -Path $Directory | Out-Null
    }

    Write-Log -LogMessage "Create File" -LogPath $DirectoryLog
    $HeartbeatFile = Join-Path $Directory $APPS2
    Set-Content $HeartbeatFile -Value (Get-Date -Format "yyyyMMdd-HHmmss")
    
    Write-Log -LogMessage "Waiting 10 secondes" -LogPath $DirectoryLog
    Start-Sleep -Seconds 10
    Write-Log -LogMessage "Remove file" -LogPath $DirectoryLog
    Remove-Item $HeartbeatFile

    Write-Log -LogMessage "Code executed successfully" -LogPath $DirectoryLog
} catch {
    Write-Log -LogMessage "Error occured while executing code: $_" -Append:$False -LogPath $DirectoryLog
}
Write-Log  "******************* END *******************" -LogPath $DirectoryLog
