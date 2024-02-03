# qBittorrent automatic port fowarding

This bash script automates the process of mapping the public port for qBittorrent using the natpmp protocol. It periodically checks for changes in the mapped public port and updates the qBittorrent port accordingly.

## Prerequisites

- **qBittorrent**: Ensure that `qBittorrent` is installed on your system. If not, the script will attempt to install it using `sudo dnf install -y qbittorrent`.

## Usage

1. Copy the script to your local machine or server.
2. Make the script executable:
   ```bash
   chmod +x torrent.sh
   ```
3. Run the script:
   ```bash
   ./torrent.sh
   ```

## Workflow

1. The script checks if `qBittorrent` is installed. If not, it installs it using the package manager (`dnf` in this case).

2. It enters a continuous loop, checking for changes in the mapped public port every 45 seconds.

3. It uses the `natpmpc` tool to obtain the gateway address and map the public port using the natpmp protocol.

4. If the mapping is successful, the script extracts the mapped public port and compares it with the previous port.

5. The script repeats the process in the loop, continuously monitoring for changes in the mapped public port.

## Configuration

- Adjust the `sleep` duration at the end of the script to control how frequently the script checks for changes (default is 45 seconds).

## Notes

- Ensure that you have the necessary permissions to install packages using `sudo` or run the script with appropriate privileges.

- This script is designed for systems using the `dnf` package manager. If you are using a different package manager, update the installation command accordingly.

- It's recommended to review and customize the script based on your specific requirements and system configuration.
