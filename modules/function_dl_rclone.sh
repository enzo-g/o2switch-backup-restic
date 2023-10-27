function install_rclone {
  # Get the latest Restic release from GitHub
  LATEST_RCLONE=$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | grep -E '.*"browser_download_url":.*linux-amd64.zip"' | cut -d '"' -f 4)

  # Download the latest Restic release
  echo "Downloading latest release of Rclone..."
  curl -L -o $DIR_SCRIPT_BACKUP/rclone.zip $LATEST_RCLONE
  unzip -j $DIR_SCRIPT_BACKUP/rclone.zip "*rclone" -d $DIR_SCRIPT_BACKUP
  chmod +x $DIR_SCRIPT_BACKUP/rclone
  rm $DIR_SCRIPT_BACKUP/rclone.zip
  echo "Latest release of Rclone downloaded"
}