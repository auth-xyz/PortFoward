#!/usr/bin/env bash

# Check if qbittorrent-nox is installed
if ! command -v qbittorrent &> /dev/null; then
    echo "Error: qbittorrent is not installed. Installing..."
    sudo dnf install -y qbittorrent
    exit 1
fi

previous_mapped_port=""

while true ; do
    date
    gateway=$(natpmpc | sed -n 2p | awk '{print $4}')
    mapping_info=$(natpmpc -a 1 0 tcp 60 -g $gateway)

    if [[ $mapping_info =~ Mapped\ public\ port\ ([0-9]+) ]]; then
        mapped_port="${BASH_REMATCH[1]}"
        echo "Mapped public port: $mapped_port"

        # Check if the mapped port has changed
        if [[ "$mapped_port" != "$previous_mapped_port" ]]; then
            echo "Changing qBittorrent port to $mapped_port"

            # Change qBittorrent port
            qbittorrent --torrenting-port=$mapped_port

            # Wait for qBittorrent to start
            sleep 5

            # Set the window position and workspace
            wmctrl -r 'qBittorrent' -e 0,0,0,1920,1080 # Adjust the values as per your screen resolution
            wmctrl -r 'qBittorrent' -t 3 # Set workspace to 1 (you can change it to your desired workspace)

            # Update the previous mapped port
            previous_mapped_port="$mapped_port"
        else
            echo "Mapped port has not changed. Skipping qBittorrent port update."
        fi
    else
        echo "ERROR: Failed to extract Mapped public port from natpmpc output"
    fi

    sleep 45
done

