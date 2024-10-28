# Importation des utilisateurs depuis le fichier CSV spécifié
$users = import-csv -path ".\users-db.csv" -delimiter ","

# Création de l'utilisateur 
foreach($user in $users) 
{ 
    $pass= "Supinfo971" 
    $nom= $user.lastname
    $prenom= $user.firstname  
    $ou= $user.ou
    $login= $prenom + "."+ $nom
    $DisplayName = $prenom + " "+ $nom 
    
    #Ajout des données dans la base Active Directory 
    New-ADuser -name $nom -DisplayName $DisplayName -givenname $prenom -SamAccountName $login -Path $ou 
}