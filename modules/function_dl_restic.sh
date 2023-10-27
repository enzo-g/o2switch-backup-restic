function install_restic {
  # Check if restic already exists
  if [ -f "$RESTIC_BIN" ]; then
    echo "Existing restic binary found."
    CURRENT_VERSION=$($RESTIC_BIN version | grep -E '^restic [0-9]+\.[0-9]+\.[0-9]+' | cut -d ' ' -f 2)
    echo "Current version of restic: $CURRENT_VERSION"
  else
    echo "No existing restic binary found."
  fi

  # Get the latest Restic release from GitHub
  LATEST_RESTIC=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep -e "browser_download_url.*linux_amd64" | cut -d '"' -f 4)

  # Download the latest Restic release
  echo "Downloading latest release of Restic..."
  if curl -L -o $DIR_SCRIPT_BINARIES/restic.bz2 $LATEST_RESTIC; then
    bunzip2 -f $DIR_SCRIPT_BINARIES/restic.bz2
    chmod +x $RESTIC_BIN

    NEW_VERSION=$($RESTIC_BIN version | grep -E '^restic [0-9]+\.[0-9]+\.[0-9]+' | cut -d ' ' -f 2)
    echo "Latest release of Restic downloaded: $NEW_VERSION"
  else
    echo "Failed to download Restic. Exiting."
    exit 1
  fi
}