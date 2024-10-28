<#
    Author: DAMIEN CHANTEPIE 
    Reviewed : ChatGPT
    Version: 2.0
    Date: 2023-02-14
    Description: Divers fonction pour intéragir avec l'active directory
        - Extraire les comptes utilisateurs ou ordinateur
        - Compte le nombre d'objet
        - Set un mot de passe
        - Move un objet
        - ...
    
    Release:
        - ?
    Ce fichier doit être inclu dans les autres fichiers powershell "c:\Chemin\Du\Fichier\FonctionScriptAD.ps1"
#>


#########################################################  
#############		Vérification en-tete    #############
#########################################################

$FunctiontPath = ".\dms-functions-tools-logs.ps1"
if (Test-Path $FunctiontPath) {
    . $FunctiontPath
} else {
    Write-Host "Le fichier de script spécialisé est introuvable à $FunctiontPath" -ForegroundColor Red
    exit
}


#########################################################  
#############		VARIABLES				#############
#########################################################

clear
$PSDefaultParameterValues['*:Encoding'] = 'utf8'


#########################################################  
#############		FUNCTIONS				#############
#########################################################


###################### INPUT CHECK ######################

<#
    .SYNOPSIS
        Vérifie le type de l'entrée et retourne la catégorie correspondante.
    .PARAMETER var
        Valeur à vérifier.
    .RETURNS
        Type de la variable: "CSV", "NotCSV", "Directory", "OU", etc.
    .EXAMPLE
        CheckInputType "C:\Data\file.csv"  # Retourne "CSV"
        CheckInputType "OU=Sales,DC=example,DC=com"  # Retourne "OU"
#>

Function CheckInputType($var) 
{
    # Vérification de la variable pour savoir si elle est vide
    if ([string]::IsNullOrEmpty($var)) 
    {
        return 
    }
    # Vérification pour savoir si la variable est un chemin de fichier
    elseif (Test-Path -Path $var -PathType Leaf) 
    {
        # Vérification pour savoir si le fichier existe
        if (!(Test-Path -Path $var)) 
        {
            return "NotFile"
        } 
        else 
        {
            # Vérification pour savoir si c'est un fichier CSV
            if ($var -like "*.csv") 
            {
                return "CSV"
            }elseif ($var -like "*.*") 
            # Si ce n'est pas un fichier CSV
            {
                write-host "test : NoCSV"
                return "NotCSV"
            }
            else
            {
               write-host "test : Name"
               return "Name"
            }
        }
     } 
     # Vérification pour savoir si la variable est un répertoire
     elseif (Test-Path -Path $var -PathType Container) 
     {
        return "Directory"
     } 
     # Si ce n'est ni un répertoire, ni un fichier
     else 
     {
        # Vérification pour savoir si la variable est une OU Active Directory
        if (($var -like "*OU=*")-or($var -like "*DC=*") )
        {
            return "OU"
        }
        # Si ce n'est ni une OU, ni un répertoire, ni un fichier
        else
        {
                        # Vérification pour savoir si c'est un fichier CSV
            if ($var -like "*.csv") 
            {
                return "NotCSV"
            }
            else
            {
                return "Name"
            }
        }
     }
}


###################### INFORMATION ADMINISTRATEUR LOCAL  ###################################

# Fonction pour obtenir les utilisateurs différents d'un groupe local
function GetLocalGroupMemberUserDiffOf($groupName, $excludedUser)
{
    # Obtenir les membres du groupe
    $groupMembers = Get-LocalGroupMember -Group $groupName

    # Filtrage pour ne garder que les utilisateurs et exclure le nom d'utilisateur spécifié
    $filteredMembers = $groupMembers | Where {$_.name -notlike $excludedUser} | Where {$_.objectClass -like 'Utilisateur'}

    # Renvoyer les membres filtrés
    return $filteredMembers
}

# Fonction pour obtenir les groupes différents d'un groupe local
function GetLocalGroupMemberGroupDiffOf($groupName, $excludedGroup)
{
    # Obtenir les membres du groupe
    $groupMembers = Get-LocalGroupMember -Group $groupName

    # Filtrage pour ne garder que les groupes et exclure le nom de groupe spécifié
    $filteredMembers = $groupMembers | Where {$_.name -notlike "*$excludedGroup"} | Where {$_.objectClass -like 'Groupe'}

    # Renvoyer les membres filtrés
    return $filteredMembers
}


###################### SUPPRESSIION ADMINISTRATEUR LOCAL  ###################################

function local_RemoveGroupMemberUserDiffOf($varGroup)
{
    ## Liste tous les comptes du groupe "VarGroup" sauf Administrateur
    $count=local_GetGroupMemberUserDiffOf($varGroup)
   ForEach ($var in $count) 
    {
        Get-LocalGroupMember "Administrateurs"
    } 
}


# Fonction pour supprimer les utilisateurs différents d'un groupe local
function RemoveLocalGroupMemberUserDiffOf($groupName, $excludedUser)
{
    # Obtenir les utilisateurs différents
    $filteredMembers = GetLocalGroupMemberUserDiffOf $groupName, $excludedUser

    # Supprimer les membres du groupe
    Remove-LocalGroupMember -Group $groupName -Member $filteredMembers
}

################################### SCRIPT AD ##############################

########################  USERS  ########################

 function FindUsers()
 {
    param(
    [string[]]$Name,
    [string]$Object="*",
    [string]$pathOutputFile="",
    [string]$filter="sAMAccountName"
    )


    Write-Host "Name : $Name" -ForegroundColor Green
    Write-Host "Object = $Object" -ForegroundColor Blue
    Write-Host "pathOutputFile = $pathOutputFile" -ForegroundColor Red
    Write-Host "filter = $filter" -ForegroundColor Yellow

    $inputType = CheckInputType($Name)

    $array = $Object -split ","
    $count=$array.Count

    switch ($inputType) 
    {
        "OU"    
        { 
            Write-Host "Name is an OU"  
            $Name = @($Name)
            
            if ($pathOutputFile -like "*.csv")
            {
                Foreach($OU in $Name)
                {   
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host "The variable contains multiple values."
                        Get-ADUser -Filter * -properties * -SearchBase $OU | Select-Object -Property $array | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = Get-ADUser -Filter * -properties * -SearchBase $OU  | Select-Object -ExpandProperty $Object| export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                    }  
                }
            }
            else
            {
                Foreach($OU in $Name)
                {   
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host "The variable contains multiple values."
                        Get-ADUser -Filter * -properties * -SearchBase $OU | Select-Object -Property $array 
                        $retour = get-aduser -Filter 'sAMAccountName -like "test"' -properties * | Select-Object -Property $Object
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = Get-ADUser -Filter * -properties * -SearchBase $OU  | Select-Object -Property  $Object 
                    } 
                }
                return $retour
            } 
        }
        "NotFile"
        {
            Write-Host "Input doesn't exist" 
        }


        "CSV"   
        { 
            Write-Host "Input is a CSV file" 
            $PathSource = Get-Content -path $Name

           if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $PathSource) 
                {
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host " 1 The variable contains multiple values."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -Property $array | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -Property  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                    }
                } 
            }
            else
            {
                ForEach ($var in $PathSource) 
                {
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host "The variable contains multiple values."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -Property $array
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -ExpandProperty $Object
                    }
                } 
                return $retour
            } 
        }
        "NotCSV" 
        {
            Write-Host "Input is a file, but not a CSV" 
        }
        "Directory" 
        { 
            Write-Host "Input is a directory" 
        }
        "Name" 
        { 
            Write-Host "Input is a Name" 
            if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $Name) 
                {
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host " 1 The variable contains multiple values."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -Property $array | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -Property  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                    }
                } 
            }
            else
            {
                ForEach ($var in $Name) 
                {
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host "The variable contains multiple values."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -Property $array
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = get-aduser -Filter '$filter -like $var' -properties * | Select-Object -ExpandProperty $Object
                    }
                } 
                return $retour
            } 
        }
        default 
        { 
            Write-Host "Input is empty" 
        }
    }
}

 ########################  COMPUTERS ########################

function FindComputers()
 {
    param(
    [string[]]$Name,
    [string]$Object="*",
    [string]$pathOutputFile="",
    [string]$filter="sAMAccountName"
    )


    Write-Host "Name : $Name" -ForegroundColor Green
    Write-Host "Object = $Object" -ForegroundColor Blue
    Write-Host "pathOutputFile = $pathOutputFile" -ForegroundColor Red
    Write-Host "filter = $filter" -ForegroundColor Yellow

        $array = $Object -split ","
    $count=$array.Count

  $inputType = CheckInputType($Name)

    switch ($inputType) 
    {
        "OU"    
        { 
            Write-Host "Input is an OU"  
            #$Name = @($Name)
            
            if ($pathOutputFile -like "*.csv")
            {
                Foreach($OU in $Name)
                {   
                     get-adcomputer -Filter * -properties *  -SearchBase $OU | Select-Object -Property $Object| export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                }
            }
            else
            {
                Foreach($OU in $Name)
                {   
                   $retour =   get-adcomputer -Filter * -properties *  -SearchBase $OU | Select-Object -ExpandProperty $Object
                   return $retour
                }
            } 
        }
        "NotFile"
        {
            Write-Host "Input doesn't exist" 
        }
        "CSV"   
        { 
            Write-Host "Input is a CSV file" 
            $PathSource = Get-Content -path $Name


            if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $PathSource) 
                {
                    #$var="*$var*"
                    get-adcomputer -Filter 'Name -like $var' -properties *   | Select-Object -Property  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                } 
            }
            else
            {
                ForEach ($var in $PathSource) 
                {
                    #$var="*$var*"
                    $retour = get-adcomputer -Filter 'Name -like $var' -properties *   | Select-Object -ExpandProperty  $Object 
                } 
                return $retour
            } 
        }
        "NotCSV" 
        {
            Write-Host "Input is a file, but not a CSV" 
        }
        "Directory" 
        { 
            Write-Host "Input is a directory" 
        }
        "Name" 
        { 
            Write-Host "Input is a Name" 
            if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $Name) 
                {
                    #$var="*$var*"
                    get-adcomputer -Filter 'Name -like $var' -properties *  | Select-Object -Property  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                } 
            }
            else
            {
                 ForEach ($var in $Name) 
                {
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host "The variable contains multiple values."
                        $retour = get-adcomputer -Filter 'Name -like $var' -properties * | Select-Object -Property $array 
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = get-adcomputer -Filter 'Name -like $var' -properties * | Select-Object -expandproperty $Object 
                    }
                } 
                return $retour
            } 
        }
        default 
        { 
            Write-Host "Input is empty" 
        }
    }
}

function FindObjectOU
{
    param (
        [string]$Name
    )   

    # Cherche l'objet parmi les unités d'organisation
    $filter = {(ObjectClass -eq "organizationalUnit") -and ((samaccountname -like $Name) -or (name -like $Name))}
   
    $ous = Get-ADObject -Filter $filter -SearchBase (Get-ADRootDSE).defaultNamingContext -SearchScope Subtree -Properties Name,DistinguishedName
    if ($ous.Count -gt 0) 
    {
        Write-Host "Unité(s) d'organisation trouvée(s) avec le nom '$Name':"
        return $ous | Select-Object -ExpandProperty DistinguishedName
    }
    else
    {
        # Cherche l'objet parmi les ordinateurs
        $filter = {(ObjectClass -eq "computer") -and (name -like $Name)}
        $computers = Get-ADComputer -Filter $filter -Properties Name,DistinguishedName
        if ($computers -ne $null) 
        {
            Write-Host "Ordinateur(s) trouvée(s) avec le nom '$Name':"
             $dnArray = $computers.DistinguishedName.Split(",")
             $ou = $dnArray[1..($dnArray.Count-1)] -join ","
            return $ou
        } 
    
        # Cherche l'objet parmi les utilisateurs
        $filter = {(ObjectClass -eq "user") -and ((samaccountname -like $Name'$') -or (name -like $Name))}
        $users = Get-ADUser -Filter $filter -Properties Name,DistinguishedName
        if ($users -ne $null)
        {
            Write-Host "Utilisateur(s) trouvée(s) avec le nom '$Name':"
            return $users.DistinguishedName
        }
    }
}

function MoveObjectParentOU
{
   param (
       [string]$Name
   )
        $object = Get-ADObject -Filter {(samAccountName -eq $Name) -or (name -eq $Name)} -Properties ObjectClass
        $dn = $object.DistinguishedName
        $ParentOU = FindParentOU -Name $Name
        write-host "$dn"
        write-host "$ParentOU"
        Move-ADObject –Identity "$dn" -TargetPath $ParentOU
}

function FindParentOU 
{
    param (
        [string]$Name
    ) 

    $ou = FindObjectOU -Name $Name
    $dnArray = $ou.Split(",")
    $ou = $dnArray[1..($dnArray.Count-1)] -join ","

    return $ou
}


########################  GROUPS ########################

function FindGroups()
 {
    param(
    [string[]]$Name,
    [string]$Object="*",
    [string]$pathOutputFile="",
    [string]$filter="sAMAccountName"
    )


    Write-Host "Name : $Name" -ForegroundColor Green
    Write-Host "Object = $Object" -ForegroundColor Blue
    Write-Host "pathOutputFile = $pathOutputFile" -ForegroundColor Red
    Write-Host "filter = $filter" -ForegroundColor Yellow

    $inputType = CheckInputType($Name)

    $array = $Object -split ","
    $count=$array.Count

    switch ($inputType) 
    {
        "OU"    
        { 
            Write-Name "Input is an OU"  
            $Name = @($Name)
            
            if ($pathOutputFile -like "*.csv")
            {
                Foreach($OU in $Name)
                {   
                     Get-ADGroup -Filter * -properties * -SearchBase $OU | Select-Object -Property $Object| export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                }
            }
            else
            {
                Foreach($OU in $Name)
                {   
                   $retour =   Get-ADGroup -Filter * -properties * -SearchBase $OU | Select-Object -ExpandProperty $Object
                   return $retour
                }
            } 
        }
        "NotFile"
        {
            Write-Host "Input doesn't exist" 
        }
        "CSV"   
        { 
            Write-Host "Input is a CSV file" 
            $PathSource = Get-Content -path $Name


            if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $PathSource) 
                {
                    #$var="*$var*"
                    get-ADGroup -Filter '$filter -like $var' -properties * | Select-Object -Property  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                } 
            }
            else
            {
                ForEach ($var in $PathSource) 
                {
                    ##$var="*$var*"
                    $retour = ADGroup -Filter '$filter -like $var' -properties * | Select-Object -ExpandProperty  $Object 
                } 
                return $retour
            } 
        }
        "NotCSV" 
        {
            Write-Host "Input is a file, but not a CSV" 
        }
        "Directory" 
        { 
            Write-Host "Input is a directory" 
        }
        "Name" 
        { 
            Write-Host "Input is a Name" 
            if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $Name) 
                {
                    #$var="*$var*"
                    get-ADGroup -Filter '$filter -like $var' -properties * | Select-Object -Property  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                } 

            }
            else
            {
                ForEach ($var in $Name) 
                {
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host "The variable contains multiple values."
                        $retour = get-ADGroup -Filter '$filter -like $var' -properties * | Select-Object -Property $array
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = get-ADGroup -Filter '$filter -like $var' -properties * | Select-Object -ExpandProperty $Object
                    }
                } 
                return $retour
            } 
        }
        default 
        { 
            Write-Host "Input is empty" 
        }
    }
}

function FindMemberGroups()
  {
    param(
    $Name,
    [string]$Object="*",
    [string]$pathOutputFile=""
    )


    Write-Host "Name : $Name" -ForegroundColor Green
    Write-Host "Object = $Object" -ForegroundColor Blue
    Write-Host "pathOutputFile = $pathOutputFile" -ForegroundColor Red

    $inputType = CheckInputType($Name)

    $array = $Object -split ","
    $count=$array.Count

    switch ($inputType) 
    {
      <#  "OU"    
        { 
            Write-Name "Input is an OU"  
            $Name = @($Name)
            
            if ($pathOutputFile -like "*.csv")
            {
                Foreach($OU in $Name)
                {   
                     Get-ADGroup -Filter * -properties * -SearchBase $OU | Select-Object -Property $Object| export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                }
            }
            else
            {
                Foreach($OU in $Name)
                {   
                   $retour =   Get-ADGroup -Filter * -properties * -SearchBase $OU | Select-Object -ExpandProperty $Object
                   Get-ADGroupMember $var -Recursive | Get-ADUser -Properties * | Select-Object
                   return $retour
                }
            } 
        } #>
        "NotFile"
        {
            Write-Host "Input doesn't exist" 
        }
        "CSV"   
        { 
            Write-Host "Input is a CSV file" 
            $PathSource = Get-Content -path $Name


            if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $PathSource) 
                {
                    #$var="*$var*"
                    Get-ADGroupMember $var -Recursive | Get-ADUser -Properties * | Select-Object  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                } 
            }
            else
            {
                ForEach ($var in $PathSource) 
                {
                    ##$var="*$var*"
                    $retour = Get-ADGroupMember $var -Recursive | Get-ADUser -Properties * | Select-Object -ExpandProperty  $Object 
                } 
                return $retour
            } 
        }
        "NotCSV" 
        {
            Write-Host "Input is a file, but not a CSV" 
        }
        "Directory" 
        { 
            Write-Host "Input is a directory" 
        }
        "Name" 
        { 
            Write-Host "Input is a Name" 
            if ($pathOutputFile -like "*.csv")
            {
                 ForEach ($var in $Name) 
                {
                    #$var="*$var*"
                    Get-ADGroupMember $var -Recursive | Get-ADUser -Properties * | Select-Object -Property  $Object | export-csv -Delimiter ';' -append -force $pathOutputFile -NoTypeInformation
                } 

            }
            else
            {
                ForEach ($var in $Name) 
                {
                    if ($count -gt 1 -or $Object -eq "*")
                    {
                        Write-Host "The variable contains multiple values."
                        $retour = Get-ADGroupMember $var -Recursive | Get-ADUser -Properties * | Select-Object -Property $array
                        #$retour = get-aduser -Filter 'sAMAccountName -like "test"' -properties * | Select-Object -Property $Object
                    }
                    else
                    { 
                        Write-Host "The variable contains a single value."
                        $retour = Get-ADGroupMember $var -Recursive | Get-ADUser -Properties * | Select-Object -ExpandProperty $Object
                    }
                } 
                return $retour
            } 
        }
        default 
        { 
            Write-Host "Input is empty" 
        }
    }
}


########################  COUNT  ########################

function CountADObjects
{
    param (
    [string]$objectType="*",
    [string]$OUPath,
    [string]$Scope="Subtree",
    [string]$filter
    )

    if ($filter -eq 1) {
        $filter = 'Enabled -eq "True"'
    } elseif ($filter -eq 0) {
        $filter = 'Enabled -eq "False"'
    } else {
        $filter = "*"
    }
    write-host "$filter"

    switch ($objectType)
    {
        '*' {
            $countComp = (Get-ADComputer -Filter $filter -SearchBase $OUPath -SearchScope "$Scope").Count
            Write-Host "Nombre d'ordinateur : $countComp "
            $countUser = (Get-ADUser -Filter $filter -SearchBase $OUPath -SearchScope "$Scope").Count
            Write-Host "Nombre d'utilisateur : $countUser "
            $count = $countComp+$countUser
            Write-Host "Nombre Total d'objet : $count"

            return $count
            break
        }
        'computer' {
            return $count = (Get-ADComputer -Filter $filter -SearchBase $OUPath -SearchScope "$Scope").Count
            break
        }
        'user' {
            return $count = (Get-ADUser -Filter $filter -SearchBase $OUPath -SearchScope "$Scope").Count
            break
        }
    }
}


################################ A MODIFIER #########################################################"
function AdAllComputerGroup($SecurityGroupName,$pathFile)
{
    $pathFile = get-content $pathFile
    Write-Host "AdAllComputerGroup : $SecurityGroupName, $pathFile"

     Foreach($Computer in $pathFile)
     {   
         Add-AdGroupmember -Identity $SecurityGroupName -Members  (Get-ADComputer $Computer)
     }
 }

function RemoveAllComputerGroup($SecurityGroupname)
{
    $Members = (FindGroupMember $SecurityGroupname name)
    Write-Host "RemoveAllComputerGroup : $SecurityGroupname, $Members"
 
     Foreach($Computer in $Members)
     {   
         Remove-ADGroupMember -Identity "$SecurityGroupname" -members (Get-ADComputer $Computer) -Confirm:$false 
     }
 }


<#
 function RemoveGroupMemberOU($OU,$PATHLOG="RemoveGroupMemberOU.save.log")
{
    $countGrp = 0

    $Members = (FindAllOUUser $OU SamAccountName)
    Write-Host "RemoveGroupMemberOU : $OU, $Members"
    echo "$(get-date -format g)" >> $PATHLOG\$DatePath"DisableAccountRemoveRight.save.log"
     Foreach($Users in $Members)
     {   
        #$UserMemberOf = Get-ADPrincipalGroupMembership $Users | Select-Object -ExpandProperty SamAccountName
        $UserMemberOf = Get-ADUser -identity $Users -Properties memberOf | Select-Object -ExpandProperty memberof

        Foreach($Group in $UserMemberOf)
        {
            #if ($Group -notlike "Domain Users" )
            $GRoupsplit = ($Group.Split(",")[0]).Split("=")[1]

            if($GRoupsplit -notlike "Domain Users")
            {  
                echo "Group : $GRoupsplit, User : $Users" >> $PATHLOG\$DatePath"DisableAccountRemoveRight.save.log"
                #Remove-ADGroupMember -Identity $Group -Members $Users -Confirm:$false
                $countGrp+=1
            }  
                 
        }
     }
     echo "$(get-date -format g) : Droits Supprimés : $countGrp" >> $PATHLOG\$DatePath"DisableAccountRemoveRight.save.log"
     return $countGrp
}
#>


function RemoveGroupMemberOU()
{
    param(
    [string[]]$OU,
    [string]$Object="*",
    [string]$pathOutputFile=""
    )

    $countGrp = 0
    $members = FindUsers -Name $OU -Object SamAccountName
    Write-Host "RemoveGroupMemberOU : $OU, $members"
    
    $members | ForEach-Object {
        $groups = Get-ADPrincipalGroupMembership $_ | Where-Object { $_.Name -notlike "Domain Users" }
        foreach ($group in $groups) {
            Write-Host "Group : $($group.Name), User : $_"
            #Remove-ADGroupMember -Identity $group -Members $_ -Confirm:$false
            $countGrp++
        }
    }
    
    Add-Content -Path "$LogPath" -Value "$((Get-Date).ToString('g')) : Droits Supprimés : $countGrp"
    return $countGrp
}


########################  PASSWORD  ########################


function ModifyPasswordUser($user, $Object="*", $pathFile="%userprofile%\FindSpecUser.csv")
{
        Set-ADUser -Identity $user -NewPassword (ConvertTo-SecureString -AsPlainText "ResetPassword-2022" -Force) -ChangePasswordAtLogon $true  
}


function ModifyPasswordUsersOU($OUListVar,$Object,$pathFile)
{
    Write-Host "ModifyPasswordUsersOU : $OUListVar, $Object, $pathFile"
    FindAllOUUser $OUListVar $Object $pathFile
}


########################  Remplacer chaine de caractere ########################
function ChangeVarString($ReplaceVar="accountExpires,Account,LockoutTime,AccountNotDelegated,c,CannotChangePassword,CanonicalName,City,CN,co,Company,Country,countryCode,Created,createTimeStamp,Department,Description,DisplayName,DistinguishedName,Division,DoesNotRequirePreAuth,dSCorePropagationData,EmailAddress,EmployeeID,EmployeeNumber,Enabled,extensionAttribute1,extensionAttribute2,extensionAttribute3,extensionAttribute4,extensionAttribute5,extensionAttribute6,extensionAttribute7,extensionAttribute8,extensionAttribute9,extensionAttribute10,extensionAttribute11,extensionAttribute12,extensionAttribute13,extensionAttribute14,extensionAttribute15,GivenName,HomePhone,Initials,ipPhone,isDeleted,l,LockedOut,lockoutTime,mail,mailNickname,Manager,MemberOf,MobilePhone,modifyTimeStamp,mS-DS-ConsistencyGuid,msDS-ExternalDirectoryObjectId,msExchMobileMailboxFlags,ObjectCategory,ObjectClass,ObjectGUID,objectSid,Office,OfficePhone,Organization,OtherName,PasswordExpired,PasswordLastSet,PasswordNeverExpires,PasswordNotRequired,PostalCode,PrimaryGroup,primaryGroupID,PrincipalsAllowedToDelegateToAccount,pwdLastSet,SamAccountName,sAMAccountType,SID,sn,st,State,StreetAddress,Surname,telephoneNumber,Title,userAccountControl,UserPrincipalName,uSNChanged,uSNCreated,whenChanged,whenCreated")
{
    Write-Host "Avant : $ReplaceVar"
    $ReplaceVar=$ReplaceVar.replace('accountExpires', "@{Name='accountExpires';Expression={[datetime]::FromFileTime($_.'accountExpires')}}")
    Write-Host "Apres : $ReplaceVar"
}


############################ TEST #############################





