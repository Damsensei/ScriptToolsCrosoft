# -------------------------------------------------------------------------------------
# - Le script recupere un mot de passe chiffre dans un fichier pour le mettre en clair -
# -------------------------------------------------------------------------------------


# ****************** Init Variables ******************
# Repertoire de destination
$Rep = "C:\Users\damien.chantepie\Documents\SCRIPT\OSCAR\Copy fichier - Cacher mdp script"
# Nom du fichier
# Variable qui contient la clef de cryptage (doit contentir 24 elements) du type #$Clef_Cryptage = (42,32,68,105,100,105,101,114,32,80,105,110,115,111,110,32,45,32,50,48,49,51,32,42)
$NameFileKey = "fichier.key"
$key = get-content $Rep$NameFileKey
$pwd = "pwdEncrypted.pwd"

$login = ".\admin-toto"
$password = Get-Content $Rep$pwd | ConvertTo-SecureString -Key $key; 


# recupere le mot de passe crypte, le decrypte avec la clef $Clef_Cryptage pour le mettre en format securiser
$Lec_password = get-Content $rep$pwd | ConvertTo-SecureString -key $key

# Convertie le mot de passe 
#securiser en mot de passe en clair
$PasswordLec = ([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Lec_password)))
# Affiche le resultat
Write-Host "Password: $PasswordLec"

$credentials = New-Object System.Management.Automation.Pscredential($login, $password) 
#Start-Process "C:\Users\damien.chantepie\Desktop\copy.bat"  -Credential $credentials

#Copy-Item "C:\Users\damien.chantepie\Desktop\test.txt" -Destination "C:\Users\damien.chantepie\Desktop\Nouveau dossier\" -Credential $credentials