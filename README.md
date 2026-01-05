# MODT Server Information Script

A terminal-based script that provides real-time server information and critical service status for Linux systems. Designed to display at the top of the terminal, it helps system users monitor essential metrics and identify issues quickly.

![Example Output](image.png) 
## Features

- **Critical Service Monitoring**: Displays the status of critical services (e.g., web servers, databases) to highlight which are up or down.
- **Zombie Process Detection**: Identifies and lists zombie processes.
- **System Metrics**:
  - Hostname and IP address
  - System uptime and load averages
  - CPU temperature and usage
  - Memory and disk utilization
- **Customizable**: Easily add or remove monitored services and adjust thresholds.

## Requirements

- Linux-based operating system
- Bash shell
- Utilities: `figlet`, `lm-sensors`, `bc`, `procps`, `systemctl`

## Installation

1. Install the necessary requirements:
   ```bash
   sudo apt update && sudo apt install -y figlet lm-sensors bc procps
   ```

2. Clone this repository:
   ```bash
   git clone [repository-url]
   ```

3. Make the script executable:
   ```bash
   chmod +x MODT-ServerINFO.sh
   ```

4. Add the script to your shell configuration:
   - For Bash users, edit `~/.bashrc`:
     ```bash
     echo '/path/to/MODT-ServerINFO.sh' >> ~/.bashrc
     ```
   - For Zsh users, edit `~/.zshrc`:
     ```bash
     echo '/path/to/MODT-ServerINFO.sh' >> ~/.zshrc
     ```

5. Reload your shell configuration:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

## Usage

Once installed, the script will automatically display system information and critical service status at the top of your terminal whenever you open a new session.


## Contributing

Contributions are welcome! Feel free to fork this repository and submit pull requests for improvements or new features.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

**Abubakkar Khan Fazla Rabbi**  
*System Administrator*

## Support

For support, please open an issue in the repository's issue tracker.
