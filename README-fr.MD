# Sauvegarde O2Switch avec Restic

## Description du script<a name="description-du-script"></a>

Ce script shell Bash a été conçu pour sauvegarder les données de votre site web et les bases de données MySQL de l'infrastructure [O2Switch](https://www.o2switch.fr/) vers un service cloud distant de votre choix.

Si vous n'hébergez que des sites web WordPress sur O2Switch, vous n'aurez peut-être besoin que de modifier les fichiers `backup-restic-conf.txt` et `backup-restic-pwd.txt`, car le comportement par défaut du script sera suffisant pour sauvegarder toutes vos installations WordPress.

Le script peut détecter automatiquement les installations WordPress situées dans les répertoires à la racine de votre installation et sauvegarder leurs bases de données. Il utilise Restic et Rclone pour sauvegarder vos données de manière sécurisée sur un emplacement distant. Restic est un outil de sauvegarde puissant et facile à utiliser qui offre un chiffrement fort, une déduplication efficace et une compression pour vous aider à sauvegarder et restaurer vos données en toute sécurité. Rclone est un outil polyvalent et fiable en ligne de commande qui vous permet de synchroniser et de transférer des fichiers entre plusieurs fournisseurs de stockage cloud et d'autres types de systèmes de stockage.

La décision d'utiliser ce script pour sauvegarder vos données avec l'infrastructure d'O2Switch est basée sur leur recommandation aux utilisateurs de maintenir leurs propres sauvegardes en plus de leur solution [Jetbackup](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup) pour la restauration de sauvegardes. Ce script est conçu pour suivre leur recommandation et vous fournir une solution de sauvegarde sécurisée et efficace.

# Table des matières

- [Description du script](#description-du-script)
- [Clause de non-responsabilité](#clause-de-non-responsabilite)
- [Comment faire : explication rapide](#comment-faire-explication-rapide)
- [Comment faire : explication détaillée](#comment-faire-explication-detaillee)
  - [Prérequis](#prerequis)
  - [Installation et configuration étape par étape](#installation-et-configuration-etape-par-etape)
- [Plus de détails](#plus-de-details)
  - [Arguments du script](#arguments-du-script)
  - [Configuration du script](#configuration-du-script)
- [Étapes suivantes](#etapes-suivantes)
- [Remerciements](#remerciements)
- [Licence](#licence)


Clause de non-responsabilité<a name="disclaimer"></a>
------------------
* Je ne suis pas affilié à [O2Switch](https://www.o2switch.fr/)
* Ce script est fourni tel quel et sans garantie. L'auteur n'est pas responsable des problèmes qui peuvent survenir lors de l'utilisation de ce script, notamment la perte de données, les plantages système ou autres problèmes. Bien que ce script soit destiné à sauvegarder des données, veuillez noter que les sauvegardes peuvent échouer pour diverses raisons, et il est important de sauvegarder vos données avant d'exécuter le script. Utilisez-le à vos propres risques et assurez-vous de sauvegarder vos données avant d'exécuter le script.
* Si vous n'êtes pas certain de la façon d'utiliser ce script ou si vous rencontrez des problèmes lors de son exécution, O2Switch propose Jetbackup comme solution de sauvegarde. Pour plus d'informations sur l'utilisation de Jetbackup, veuillez consulter leur [page FAQ](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup).

# How-To: Quick Explanation<a name="how-to-quick-explanation"></a>

That short how-to is for those confortable with Restic and O2Swtich capabilities and restrictions.
By default, the script will backup all of your files except the one within hidden folder at the root of your webserver.
All wordpress databases will be backup automatically too.
You will have to follow those steps:
* Install the script. Upload it to the root directory of your webserver and then execute 
```shell
$ ./backup.sh --install
```
* The only mandatory files to edit are the following one in that directory $HOME/scripts/backup
  * backup-restic-conf.txt: Input the path to your restic repository
  * backup-restic-pwd.txt: Input the password of your restic repository
* You can now execute from the directory $HOME/scripts/backup:
```shell
$ ./backup.sh --backup
```

# How-to: Explication détaillé<a name="how-to-detailed-explanation"></a>

Prérequis<a name="prerequisite"></a>
---------------------
* Avant de commencer avec le script, il est recommandé d'avoir de l'expérience avec Restic ou Rclone. Si vous n'êtes pas familier avec ces outils, ne vous inquiétez pas - j'ai inclus des liens vers la documentation qui peuvent vous aider à vous mettre à niveau. La configuration étape par étape couvre également les bases.
  * Documentation sur Restic : (https://restic.readthedocs.io/en/latest/010_introduction.html)
  * Documentation sur l'utilisation de Rclone avec Restic : (https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html?highlight=rclone#other-services-via-rclone)

* Restic peut sauvegarder vers plusieurs services cloud, tels que Rest Server, Amazon S3, Minio et Azure, ainsi qu'en local ou avec SFTP.
  * Si vous prévoyez d'utiliser SFTP, vous devrez déclarer votre adresse IP de serveur distant dans l'interface Cpanel pour débloquer le trafic. Nous avons inclus un lien vers la documentation officielle d'O2switch qui explique comment faire.
    * Documentation officielle d'O2switch : (https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/whitelist-firewall)
    * Cpanel > Outils > Autorisation SSH, et déclarez votre adresse IP de serveur distant sur le port 22
  * Notez que les services OneDrive sont autorisés par défaut chez O2switch et peuvent être utilisés avec Rclone.

* Enfin, il est important d'avoir un accès shell à votre hébergement web. Si vous n'avez pas déjà demandé cela, j'ai inclus un lien vers la documentation d'O2switch qui explique comment le faire. (https://faq.o2switch.fr/hebergement-mutualise/acces-ssh-shell-cli-cmdline)

J'espère que cela vous aidera à vous préparer à utiliser le script. Si vous avez des questions ou des problèmes, n'hésitez pas à me contacter - je suis là pour vous aider !

Step by step Installation and configuration<a name="step-by-step-installation-and-configuration"></a>
---------------------

### Step 1 - Upload the script and install it.

```shell
  $ # Copy the script backup.sh to your root directory "/home2/username/" either from your cpanel 
  $ # or by using 'nano' to create a new file and copy-paste the content of backup.sh to your file.
  $ nano backup.sh
  $ # Paste the content in it, and save it with Ctrl+O and close the file with Ctrl+X
  $ chmod +x backup.sh
  $ # Allow you to execute the script
  $ backup.sh --install
  $ # This command create all folders and file needed and copy the backup script within the folder scripts/backup
  $ rm backup.sh"sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic"
  $ # delete the backup.sh file from the root directory
```
### Step 2 - Edit 'backup-restic-pwd.txt'

Edit the file called `backup-restic-pwd.txt` and save the password inside that you want to use for your restic backup. 
Remember, this password is essential for several Restic tasks, so let's keep a copy of it safe outside of O2switch. Though I don't anticipate any issues, we need to understand how crucial this password is in case of a massive O2switch infrastructure crash. Without it, you won't be able to access any of your Restic backups. So let's take a moment to ensure this password is well-protected and safely backed up!

### Step 3 - Prepare a remote repository to welcome your files.

In any case, first execute the following command in your shell: `export PATH=$PATH:/home2/ufza5835/scripts/backup`
This command is allowing you to use the time of your session the executable "restic" and  "rclone" without typing their full path. (ex: $HOME/scripts/backup/./restic)

#### 3.1 Example with SFTP

Make sure to whitelist the traffic toward your remote server (https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/whitelist-firewall)
You should have a credential to login on your remote server.
Below the command to repare an SSH key on O2switch server and to copy it to your remote server.
This will allow your script to connect without password to your remote server.

```shell
  $ ssh-keygen
  $ # Set all to default with no password
  $ ssh-copy-id -i ~/.ssh/id_rsa.pub user_remoteserver@host_remoteserver.com
  $ # You will be request for your password for the remote server.
  $ # After that the ssh key will be copy to the remote server and password will not be necessary anymore.
```
It's time to prepare your restic repository

```shell
$ restic -r "sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic" init -p $HOME/scripts/backup/backup-restic-pwd.txt
$ # As long as user_remote has enougth permissions, the directory will be automatically created: /home/user_remoteserver/restic
$ # You don't need to type your restic password because its loaded from the file backup-restic-pwd.txt
```
#### 3.2 Example with rclone

If you choose to use the sftp option, you do not need to follow the instructions provided in the rclone example. While creating that guide, I found that Mega has been integrated with rclone in a very useful way. Therefore, you should take the time to create a Mega account, which will give you access to 50GB of free storage. After creating the account, you can run the following command:

```shell
$ rclone config create mymega mega user user@example.com pass Your-Password
  [mymega]
  type = mega
  user = user@example.com
  pass = *** ENCRYPTED ***
```
To verify that your rclone configuration is accurate, we will create a file called "demo.txt" and confirm its existence. You can also check this simultaneously using your web browser.

```shell
#Create a file
$ rclone touch mymega:demo.txt
#Check for the file
$ rclone ls mymega:
  0 demo.txt
```

It's time to prepare your restic repository

```shell
$ restic -r "rclone:mymega:restic" init -p $HOME/scripts/backup/backup-restic-pwd.txt
$ # As long as user_remote has enougth permissions, the directory will be automatically created: /restic
$ # You don't need to type your restic password because its loaded from the file backup-restic-pwd.txt
```

### Step 4 - Edit the configuration files

Now let's edit the configuration files.

* `backup-restic-conf.txt`: If you want to keep the default script behavior, only edit 'restic_repo'and 'restic_receive_email'
  * `restic_repo=` Should be similar to the command you wrote previously to init your restic repo. 
    * Example with sftp: sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic
    * Excample with rclone: rclone:mymega:restic
  * `restic_receive_email` Define the email address that will receive the logs.
  * `restic_log_file` Edit that value if you want to give a specific name to your log's file.
  * `restic_log_days` Define how many days to keep the log's files.
  * `restic_dump_days` Define how many days to keep the MySQL dumps.
* `backup-db-others.txt`: Edit that file if you want to add specific databases not related to a wordpress installation and that you want to backup.
  * You will need to create an user and to grant him the following permission for those DBs only: `SELECT / LOCK TABLES / SHOW VIEW`
  * Documentation from O2Switch: [Base de données MySQL](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/base-donnees-mysql)
* `backup-excluded-dirs.txt`: Edit that file to add folders to not backup, check the content some folders are excluded by default.
  * You can use the command  `ls -dA .*/ | grep -Ev '^(\./|\.\./)$'` to obtain the list of all hidden folder at the root of your home directory.
    Most of those directories can be excluded from backup. I recommend you to add them within the file.

### Step 5 - Set a cron

You want that script to be automatically executed, for that we use crontab. 
You can do that from [O2switch cpanel](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/taches-cron) or from command line. 
```shell
$ EDITOR=nano crontab -e
$ # Add the following line to launch a backup everyday at midnigh:
$ 0 0 * * * $HOME/scripts/backup/backup.sh --backup
$ # Ctrl + o to save your change and Ctrl + x to quit nano
```

### Step 6 - Test our installation / launch our first backup

You are probably impatient at this point to test if your backup is going to work properly.
You can execute that command to launch your first backup: `$HOME/scripts/backup/backup.sh --backup`

# More details<a name="more-details"></a>

Script arguments<a name="script-arguments"></a>
---------------------

The script can be used with two options: `--backup` and `--install`.

The `--backup` option is used to backup the MySQL databases of WordPress installations and other databases not related to WordPress, as well as specified directories. To use this option, run the script with the following command:

The `--install` option is used to install the bacup script, downlaod the latest version of Restic and prepare the environment for running the backup.
If while running "./backup.sh --backup" a file was missing, the --install option can be used to recreate the missing file. 

Script Configuration<a name="script-configuration"></a>
--------------------

Before diving into customizing the script behavior, it's worth noting that if you're only hosting WordPress websites on O2switch, you'll only need to edit `backup-restic-conf.txt` and `backup-restic-pwd.txt`. The default behavior of the script should be sufficient for backing up all of your WordPress installations.

That being said, if you do need to customize the script, you can modify the following files:

* `backup-restic-conf.txt`: This file contains the restic command that is used to backup your selected repository.
* `backup-restic-pwd.txt`: Here you have to enter the password for your restic repository.
* `backup-db-others.txt`: In case you need to backup other MySQL databases besides the automatic backup of the WordPress database, you can add them to this file.
* `backup-excluded-dirs.txt`: If you want to exclude certain folders from the backup, you can add them to this file. 
   Some folders are already excluded by default. You can use at the root of your home directory, the command: `ls -dA .*/ | grep -Ev '^(\./|\.\./)$'` to obtain a list of all hidden folders at the root of your home directory. Most of these directories can be excluded from backup, and I recommend adding them to this file.

The following variables within the script `backup.sh` can be edited to change the script behavior. But I recommend keeping the default value.

*   `DIR_ROOT`: This variable specifies the root directory that the script will scan to find directories that need to be backed up.
*   `DIR_DB_BACKUP`: The directory where the databases dump will be stored can be changed by modifying this variable.
*   `DIR_WP`: Defines the directory that the script scant to find your wordpress installations
*   `LOG_FILE`: The name format of the log files can be customized by editing this variable.
*   `LOG_DAYS_TO_KEEP`: The amount of time that log files will be retained can be specified by changing this variable.
*   `DUMP_DAYS`: The length of time that a dump file will be retained in the `DIR_DB_BACKUP` folder can be set by modifying this variable.

# Next steps<a name="next-steps"></a>

Looking ahead, I have a few features I'd like to add to the script to make it even more useful. Here are some things I'm planning to work on:

* Adding support for PostgreSQL: I think it would be interesting to have that feature too.
* Updating the script and its components: I'll add an option to update the script and any dependencies, so you always have the latest features and bug fixes.
* Automatic editing of cron at installation: I'll streamline the installation process by automatically configuring the cron job for you.
* Adding more safety checks: I'll build in additional checks to ensure that the script is running smoothly and safely.
* Adding a script check and repair option: I'll include an option to check the current installation and fix any issues in a cleaner way if needed.
* Providing documentation on how to restore files from the restic backup: I'll create a guide to help you restore your files in case you ever need to recover from a data loss.

I'm excited to work on these features and make the script even better. As always, if you have any feedback or suggestions, I'm happy to hear them!

# Acknowledgments<a name="acknowledgments"></a>

* [Restic](https://github.com/restic/restic) for their marverlous software.
* [Rclone](https://rclone.org/) for their astonishing softwares.
* [Uprising](https://github.com/uprisingweb/o2switch-backup-all.sh). I got the idea of this current script when I was looking for an existing solution and found his script. I find his wordpress database backup solution especially elegant!

License<a name="license"></a>
----------

[BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause)
