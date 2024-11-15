#!/bin/bash

chmod +x /usr/local/bin/pwsh
pwsh -c '$PSVersionTable'

PWSH_DIR=$(dirname $(which pwsh))

# Install and configure Oh My Posh
pwsh -c '
# Get pwsh directory from bash variable
$PWSH_DIR = $env:PWSH_DIR

curl -L https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -o $PWSH_DIR/oh-my-posh
chmod +x $PWSH_DIR/oh-my-posh

if (!(Test-Path -Path $PROFILE )) {
    New-Item -ItemType File -Path $PROFILE -Force
}

echo "$PWSH_DIR/oh-my-posh init pwsh | Invoke-Expression" >> $PROFILE

# https://ohmyposh.dev/docs/themes/
$themeName = "patriksvensson"

mkdir -p $HOME/.poshthemes
curl -L https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -o $HOME/.poshthemes/themes.zip
Expand-Archive -Path $HOME/.poshthemes/themes.zip -DestinationPath $HOME/.poshthemes
Remove-Item $HOME/.poshthemes/themes.zip
echo "$PWSH_DIR/oh-my-posh init pwsh --config $HOME/.poshthemes/${themeName}.omp.json | Invoke-Expression" >> $PROFILE

Write-Host "Oh My Posh has been installed and configured."
Write-Host "To apply changes to the current session, run the following command:"
Write-Host ". `$PROFILE"
'