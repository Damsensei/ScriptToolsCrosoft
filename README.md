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

```
. "path\to\dms-functions-tools.ps1"  # Charger le fichier de fonctions
```


### 2. `dms-main-ou-usb-rights.ps1`

**Description** : Script principal pour la gestion des droits USB en fonction des unités organisationnelles (OU). Il permet de vérifier, mettre à jour et révoquer les droits USB attribués aux ordinateurs selon des critères définis. Les données sont enregistrées dans un fichier CSV pour un suivi détaillé.

**Utilisation** :

- Création de fichiers CSV : Génère des fichiers pour suivre les ordinateurs autorisés et les exceptions USB.
- Mise à jour des droits : Actualise les droits USB en fonction des données contenues dans le fichier CSV.
- Révocation automatique des droits : Supprime les droits USB après une période de temps spécifiée.
- Journalisation : Enregistre des logs pour chaque action exécutée, permettant l'audit et la traçabilité.
