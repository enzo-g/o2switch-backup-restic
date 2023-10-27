function install_rclone {
  # Check if rclone already exists
  if [ -f "$RCLONE_BIN" ]; then
    echo "Existing rclone binary found."
    CURRENT_VERSION=$($RCLONE_BIN version | grep -E '^rclone v[0-9]+\.[0-9]+\.[0-9]+' | cut -d ' ' -f 2)
    echo "Current version of rclone: $CURRENT_VERSION"
  else
    echo "No existing rclone binary found."
  fi

  # Get the latest Rclone release from GitHub
  LATEST_RCLONE=$(curl -s https://api.github.com/repos/rclone/rclone/releases/latest | grep -E '.*"browser_download_url":.*linux-amd64.zip"' | cut -d '"' -f 4)

  # Download the latest Rclone release
  echo "Downloading latest release of Rclone..."
  if curl -L -o $DIR_SCRIPT_BINARIES/rclone.zip $LATEST_RCLONE; then
      unzip -j $DIR_SCRIPT_BINARIES/rclone.zip "*rclone" -d $DIR_SCRIPT_BINARIES
      chmod +x $RCLONE_BIN
      rm $DIR_SCRIPT_BINARIES/rclone.zip
      echo "Latest release of Rclone downloaded"
  else
      echo "Failed to download Rclone. Exiting."
      exit 1
  fi
}