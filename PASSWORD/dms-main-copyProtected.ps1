# -------------------------------------------------------------------------------------
# - Le script recupere un mot de passe chiffre dans un fichier pour le mettre en clair -
# -------------------------------------------------------------------------------------


# ****************** Init Variables ******************
# Repertoire de destination
$Rep = "%userprofile%\Bureau\"
# Nom du fichier
# Variable qui contient la clef de chiffrement (doit contentir 24 elements) du type #$Clef_Cryptage = (42,32,68,105,100,105,101,114,32,80,105,110,115,111,110,32,45,32,50,48,49,51,32,42)
$NameFileKey = "fichier.key"
$key = get-content $Rep$NameFileKey
$pwd = "pwdEncrypted.pwd"

$login = ".\admin-toto"
$password = Get-Content $Rep$pwd | ConvertTo-SecureString -Key $key; 

$credentials = New-Object System.Management.Automation.Pscredential -Argumentlist $login,$password 
Start-Process "C:\Users\damien.chantepie\Desktop\copy.bat"  -Credential $credentials
