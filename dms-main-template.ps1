<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : /
    Version: 1.0
    Date: 2023-02-15
    Description: Template des fichiers MAIN
#>


###################### INCLUDE  ###################################
. "FonctionScriptAD.ps1"

###################### VARIABLES  ###################################

$APPS = "APPLICATION"
$APPS2 = "Template"

$DirectoryLog = "C:\CYBER\LOG\$APPS"+"_"+"$APPS2.log"

$Directory = "C:\CYBER\SOURCES\$APPS\$APPS2"


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
