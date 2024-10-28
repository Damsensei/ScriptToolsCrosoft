dms-main-ou-usb-rights.ps1
Description : Script principal pour la gestion des droits USB en fonction des unités organisationnelles (OU). Il permet de vérifier, mettre à jour et révoquer les droits USB attribués aux ordinateurs selon des critères définis. Les données sont enregistrées dans un fichier CSV pour un suivi précis.

Fonctionnalités principales :

Création de fichiers CSV : Génère des fichiers pour suivre les ordinateurs autorisés et les exceptions USB.
Mise à jour des droits : Actualise les droits USB en fonction des données du fichier CSV.
Révocation automatique des droits : Supprime les droits USB après une période de temps spécifiée.
Journalisation : Écrit des logs pour chaque action exécutée pour audit et traçabilité.
Utilisation :

powershell
Copier le code
. "path\to\dms-functions-tools.ps1"   # Charger les fonctions utilitaires
. "path\to\dms-main-ou-usb-rights.ps1" # Exécuter le script principal
3. dms-main-template.ps1
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
Installation
Clonez le dépôt :

bash
Copier le code
git clone https://github.com/votre-utilisateur/votre-depot.git
Chargez les fonctions avant d'exécuter les scripts principaux :

powershell
Copier le code
. "path\to\dms-functions-tools.ps1"
Exécutez le script principal souhaité :

powershell
Copier le code
. "path\to\dms-main-ou-usb-rights.ps1"
Contributions
Les contributions sont les bienvenues ! Veuillez ouvrir une pull request pour toute suggestion d'amélioration ou nouvelle fonctionnalité.

Licence
Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.
