@echo OFF
:: Désactive l'affichage des commandes exécutées dans la console

:: Crée un fichier de liste d'accès avec la date et l'heure actuelle dans le nom
dir /q \\PATHtoZAFRepo\Personnels /n > "ListeAccesOSCAR_%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%_%time:~0,2%h%time:~3,2%min.txt"

:: Initialise les compteurs utilisés pour suivre le nombre de fichiers trouvés
set /a compteur1=0
set /a compteur2=0

:: Active le delayed expansion pour utiliser les variables dynamiques dans les boucles
setlocal enabledelayedexpansion

:: Trouve tous les fichiers dont le nom commence par "ListeAccesOSCAR_" et enregistre cette liste dans un fichier temporaire
dir | find "ListeAccesOSCAR_" > "tmp.txt"

:: Parcourt chaque ligne du fichier temporaire pour extraire le nom des fichiers et les stocker dans des variables dynamiques (var1, var2, etc.)
FOR /f "tokens=4 delims= " %%i in (tmp.txt) do ( 
    set /a compteur1+=1
    set var!compteur1!=%%i
)

:: Compte le nombre de fichiers qui commencent par "ListeAccesOSCAR_" et enregistre ce nombre dans nb1
dir | find "ListeAccesOSCAR_" /C > "tmp.txt"
FOR /f "tokens=1 delims= " %%j in (tmp.txt) do ( 
    set nb1=%%j
)
echo %nb1%  :: Affiche le nombre total de fichiers trouvés

:: Calcule nb2 comme étant le nombre total de fichiers - 1 (utile pour obtenir les deux fichiers les plus récents)
set /a nb2=%nb1%-1
echo !nb2!  :: Affiche la valeur de nb2

:: Trouve les deux derniers fichiers en fonction des valeurs de nb1 et nb2 et les stocke dans un fichier temporaire
set | find "var%nb1%" > "tmp.txt"
set | find "var!nb2!" >> "tmp.txt"

:: Extrait les noms des deux derniers fichiers (comp1 et comp2) à partir de tmp.txt
FOR /f "tokens=2 delims==" %%i in (tmp.txt) do ( 
    set /a compteur2+=1
    set comp!compteur2!=%%i
)

:: Compare les deux fichiers les plus récents et affiche les différences ligne par ligne
FC "%comp1%" "%comp2%" /N /lb

:: Supprime le fichier temporaire pour nettoyer après exécution
del "tmp.txt" 

:: Met en pause le script pour que l'utilisateur puisse voir les résultats avant la fermeture
pause
