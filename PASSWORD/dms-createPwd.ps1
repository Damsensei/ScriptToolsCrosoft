# ---------------------------------------------------------------
# - Le script sauvegarde un mot de passe et le chiffre dans un fichier -
# ---------------------------------------------------------------


# ****************** Init Variables ******************
# Repertoire de destination
$Rep = "C:\Users\damien.chantepie\Documents\SCRIPT\OSCAR\Copy fichier - Cacher mdp script"
# Nom du fichier
# Variable qui contient la clef de cryptage (doit contentir 24 elements) du type #$Clef_Cryptage = (42,32,68,105,100,105,101,114,32,80,105,110,115,111,110,32,45,32,50,48,49,51,32,42)
$NameFileKey = "fichier.key"
$key = get-content $Rep$NameFileKey
$pwd = "pwdEncrypted.pwd"


# Affiche une fentre de saisie pour la saisie du mot de passe
# Transforme le mot de passe en clair ($Password) en mot de passe securise
# Sauvegarde du Mot de passe chiffre ($Pass_Crypt) dans le fichier $fichier dans le repertoire $Rep

Read-Host -AsSecureString  "Entrer un mot de passe" | ConvertFrom-SecureString -key $key| Out-file $Rep$pwd
