# Sauvegarde O2Switch avec Restic

* [Documentation en anglais.](README.MD)
* [Documentation en français.](README-fr.MD) 

## Description du script<a name="script-description"></a>

Ce script shell Bash est conçu pour sauvegarder les données de votre site web et les bases de données MySQL de l'infrastructure [O2Switch](https://www.o2switch.fr/) vers un service cloud distant de votre choix.

Si vous hébergez uniquement des sites WordPress sur O2Switch, vous devrez peut-être seulement modifier les fichiers `backup-restic-conf.txt` et `backup-restic-pwd.txt`, car le comportement par défaut du script sera suffisant pour sauvegarder toutes vos installations WordPress.

Le script peut détecter automatiquement les installations WordPress situées dans des répertoires à la racine de votre installation et sauvegarder leurs bases de données. Il utilise Restic et Rclone pour sauvegarder vos données de manière sécurisée sur un emplacement distant. Restic est un outil de sauvegarde puissant et facile à utiliser qui offre un chiffrement solide, une déduplication efficace et une compression pour vous aider à sauvegarder et restaurer vos données en toute sécurité. Rclone est un outil polyvalent et fiable en ligne de commande qui vous permet de synchroniser et de transférer des fichiers entre plusieurs fournisseurs de stockage cloud et d'autres types de systèmes de stockage.

La décision d'utiliser ce script pour sauvegarder vos données avec l'infrastructure d'O2Switch est basée sur leur recommandation aux utilisateurs de maintenir leurs propres sauvegardes en plus de leur solution [Jetbackup](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup) pour la restauration des sauvegardes. Ce script est conçu pour suivre leur recommandation et vous fournir une solution de sauvegarde sécurisée et efficace.

# Table des matières

- [Description du script](#script-description)
- [Clause de non-responsabilité](#disclaimer)
- [Procédure : Explication rapide](#how-to-quick-explanation)
- [Procédure : Explication détaillée](#how-to-detailed-explanation)
  - [Prérequis](#prerequisite)
  - [Installation étape par étape et configuration](#step-by-step-installation-and-configuration)
- [Plus de détails](#more-details)
  - [Qu'est-ce que le script modifie sur mon système](#change-script)
  - [Arguments du script](#script-arguments)
  - [Configuration du script](#script-configuration)
- [Étapes suivantes](#next-steps)
- [Remerciements](#acknowledgments)
- [Licence](#license)


Clause de non-responsabilité<a name="disclaimer"></a>
------------------
* Je ne suis pas affilié à [O2Switch](https://www.o2switch.fr/)
* Ce script est fourni en l'état et sans aucune garantie. L'auteur n'est pas responsable des problèmes pouvant survenir lors de l'utilisation de ce script, y compris, mais sans s'y limiter, la perte de données, les plantages du système ou d'autres problèmes. Bien que ce script soit destiné à la sauvegarde de données, veuillez noter que les sauvegard

es peuvent échouer pour diverses raisons, il est donc important de sauvegarder vos données avant d'exécuter le script. Utilisez-le à vos propres risques et assurez-vous de sauvegarder vos données avant d'exécuter le script.
* Si vous n'êtes pas sûr de la façon d'utiliser ce script ou si vous rencontrez des problèmes lors de son exécution, O2Switch propose Jetbackup comme solution de sauvegarde. Pour plus d'informations sur l'utilisation de Jetbackup, veuillez consulter leur [page FAQ](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup)

Procédure : Explication rapide<a name="how-to-quick-explanation"></a>
-------------------------------------------------------

Cette brève procédure explique les étapes à suivre pour les utilisateurs familiers avec Restic et les capacités et restrictions d'O2Switch.
Par défaut, le script sauvegarde tous vos fichiers à l'exception de ceux situés dans des dossiers cachés à la racine de votre serveur web.
Toutes les bases de données WordPress seront automatiquement sauvegardées.
Suivez ces étapes :

* Installez le script. Téléchargez-le dans le répertoire racine de votre serveur web, puis exécutez la commande suivante :
```shell
$ ./backup.sh --install
```
* Les seuls fichiers obligatoires à modifier sont les suivants dans le répertoire `$HOME/scripts/backup` :
  * `backup-restic-conf.txt` : Entrez le chemin vers votre dépôt Restic.
  * `backup-restic-pwd.txt` : Entrez le mot de passe de votre dépôt Restic.
* Vous pouvez maintenant exécuter la commande suivante depuis le répertoire `$HOME/scripts/backup` :
```shell
$ ./backup.sh --backup
```

Procédure : Explication détaillée<a name="how-to-detailed-explanation"></a>
-----------------------------------------------------

Prérequis<a name="prerequisite"></a>
---------------------
* Avant de commencer avec le script, il est conseillé d'avoir une certaine expérience avec Restic ou Rclone. Si vous n'êtes pas familiarisé avec ces outils, ne vous inquiétez pas - j'ai inclus des liens vers la documentation qui peut vous aider à vous mettre à jour. La configuration étape par étape couvre également les bases.
  * [Documentation sur Restic](https://restic.readthedocs.io/en/latest/010_introduction.html)
  * [Documentation pour utiliser Rclone avec Restic](https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html?highlight=rclone#other-services-via-rclone)

* Restic peut sauvegarder vers plusieurs services cloud, tels que Rest Server, Amazon S3, Minio et Azure, ainsi que localement ou avec SFTP.
  * Si vous prévoyez d'utiliser SFTP, vous devrez déclarer l'adresse IP de votre serveur distant dans l'interface Cpanel pour débloquer le trafic. Nous avons inclus un lien vers la documentation officielle d'O2switch qui explique comment faire cela.
    * [Documentation officielle d'O2switch](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/whitelist-firewall)
    * Cpanel > Outils > Autorisation SSH,

 puis déclarez votre adresse IP de serveur distant sur le port 22
  * Notez que les services OneDrive sont autorisés par O2switch et peuvent être utilisés par défaut avec Rclone.

* Enfin, il est important d'avoir un accès shell à votre hébergement web. Si vous ne l'avez pas déjà demandé, j'ai inclus un lien vers la documentation d'O2switch qui explique comment le faire :
  * https://faq.o2switch.fr/hebergement-mutualise/acces-ssh-shell-cli-cmdline

J'espère que cela vous aidera à vous préparer à utiliser le script. Si vous avez des questions ou rencontrez des problèmes, n'hésitez pas à me contacter, je suis là pour vous aider !

Installation étape par étape et configuration<a name="step-by-step-installation-and-configuration"></a>
-----------------------------------------------------

### Étape 1 - Téléchargez le script et installez-le.

```shell
  $ # Copiez le script backup.sh dans votre répertoire racine "/home2/nom_utilisateur/" depuis votre cpanel
  $ # ou en utilisant 'nano' pour créer un nouveau fichier et copiez-collez le contenu de backup.sh dans votre fichier.
  $ # Créez un nouveau fichier avec nano et collez le contenu de backup.sh dedans. Enregistrez le fichier avec Ctrl+O et fermez-le avec Ctrl+X
  $ nano backup.sh
  $ # Rendez le script exécutable avec la commande suivante.
  $ chmod +x backup.sh
  $ # Exécutez le script avec l'argument --install.
  $ backup.sh --install
```
### Étape 2 - Modifier 'backup-restic-pwd.txt'

Modifiez le fichier `backup-restic-pwd.txt` et enregistrez-y le mot de passe que vous souhaitez utiliser pour votre sauvegarde Restic. 
N'oubliez pas que ce mot de passe est essentiel pour plusieurs tâches Restic, donc assurez-vous d'en conserver une copie en lieu sûr en dehors d'O2switch. Bien que je n'anticipe aucun problème, nous devons comprendre l'importance de ce mot de passe en cas de crash massif de l'infrastructure O2switch. Sans lui, vous ne pourrez pas accéder à vos sauvegardes Restic. Prenez donc un moment pour vous assurer que ce mot de passe est bien protégé et sauvegardé en toute sécurité !

### Étape 3 - Préparez un dépôt distant pour accueillir vos fichiers.

Dans tous les cas, exécutez d'abord la commande suivante dans votre shell : `export PATH=$PATH:~/scripts/backup`
Cette commande vous permet d'utiliser les exécutables "restic" et "rclone" pendant la durée de votre session sans avoir à taper leur chemin complet. (par exemple : $HOME/scripts/backup/./restic)

#### 3.1 Exemple avec SFTP

Assurez-vous d'autoriser le trafic vers votre serveur distant : [Whitelist Firewall](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/whitelist-firewall)
Vous devriez disposer d'informations d'identification pour vous connecter à votre serveur distant.
Voici la commande pour préparer une clé SSH sur le serveur O2switch et la copier

 sur votre serveur distant.
Cela permettra à votre script de se connecter sans mot de passe à votre serveur distant.

```shell
  $ ssh-keygen
  $ # Utilisez les paramètres par défaut sans mot de passe
  $ ssh-copy-id -i ~/.ssh/id_rsa.pub user_remoteserver@host_remoteserver.com
  $ # Vous serez invité à entrer votre mot de passe pour le serveur distant.
  $ # Après cela, la clé SSH sera copiée sur le serveur distant et aucun mot de passe ne sera nécessaire.
```
Il est temps de préparer votre dépôt restic

```shell
$ restic -r "sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic" init -p $HOME/scripts/backup/backup-restic-pwd.txt
$ # Tant que l'utilisateur distant dispose des autorisations suffisantes, le répertoire sera créé automatiquement : /home/user_remoteserver/restic
$ # Vous n'avez pas besoin de taper votre mot de passe Restic car il est chargé à partir du fichier backup-restic-pwd.txt
```
#### 3.2 Exemple avec rclone

Si vous choisissez d'utiliser l'option SFTP, vous n'avez pas besoin de suivre les instructions fournies dans l'exemple rclone. En créant ce guide, j'ai constaté que Mega avait été intégré à rclone de manière très utile. Par conséquent, prenez le temps de créer un compte Mega, qui vous donnera accès à 50 Go de stockage gratuit. Après avoir créé le compte, vous pouvez exécuter la commande suivante :

```shell
$ rclone config create mymega mega user user@example.com pass Your-Password
  [mymega]
  type = mega
  user = user@example.com
  pass = *** ENCRYPTED ***
```
Pour vérifier que votre configuration rclone est correcte, nous allons créer un fichier appelé "demo.txt" et confirmer son existence. Vous pouvez également vérifier cela en même temps à l'aide de votre navigateur web.

```shell
# Créer un fichier
$ rclone touch mymega:demo.txt
# Vérifier l'existence du fichier
$ rclone ls mymega:
  0 demo.txt
```

Il est temps de préparer votre dépôt restic

```shell
$ restic -r "rclone:mymega:restic" init -p $HOME/scripts/backup/backup-restic-pwd.txt
$ # Tant que l'utilisateur distant dispose des autorisations suffisantes, le répertoire sera créé automatiquement : /restic
$ # Vous n'avez pas besoin de taper votre mot de passe Restic car il est chargé à partir du fichier backup-restic-pwd.txt
```

### Étape 4 - Modifiez les fichiers de configuration

Maintenant, modifions les fichiers de configuration.

* `backup-restic-conf.txt` : Si vous souhaitez conserver le comportement par défaut du script, ne modifiez que les champs 'restic_repo' et 'restic_receive_email'.
  * `restic_repo=` Doit être similaire à la commande que vous avez précédemment utilisée pour initialiser votre dépôt Restic. 
    * Exemple avec SFTP : sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic
    * Exemple avec r

clone : rclone:mymega:restic
  * `restic_receive_email` Définit l'adresse e-mail qui recevra les journaux.
  * `restic_log_file` Modifiez cette valeur si vous souhaitez donner un nom spécifique à votre fichier de journal.
  * `restic_log_days` Définit combien de jours conserver les fichiers de journal.
  * `restic_dump_days` Définit combien de jours conserver les sauvegardes des bases de données MySQL.
* `backup-db-others.txt` : Modifiez ce fichier si vous souhaitez ajouter des bases de données spécifiques non liées à une installation WordPress et que vous souhaitez sauvegarder.
  * Vous devrez créer un utilisateur et lui accorder les autorisations suivantes uniquement pour ces bases de données : `SELECT / LOCK TABLES / SHOW VIEW`
  * Documentation d'O2Switch : [Base de données MySQL](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/base-donnees-mysql)
* `backup-excluded-dirs.txt` : Modifiez ce fichier pour ajouter des dossiers à exclure de la sauvegarde. Vérifiez le contenu, certains dossiers sont exclus par défaut.
  * Vous pouvez utiliser la commande `ls -dA .*/ | grep -Ev '^(\./|\.\./)$'` à la racine de votre répertoire personnel pour obtenir la liste de tous les dossiers cachés à la racine de votre répertoire personnel. La plupart de ces répertoires peuvent être exclus de la sauvegarde. Je vous recommande de les ajouter dans ce fichier.

### Étape 5 - Définissez une tâche cron

Vous souhaitez que ce script s'exécute automatiquement, pour cela nous utilisons crontab. 
Vous pouvez le faire depuis le [cpanel d'O2switch](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/taches-cron) ou en ligne de commande. 
```shell
$ EDITOR=nano crontab -e
$ # Ajoutez la ligne suivante pour lancer une sauvegarde tous les jours à minuit :
$ 0 0 * * * $HOME/scripts/backup/backup.sh --backup
$ # Ctrl + o pour enregistrer vos modifications et Ctrl + x pour quitter nano
```

### Étape 6 - Testez notre installation / lancez notre première sauvegarde

À ce stade, vous êtes probablement impatient de tester si votre sauvegarde va fonctionner correctement.
Vous pouvez exécuter la commande suivante pour lancer votre première sauvegarde : `$HOME/scripts/backup/backup.sh --backup`

Plus de détails<a name="more-details"></a>
-------------------------------

Qu'est-ce que le script modifie sur mon système ?<a name="script-change"></a>
--------------------------------------

Le script va :
* Créer les répertoires suivants :
  * $HOME/backup-db
  * $HOME/scripts
  * $HOME/scripts/backup
  * $HOME/scripts/backup/logs
* Créer les fichiers suivants :
  * $HOME/scripts/backup/backup-restic-pwd.txt
  * $HOME/scripts/backup/backup-restic-conf.txt
  * $HOME/scripts/backup/backup-excluded-dirs.txt
  * $HOME/scripts/backup/backup-db-others.txt


  * $HOME/scripts/backup/backup-pgdb-others.txt
* Télécharger les exécutables nécessaires :
  * Télécharger la dernière version de Restic depuis GitHub et la décompresser dans le répertoire : $HOME/scripts/backup
  * Télécharger la dernière version de Rclone depuis GitHub et la décompresser dans le répertoire : $HOME/scripts/backup
* S'assurer que le fichier de script backup.sh est situé dans le dossier $HOME/scripts/backup

Arguments du script<a name="script-arguments"></a>
---------------------------------

Le script peut être utilisé avec deux options : `--backup` et `--install`.

L'option `--backup` est utilisée pour sauvegarder les bases de données MySQL des installations WordPress et d'autres bases de données non liées à WordPress, ainsi que des répertoires spécifiés. Pour utiliser cette option, exécutez le script avec la commande suivante :

L'option `--install` est utilisée pour installer le script de sauvegarde, télécharger la dernière version de Restic et préparer l'environnement pour exécuter la sauvegarde.
Si lors de l'exécution de "./backup.sh --backup" un fichier manquait, l'option --install peut être utilisée pour recréer le fichier manquant.

Configuration du script<a name="script-configuration"></a>
--------------------------------

Avant de personnaliser le comportement du script, il est bon de noter que si vous hébergez uniquement des sites WordPress sur O2switch, vous n'aurez qu'à modifier les fichiers `backup-restic-conf.txt` et `backup-restic-pwd.txt`. Le comportement par défaut du script devrait être suffisant pour sauvegarder toutes vos installations WordPress.

Cela étant dit, si vous avez besoin de personnaliser le script, vous pouvez modifier les fichiers suivants :

* `backup-restic-conf.txt` : Ce fichier contient plusieurs variables modifiables pour gérer le comportement du script.
* `backup-restic-pwd.txt` : Vous devez entrer le mot de passe pour votre dépôt Restic.
* `backup-db-others.txt` : Si vous devez sauvegarder d'autres bases de données MySQL en dehors de la sauvegarde automatique de la base de données WordPress, vous pouvez les ajouter à ce fichier.
* `backup-pgdb-others.txt` : Si vous avez besoin de sauvegarder des bases de données PosteGreSQL.
* `backup-excluded-dirs.txt` : Si vous souhaitez exclure certains dossiers de la sauvegarde, vous pouvez les ajouter à ce fichier. Certains dossiers sont déjà exclus par défaut. Vous pouvez utiliser la commande `ls -dA .*/ | grep -Ev '^(\./|\.\./)$'` à la racine de votre répertoire personnel pour obtenir la liste de tous les dossiers cachés à la racine de votre répertoire personnel. La plupart de ces répertoires peuvent être exclus de la sauvegarde, je vous recommande donc de les ajouter à ce fichier.

Les variables suivantes dans le script `backup.sh` peuvent être modifiées pour changer le comportement du script. Mais je recommande de conserver les valeurs par défaut.

*   `DIR_ROOT` : Cette variable spécifie le répertoire racine que le script analyse pour trouver les répertoires à sauvegarder.
*   `DIR_DB_BACKUP` : Le ré

pertoire où les sauvegardes des bases de données seront stockées peut être modifié en modifiant cette variable.
*   `DIR_WP` : Définit le répertoire que le script analyse pour trouver vos installations WordPress.
*   `LOG_FILE` : Le format du nom des fichiers de journal peut être personnalisé en modifiant cette variable.
*   `LOG_DAYS_TO_KEEP` : La durée pendant laquelle les fichiers de journal seront conservés peut être spécifiée en modifiant cette variable.
*   `DUMP_DAYS` : La durée pendant laquelle un fichier de sauvegarde sera conservé dans le dossier `DIR_DB_BACKUP` peut être définie en modifiant cette variable.

Prochaines étapes<a name="next-steps"></a>
---------------------------------

En regardant vers l'avenir, j'ai quelques fonctionnalités que j'aimerais ajouter au script pour le rendre encore plus utile. Voici quelques points sur lesquels je prévois de travailler :

* Mise à jour du script et de ses composants : J'ajouterai une option pour mettre à jour le script et toutes ses dépendances afin que vous disposiez toujours des dernières fonctionnalités et corrections de bugs.
* Modification automatique de la tâche cron lors de l'installation : J'automatiserai le processus d'installation en configurant automatiquement la tâche cron pour vous.
* Ajout de vérifications de sécurité supplémentaires : J'ajouterai des vérifications supplémentaires pour m'assurer que le script s'exécute correctement et en toute sécurité.
* Ajout d'une option de vérification et de réparation du script : J'inclurai une option pour vérifier l'installation actuelle et corriger les problèmes éventuels de manière plus propre si nécessaire.
* Fourniture d'une documentation sur la façon de restaurer des fichiers à partir de la sauvegarde Restic : Je créerai un guide pour vous aider à restaurer vos fichiers en cas de perte de données.
* Ajout du support automatique de la commande restic unlock --cleanup-cache en cas de problème avec un instantané verrouillé

Je suis ravi de travailler sur ces fonctionnalités et d'améliorer le script. Comme toujours, si vous avez des commentaires ou des suggestions, n'hésitez pas à les partager !
