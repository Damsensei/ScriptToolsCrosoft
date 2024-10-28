# DMS PowerShell Scripts

Ce dépôt contient des scripts PowerShell utiles pour la gestion des droits USB et la gestion des Unités Organisationnelles (OU) dans un environnement Active Directory. Ces scripts sont conçus pour automatiser les tâches administratives, notamment le suivi des droits USB et le contrôle d'accès basé sur les OUs.

## Contenu du dépôt

### 1. `dms-functions-tools.ps1`

**Description** : Ce fichier regroupe les fonctions utilitaires courantes utilisées dans différents scripts. Il inclut des fonctions pour gérer les droits d’accès, les journaux, la gestion des utilisateurs et groupes locaux, ainsi que des opérations sur les fichiers CSV. Ce script doit être chargé en amont pour que les autres scripts puissent l’utiliser.

**Fonctions principales** :
- `Write-Log` : Écrit un message dans un fichier de log avec horodatage.
- `GetLocalGroupMemberUserDiffOf` : Récupère les utilisateurs d’un groupe local tout en excluant un utilisateur spécifié.
- `RemoveLocalGroupMemberUserDiffOf` : Supprime les utilisateurs d’un groupe local, à l’exception de ceux définis dans les exceptions.
- Fonctions d’import/export CSV pour les audits et rapports.

**Utilisation** :
```powershell
. "path\to\dms-functions-tools.ps1"  # Charger le fichier de fonctions
Write-Log -LogMessage "Test de la fonction de log"


dms-main-template.ps1
Description : Modèle de script principal pour les nouveaux projets ou tâches. Ce template contient la structure de base avec des sections de documentation standardisées, un modèle de gestion des erreurs, et des exemples d'utilisation des fonctions de dms-functions-tools.ps1.

Sections incluses :

Documentation initiale : Modèle de description, auteur, version et date.
Variables : Structure prête à accueillir les variables globales.
Bloc try-catch : Gestion des erreurs intégrée pour une exécution robuste.
Exemple de log : Utilisation de la fonction Write-Log pour un suivi standardisé.
Utilisation :

Dupliquez dms-main-template.ps1 pour créer un nouveau script.
Personnalisez les sections selon vos besoins.
Prérequis
PowerShell 5.1 ou supérieur.
Permissions administratives pour exécuter des commandes de gestion de groupe local et d’accès réseau.
