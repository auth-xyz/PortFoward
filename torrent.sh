#!/usr/bin/env bash

# Function to check if qbittorrent is installed and install if not
install_qbittorrent() {
    if command -v qbittorrent &> /dev/null; then
        return 0  # qbittorrent is already installed
    fi
    
    echo "Error: qbittorrent is not installed."
    
    # Check if qbittorrent is available on flatpak
    if command -v flatpak &> /dev/null; then
        echo "Do you want to install qBittorrent via Flatpak? (y/n)"
        read choice
        if [ "$choice" == "y" ]; then
            flatpak install flathub org.qbittorrent.qBittorrent
            return $?
        fi
    fi
    
    # Check if qbittorrent is available on the package manager
    if command -v sudo &> /dev/null; then
        echo "Do you want to install qBittorrent via your package manager? (y/n)"
        read choice
        if [ "$choice" == "y" ]; then
            sudo dnf install -y qbittorrent  # Change this line as needed for your package manager
            return $?
        fi
    fi
    
    echo "Error: Could not find a suitable method to install qbittorrent."
    return 1
}

# Function to get the qBittorrent command for changing torrenting port
get_qbittorrent_command() {
    if command -v flatpak &> /dev/null && flatpak list | grep -q org.qbittorrent.qBittorrent; then
        echo "flatpak run org.qbittorrent.qBittorrent --torrenting-port="
    elif command -v qbittorrent &> /dev/null; then
        echo "qbittorrent --torrenting-port="
    else
        echo "Error: qBittorrent is not installed."
        return 1
    fi
}

# Check and install qbittorrent
install_qbittorrent || exit 1

previous_mapped_port=""

while true ; do
    date
    gateway=$(natpmpc | sed -n 2p | awk '{print $4}')
    mapping_info=$(natpmpc -a 1 0 tcp 60 -g $gateway)

    if [[ $mapping_info =~ Mapped\ public\ port\ ([0-9]+) ]]; then
        mapped_port="${BASH_REMATCH[1]}"
        echo "Mapped public port: $mapped_port"
        notify-send "Port Fowarding" "Mapped public port: $mapped_port"

        # Check if the mapped port has changed
        if [[ "$mapped_port" != "$previous_mapped_port" ]]; then
            echo "Changing qBittorrent port to $mapped_port"

            # Get the qBittorrent command
            qbittorrent_command=$(get_qbittorrent_command)
            if [ $? -eq 0 ]; then
                # Change qBittorrent port
                $qbittorrent_command$mapped_port

                # Update the previous mapped port
                previous_mapped_port="$mapped_port"
            else
                echo "Error: Unable to determine qBittorrent command."
            fi
        else
            echo "Mapped port has not changed. Skipping qBittorrent port update."
        fi
    else
        echo "ERROR: Failed to extract Mapped public port from natpmpc output"
    fi

    sleep 45
done

