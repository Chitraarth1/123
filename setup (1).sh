#!/bin/bash

# Step 1: Clean up duplicate entries in /etc/apt/sources.list
echo "Cleaning up duplicate entries in /etc/apt/sources.list and related files..."
sudo rm -f /etc/apt/sources.list.d/debian.sources
sudo rm -f /etc/apt/sources.list
sudo bash -c 'echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free" > /etc/apt/sources.list'
sudo bash -c 'echo "deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free" >> /etc/apt/sources.list'
sudo bash -c 'echo "deb http://deb.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list'

# Step 2: Update the package list and fix any broken installations
echo "Updating system package list..."
sudo apt clean
sudo apt update --fix-missing
sudo apt upgrade -y

# Step 3: Install XFCE Desktop Environment
echo "Installing XFCE Desktop Environment..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y xfce4 desktop-base dbus-x11 xscreensaver

# Step 4: Re-download and install Chrome Remote Desktop
echo "Re-downloading and installing Chrome Remote Desktop..."
wget -O chrome-remote-desktop_current_amd64.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg -i chrome-remote-desktop_current_amd64.deb

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo "Error: Chrome Remote Desktop installation failed. Attempting to fix missing dependencies..."
    sudo apt --fix-broken install -y
    sudo dpkg -i chrome-remote-desktop_current_amd64.deb
    if [ $? -ne 0 ]; then
        echo "Error: Chrome Remote Desktop installation failed after retry."
        exit 1
    fi
fi

# Step 5: Configure Chrome Remote Desktop to use XFCE4 session
echo "Configuring Chrome Remote Desktop to use XFCE4..."
sudo bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

# Step 6: Stop LightDM service
echo "Stopping LightDM service..."
sudo service lightdm stop

# Step 7: Final step: Ask for Chrome Remote Desktop Setup code from the user
echo "Please provide the Chrome Remote Desktop Setup Code (copy and paste the following command):"
read -p "Enter Chrome Remote Desktop authorization code: " AUTH_CODE

# Step 8: Run the Chrome Remote Desktop host setup
DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="$AUTH_CODE" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name=$(hostname)

if [ $? -ne 0 ]; then
    echo "Error: Failed to start Chrome Remote Desktop host."
    exit 1
fi

echo "Setup complete! Chrome Remote Desktop is now configured."
