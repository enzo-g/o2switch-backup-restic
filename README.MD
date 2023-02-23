# O2Switch Backup with Restic

Script Description
------------------

This Bash shell script has been written with the goal of backing up your website's data and MySQL databases on the infrastructure provided by [O2Switch](https://www.o2switch.fr/), as well as transferring them to a remote cloud service of your choice.

The script can automatically detect WordPress installations located in directories at the root of your installation and dump their databases for backup. It uses Restic and Rclone to backup your data in a secure manner on a remote location. Restic is a powerful and easy-to-use backup tool that features strong encryption, efficient deduplication, and compression to help you securely backup and restore your data. Rclone is a versatile and reliable command-line tool that allows you to sync and transfer files between multiple cloud storage providers and other types of storage systems.

The decision to use this script to backup your data with O2Switch's infrastructure is based on their recommendation for users to maintain their own backups in addition to their [Jetbackup](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup) solution for restoring backups. This script is designed to follow their recommendation and provide you with a secure and efficient backup solution.

Disclaimer
------------------
* I'm not affiliated with [O2Switch](https://www.o2switch.fr/)
* This script is provided as-is and without any warranty. The author is not responsible for any problems that may arise from the use of this script, including but not limited to data loss, system crashes, or other issues. While this script is intended for backing up data, please note that backups can fail for a variety of reasons, and it is important to backup your data before running the script. Use at your own risk and make sure to backup your data before running the script.
* If you are uncertain about how to use this script or encounter any issues during its execution, O2Switch offers Jetbackup as a backup solution. For more information on how to use Jetbackup, please visit their [FAQ page](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup)




# How-To - Short version

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

# HOW-TO - Long version

Prerequesite
---------------------

* Some experiences with Restic or Rclone before using the script would be appropriate.
  * Documentation about Restic: (https://restic.readthedocs.io/en/latest/010_introduction.html)
  * Documentation to use Rclone with Restic: (https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html?highlight=rclone#other-services-via-rclone)

* Restic can backup without Rclone on multiple cloud services (Rest Server, Amazon S3, Minio, Azure...). But also locally or with SFTP.
  * If you are planning to use SFTP, you need to declare your remote server IP in Cpanel interface to unlock the traffic.
    * Official O2switch documentation: (https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/whitelist-firewall)
      * Outils > Autorisation SSH, and declare you remote server IP on port 22
  * OneDrive services seems to be whitelisted by O2switch and can be use by default with Rclone.

* You should have request your shell access for your web-hosting (https://faq.o2switch.fr/hebergement-mutualise/acces-ssh-shell-cli-cmdline)

Step by step Installation and configuration
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
### Step 2 - Prepare a remote repository to welcome your files.

#### Example with SFTP

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
$ $HOME/scripts/backup/./restic -r "sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic" init
$ # As long as user_remote has enougth permissions, the directory will be automatically created: /home/user_remoteserver/restic
$ # You will be requested to "enter password for new repository:" You will need that password later, don't lose it.
```
### Step 3 - Edit the configuration files

Now let's edit the configuration files.

* backup-restic-conf.txt: Edit that file with the content of the command used to init your restic repository.
  `"sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic"`
  Within that file you can also edit the path of the file that will contain your restic repo password. I don't recommend to edit it.
* backup-restic-pwd.txt: Insert within that file, the password you have selected.
* backup-db-others.txt: Edit that file if you want to add specific databases to backup that are not related to a wordpress installation.
  You will need to create an user and to grant him the following permission for those DBs only: `SELECT / LOCK TABLES / SHOW VIEW`
  Documentation from O2Switch: Base de données MySQL(https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/base-donnees-mysql)
* backup-excluded-dirs.txt: Edit that file to add folders to not backup, check the content some folders are excluded by default.
  You can use the command  `ls -dA .*/ | grep -Ev '^(\./|\.\./)$'` to obtain the list of all hidden folder at the root of your home directory.
  Most of those directories can be excluded from backup. I recommend you to add them within the file.

### Step 4 - Set a cron

You want that script to be automatically executed, for that we use crontab. 
You can do that from cpanel or from command line. (https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/taches-cron)
```shell
$ EDITOR=nano crontab -e
$ # Add the following line to launch a backup everyday at midnigh:
$ 0 0 * * * $HOME/scripts/backup/backup.sh --backup
$ # Ctrl + o to save your change and Ctrl + x to quit nano
```
### Step 5 - Test our installation / launch our first backup

You are probably impatient at this point to test if the backup is working correctly.
You can execute that command to launch your first backup: `$HOME/scripts/backup/backup.sh --backup`

# More details

Script arguments
---------------------

The script can be used with two options: `--backup` and `--install`.

The `--backup` option is used to backup the MySQL databases of WordPress installations and other databases not related to WordPress, as well as specified directories. To use this option, run the script with the following command:

The `--install` option is used to install the bacup script, downlaod the latest version of Restic and prepare the environment for running the backup.
If while running "./backup.sh --backup" a file was missing, the --install option can be used to recreate the missing file. 

To use this option, run the script with the following command:

shell

```shell
$ ./backup.sh --install
```

Script Configuration
--------------------

The script can be configured using the following variables.
By default, you should have no need to edit them.

*   `ROOT_DIR`: Defines the root directory to scan for directory to backup.
*   `RESTIC_SCRIPT`: Defines the path to the script backup directory.
*   `DB_BACKUP_DIR`: Defines the directory to store database backups.
*   `RESTIC_BIN`: Defines the path to the Restic binary.
*   `RESTIC_CONF`: Defines the path of the Restic configuration file.
*   `restic_password_file`: Sets the path to the Restic password file.
*   `OTHER_DBS_FILE`: Defines the file containing other databases to backup and usernames.
*   `EXCLUDED_DIRS_FILE`: Defines the file containing the directories to exclude.

The following files are carrying also important part of the configuration:

* backup-restic-conf.txt: restic command to backup on your selected repository
* backup-restic-pwd.txt: Password of your restic repository
* backup-db-others.txt: Other MySQL DB to back-up aside of the automatic backup of wordpress DB
* backup-excluded-dirs.txt: Edit that file to add folders to not backup, check the content some folders are excluded by default.
  You can use the command  `ls -dA .*/ | grep -Ev '^(\./|\.\./)$'` to obtain the list of all hidden folder at the root of your home directory.
  Most of those directories can be excluded from backup. I recommend you to add them within the file.

# Next steps

I would like to implement the following feature within that script:
* Add an option to update the script and its components
* Automaticat edition of cron at the installation
* Add more safety check within the script
* Add an option to check the script current installation and fix it in a cleaner way if necessary
* Provide documentation on how to restore files from the restic backup, even if that documentation can befind on restic official website.


# Acknowledgments

I would like to thanks [Restic](https://github.com/restic/restic) and [Rclone](https://rclone.org/) for their astonishing softwares.
I would like to express my gratitude to [Uprising](https://github.com/uprisingweb/o2switch-backup-all.sh). 
I got the idea of this current script when I was looking for an existing solution and found his script. I find his wordpress database backup solution especially elegant!

License
----------

[BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause)
