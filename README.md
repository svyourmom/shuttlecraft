# Shuttlecraft
**Shuttlecraft** is a macOS menu bar utility designed to simplify managing and toggling your `sshuttle` VPN connections.
## Features
* **Menu Bar Access:** Quickly connect and disconnect from your configured `sshuttle` hosts directly from the macOS menu bar.
* **Modern macOS Tahoe UI:** Beautiful glass effects and modern design elements that integrate seamlessly with macOS Sequoia.
* **VPN Mode:** One-click toggle to route all traffic (IPv4/IPv6) and DNS through your SSH connection for full VPN functionality.
* **Star Trek Themed Icons:** Space-themed menu bar icons including the iconic Starfleet delta symbol for disconnected state.
* **Connection Management:**
    * Add, edit, and remove `sshuttle` host configurations through an elegant preferences window.
    * Configure parameters for each host, including:
        * Connection Name
        * Remote SSH Host (e.g., `user@server.com`)
        * VPN Mode (routes all traffic: 0/0, ::/0 with DNS)
        * Manual Routing: Subnets to Forward (comma-separated)
        * DNS Forwarding (`--dns`)
        * Auto Add Hostnames (`-N`)
        * Advanced options: Excluded Subnets (`-x`), Custom SSH Command (`--ssh-cmd`)
* **Status Indication:**
    * Visual feedback in the menu for connection status (Disconnected, Connecting, Connected, Error).
    * Dynamic menu bar icons: △ (disconnected), 🚀 (connected), 🛡️ (VPN mode active).   
* **Persistent Configurations:** Your host configurations are saved and loaded across app launches using `UserDefaults`.

## License
* **GPLv3 Licensed:** Open source and free to use, modify, and distribute under the GNU General Public License v3.0.
This project is licensed under the GNU General Public License v3.0. A copy of the license should be included with the source code (e.g., in a `LICENSE` file).


## Requirements
* **macOS Sequoia (15.5) or later** - Tested on macOS 15.5 (Tahoe/26).
* **`sshuttle` must be installed on your system.** Shuttlecraft currently expects `sshuttle` to be located at `/opt/homebrew/bin/sshuttle`. The easiest way to install it there is via [Homebrew](https://brew.sh/):
    ```bash
    brew install sshuttle
    ```


## Installation 
1.  **Install `sshuttle`:** If you haven't already, install `sshuttle` using Homebrew:
    ```bash
    brew install sshuttle
    ```
    Ensure it is available at `/opt/homebrew/bin/sshuttle`.
2.  **Download Shuttlecraft:**
    * Download the latest `Shuttlecraft.app` release from the [GitHub Releases page] https://github.com/svyourmom/shuttlecraft/releases

3.  **Install the App:**
    * Unzip the downloaded file (if it's a `.zip`).
    * Drag `Shuttlecraft.app` to your `/Applications` folder.
4.  **First Launch (Gatekeeper):**
    * The first time you open Shuttlecraft, macOS Gatekeeper might show a warning because the app is from an (unidentified for now) developer.
    * To open it, right-click (or Control-click) the `Shuttlecraft.app` icon and choose "Open" from the context menu. You may need to confirm again.
    * (Alternatively, you might need to allow it in **System Settings > Privacy & Security**).
5.  **`sudo` Password for `sshuttle`:**
    * When you activate a connection for the first time using Shuttlecraft, `sshuttle` (which Shuttlecraft launches in the background) needs administrator privileges to modify network settings.
    * You will likely see a standard macOS password prompt asking for your administrator password. This is for `sudo` being used by `sshuttle`.
    * You will need to enter your macOS user password for `sshuttle` to function. This may occur for each new `sshuttle` session unless you have configured passwordless `sudo` for `sshuttle` yourself.


## Current Status & Limitations
* The path to the `sshuttle` executable is currently hardcoded to `/opt/homebrew/bin/sshuttle`.
* This application is currently under development. While core features are functional, further refinements and robust error handling are ongoing. 

## Acknowledgements
* This application relies on Shuttle, Major thanks to the creators. https://github.com/sshuttle/sshuttle/graphs/contributors
