# O2Switch Backup with Restic

## Script Description<a name="script-description"></a>

This Bash shell script is designed to backup your website's data and databases from [O2Switch's infrastructure](https://www.o2switch.fr/) to a remote cloud service of your choice.

The script can automatically detect WordPress installations located in directories at the root of your installation and dump their databases for backup. It uses Restic and Rclone to backup your data in a secure manner on a remote location. Restic is a powerful and easy-to-use backup tool that features strong encryption, efficient deduplication, and compression to help you securely backup and restore your data. Rclone is a versatile and reliable command-line tool that allows you to sync and transfer files between multiple cloud storage providers and other types of storage systems.

The decision to use this script to backup your data with O2Switch's infrastructure is based on their recommendation for users to maintain their own backups in addition to their [Jetbackup](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup) solution for restoring backups. This script is designed to follow their recommendation and provide you with a secure and efficient backup solution.

## Disclaimer<a name="disclaimer"></a>

* I'm not affiliated with [O2Switch](https://www.o2switch.fr/)
* This script is provided as-is and without any warranty. The author is not responsible for any problems that may arise from the use of this script, including but not limited to data loss, system crashes, or other issues. While this script is intended for backing up data, please note that backups can fail for a variety of reasons, and it is important to backup your data before running the script. Use at your own risk and make sure to backup your data before running the script.
* If you are uncertain about how to use this script or encounter any issues during its execution, O2Switch offers Jetbackup as a backup solution. For more information on how to use Jetbackup, please visit their [FAQ page](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/sauvegarde-jetbackup)

## Installation

Clone the repository and set up the script. 

```bash
git clone https://github.com/enzo-g/o2switch-backup-restic.git
cd o2switch-backup-restic
chmod +x backup.sh
./backup.sh --install
```
Once the script has been installed, you will find it in `$HOME/scripts/backup`. From this point forward, you will need to work from that folder. You can remove the entire folder that was created using the `git clone` command previously.

### Step 1 - Edit 'backup-restic-pwd.conf'

Edit the file called `backup-restic-pwd.conf` and save the password inside that you want to use for your restic backup. 
Remember, this password is essential for several Restic tasks, so let's keep a copy of it safe outside of O2switch. Though I don't anticipate any issues, we need to understand how crucial this password is in case of a massive O2switch infrastructure crash. Without it, you won't be able to access any of your Restic backups. So let's take a moment to ensure this password is well-protected and safely backed up!

### Step 2 - Prepare a remote repository to welcome your files.

In any case, first execute the following command in your shell: `export PATH=$PATH:~/scripts/backup`
This command is allowing you to use the time of your session the executable "restic" and  "rclone" without typing their full path. (ex: $HOME/scripts/backup/./restic)
You will etiher haev to follow the instructions given as example in step 2.1 or 2.2 not both !

#### 2.1 Example with SFTP

Make sure to whitelist the traffic toward your remote server: [Whitelist Firewall](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/whitelist-firewall)
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
$ restic -r "sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic" init -p $HOME/scripts/backup/backup-restic-pwd.conf
$ # As long as user_remote has enougth permissions, the directory will be automatically created: /home/user_remoteserver/restic
$ # You don't need to type your restic password because its loaded from the file backup-restic-pwd.conf
```
#### 2.2 Example with rclone

If you choose to use the sftp option, you do not need to follow the instructions provided in the rclone example. While creating that guide, I found that Mega has been integrated with rclone in a very useful way. Therefore, you should take the time to create a Mega account, which will give you access to 50GB of free storage. After creating the account, you can run the following command:

```shell
$ rclone config create mymega mega user user@example.com pass Your-Password
  [mymega]
  type = mega
  user = user@example.com
  pass = *** ENCRYPTED ***
```
To verify that your rclone configuration is accurate, we will create a file called "demo.conf" and confirm its existence. You can also check this simultaneously using your web browser.

```shell
#Create a file
$ rclone touch mymega:demo.conf
#Check for the file
$ rclone ls mymega:
  0 demo.conf
```

It's time to prepare your restic repository

```shell
$ restic -r "rclone:mymega:restic" init -p $HOME/scripts/backup/backup-restic-pwd.conf
$ # As long as user_remote has enougth permissions, the directory will be automatically created: /restic
$ # You don't need to type your restic password because its loaded from the file backup-restic-pwd.conf
```
### Step 3 - Edit the configuration files

Now let's edit the configuration files. Theya re located within: $HOME/scripts/backup/configs

* `backup-restic-conf.conf`: If you want to keep the default script behavior, only edit 'restic_repo'and 'restic_receive_email'
  * `restic_repo=` Should be similar to the command you wrote previously to init your restic repo. 
    * Example with sftp: sftp:user_remoteserver@host_remoteserver.com:/home/user_remoteserver/restic
    * Excample with rclone: rclone:mymega:restic
  * `restic_receive_email` Define the email address that will receive the logs.
  * `restic_log_file` Edit that value if you want to give a specific name to your log's file.
  * `restic_log_days` Define how many days to keep the log's files.
  * `restic_dump_days` Define how many days to keep the MySQL dumps.
  * `restic_wp_backup_enable` Enable or Disable automatic backup of all WordPress databases. Set to true to enable, false to disable.

* `backup-db-others.conf`: Edit that file if you want to add specific databases not related to a wordpress installation and that you want to backup.
  * You will need to create an user and to grant him the following permission for those DBs only: `SELECT / LOCK TABLES / SHOW VIEW`
  * Documentation from O2Switch: [Base de données MySQL](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/base-donnees-mysql)
* `backup-pgdb-others.conf`: Edit that file if you want to add postregresql databases.
* `backup-excluded-dirs.conf`: Edit this file to add folders that should not be backed up. Check the content; some folders are excluded by default.
  * To obtain a list of all hidden folders at the root of your home directory, you can use the command `ls -dA .*/ | grep -Ev '^(\./|\.\./)$'`. Most of these directories can be excluded from the backup. I recommend adding the folders returned by this command to the `backup-excluded-dirs.conf` file.

### Step 4 - Set a cron

You want that script to be automatically executed, for that we use crontab. 
You can do that from [O2switch cpanel](https://faq.o2switch.fr/hebergement-mutualise/tutoriels-cpanel/taches-cron) or from command line. 
```shell
$ EDITOR=nano crontab -e
$ # Add the following line to launch a backup everyday at midnigh:
$ 0 0 * * * $HOME/scripts/backup/backup.sh --backup
$ # Ctrl + o to save your change and Ctrl + x to quit nano
```
### Step 5 - Test our installation / launch our first backup

You are probably impatient at this point to test if your backup is going to work properly.
You can execute that command to launch your first backup: `$HOME/scripts/backup/backup.sh --backup`

## Restoration Feature

The restoration part of the script provides an interactive menu to help users restore their backups. Here is a step-by-step guide on how to use this feature: `$HOME/scripts/backup/backup.sh --restore`

### Interactive Menu Options

Once the script is running, you'll be presented with an interactive menu that offers the following options:

1. **View Snapshots**: This option lists all available snapshots in your Restic repository. Note the snapshot ID of the snapshot you want to work with.
2. **List Files in a Snapshot**: Here, you can enter a snapshot ID and an optional directory path to list files within a specific snapshot.
3. **Restore from a Snapshot**: This option allows you to restore data from a selected snapshot. You'll be prompted to enter the snapshot ID (or type 'latest' for the most recent snapshot) and the directory path to restore. The script will create a temporary directory in `/tmp` for the restoration and log the progress in a `restore.json` file.
   - If you choose to restore a database backup located in `$HOME/backup-db`, the script will include this in the restoration process.
4. **Monitor Ongoing Restoration**: This option lets you monitor the status of an ongoing restoration process. It shows the restoration progress as a percentage completed and indicates the target directory of the restoration.
5. **Stop an Ongoing Restoration**: Use this option to stop an ongoing restoration process. The script will ask for confirmation before terminating the restoration process.

### Important Notes

- Make sure the Restic configuration file is correctly set up before attempting a restoration.
- Be cautious when using the option to stop an ongoing restoration, as it will terminate the process immediately.
- Keep an eye on the `restore.json` log file for detailed information about the restoration process.

### Troubleshooting

- If you encounter issues, verify that the Restic configuration file exists and contains the correct settings.
- For problems with specific snapshots, check their integrity and availability in the Restic repository.

## HELP

Before asking for help, make sure to check the documentation for Restic and Rclone. These resources will be very helpful for you to understand the script:
- Restic Documentation: [https://restic.readthedocs.io/en/latest/](https://restic.readthedocs.io/en/latest/)
- Rclone Documentation: [https://rclone.org/docs/](https://rclone.org/docs/)