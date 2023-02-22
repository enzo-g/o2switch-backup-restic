# O2Switch Backup with Restic

Disclaimer
------------------
I'm not affiliated with [O2Switch](https://www.o2switch.fr/)

Script Description
------------------

The script is a Bash shell script that can be used to backup MySQL databases of WordPress installations and other databases not related to WordPress. 
It can also backup specified directories using the Restic backup tool and prune the backups according to the specified retention policy. 
Additionally, the script can be used to prepare the environment for running the backup, by installing restic and create all mandatory files and folders.

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

# HOW-TO - Long version - Instructions incomplete

Prerequesite
---------------------

* A remote server that accept SSH connection with public key.

* This version of the backup script is ready to backup towards an sftp server. So using SSH -port 22.
  * For that you need in your O2Switch Cpanel to go to:
    * Outils > Autorisation SSH, and declare you remote server IP on port 22
  * Then you can prepare an ssh key on O2switch to export to your remote server.
    ```shell
    $ ssh-keygen
    $ ssh-copy-id -i $HOME/.ssh/id_rsa.pub user_remoteserver@host_remoteserver.com
    ```
* How to install the backup script:
```shell
$ ./backup.sh --backup
```

* How to prepare your restic repository:
```shell
$ ./restic -r "sftp:o2backup@srv.demo.com:/home/o2backup/restic" init
```

# More details

Script arguments
---------------------

The script can be used with two options: `--backup` and `--install`.

### `--backup` Option

The `--backup` option is used to backup the MySQL databases of WordPress installations and other databases not related to WordPress, as well as specified directories. To use this option, run the script with the following command:

shell

```shell
$ ./backup.sh --backup
```

### `--install` Option

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
By default, you should not need to edit 

*   `ROOT_DIR`: Defines the root directory to scan for directory to backup.
*   `RESTIC_SCRIPT`: Defines the path to the script backup directory.
*   `DB_BACKUP_DIR`: Defines the directory to store database backups.
*   `RESTIC_BIN`: Defines the path to the Restic binary.
*   `RESTIC_CONF`: Defines the path of the Restic configuration file.
*   `restic_password_file`: Sets the path to the Restic password file.
*   `OTHER_DBS_FILE`: Defines the file containing other databases to backup and usernames.
*   `EXCLUDED_DIRS_FILE`: Defines the file containing the directories to exclude.

Functions
---------

The script contains the following functions:

*   `create_htaccess_file()`: Creates a .htaccess file in the backup directory to prevent web access.
*   `install_restic()`: Downloads and installs the latest Restic release from GitHub.
*   `create_mandatory_dir()`: Creates a mandatory directory if it does not exist.
*   `is_script_in_backup_dir()`: Checks if the script is located in the backup directory.
*   `copy_script_to_backup_dir()`: Copies the script to the backup directory.
*   `create_db_others_file()`: Creates the file for other databases to backup if it does not exist.
*   `create_file_exclude_directory()`: Creates the file containing the directories to exclude if it does not exist.
*   `create_restic_files()`: Creates the Restic configuration file and the Restic password file if they do not exist.
*   `check_required_files()`: Checks if the required files exist.

# Next steps

I would like to implement the following feature within that script:
* Add an option to update the script and its components
* Implementation of rclone
* Automaticat edition of cron at the installation
* Add more safety check within the script
* Add an option to check the script current installation and fix it in a cleaner way if necessary


# Acknowledgments

I would like to express my gratitude to [Uprising](https://github.com/uprisingweb/o2switch-backup-all.sh). I got the idea of this current script by looking an existing solution and found his script. I find the database backup solution especially elegant!

I would also like to thank [Restic](https://github.com/restic/restic) for their backup software.

License
----------

[BSD 2-Clause License](https://opensource.org/licenses/BSD-2-Clause)
