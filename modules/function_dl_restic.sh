function install_restic {
  # Get the latest Restic release from GitHub
  LATEST_RESTIC=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep -e "browser_download_url.*linux_amd64" | cut -d '"' -f 4)

  # Download the latest Restic release
  echo "Downloading latest release of Restic..."
  curl -L -o $DIR_SCRIPT_BACKUP/restic.bz2 $LATEST_RESTIC
  bunzip2 $DIR_SCRIPT_BACKUP/restic.bz2
  chmod +x $DIR_SCRIPT_BACKUP/restic
  echo "Latest release of Restic downloaded"
}