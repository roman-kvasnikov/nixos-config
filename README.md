# 🐧 Modern NixOS Configuration

> A comprehensive, modular NixOS configuration featuring GNOME desktop, security hardening, and modern development tools.

[![NixOS](https://img.shields.io/badge/NixOS-25.05-blue.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blueviolet.svg?style=flat&logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home-Manager-orange.svg?style=flat&logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)

## ✨ Features

### 🖥️ Desktop Environment

- **GNOME + Wayland** - Modern desktop with smooth animations
- **PipeWire** - Low-latency audio system
- **Stylix** - Unified theming across all applications
- **Custom Electron Apps** - WhatsApp, Discord, Claude AI, DeepSeek
- **GNOME Extensions** - Auto-move windows, clipboard history, Bitcoin markets

### 🔒 Security & Privacy

- **LUKS + LVM** - Full disk encryption with logical volume management
- **SSH Hardening** - Secure client configuration, disabled server by default
- **DNSSEC** - DNS over HTTPS with Cloudflare
- **Xray Proxy** - Custom proxy management system with systemd integration

### 🛠️ Development Tools

- **Modern CLI** - `ripgrep`, `fd`, `eza`, `bat`, `dust`, and more
- **Git Integration** - Automated Obsidian vault and wallpaper syncing
- **System Monitoring** - `htop`, `btop`, `bottom` with custom configurations
- **Code Editing** - Cursor, with VS Code settings sync

### 📦 Package Management

- **Flakes** - Reproducible builds with locked dependencies
- **Home Manager** - User-space package and configuration management
- **Modular Design** - Clean separation between system and user configurations

## 🏗️ Architecture

```
nixos-config/
├── flake.nix              # Main entry point and dependencies
├── shared.nix             # Common host settings
├── hosts/                 # Host-specific configurations
│   ├── nixos/            # Main desktop (LUKS+LVM)
│   ├── nixos-vm/         # Virtual machine setup
│   └── huawei/           # Laptop configuration
├── nixos/                # System-level modules
│   ├── modules/          # Boot, networking, services, etc.
│   └── packages.nix      # System packages and GNOME exclusions
└── home-manager/         # User environment
    ├── modules/          # Application configurations
    ├── config/           # Base settings (GTK, XDG)
    └── packages.nix      # User packages and apps
```

## 🚀 Quick Start

### Prerequisites

- NixOS with flakes enabled
- Git configured with SSH keys

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/roman-kvasnikov/nixos-config.git ~/.config/nixos
cd ~/.config/nixos
```

2. **Format the code (recommended):**

```bash
alejandra .
```

3. **Apply system configuration:**

```bash
sudo nixos-rebuild switch --flake .#nixos
# For VM: sudo nixos-rebuild switch --flake .#nixos-vm
```

4. **Apply user configuration:**

```bash
home-manager switch --flake .#romank@nixos
# For VM: home-manager switch --flake .#romank@nixos-vm
```

### 🔧 Host Configuration

The configuration supports multiple hosts:

| Host       | Purpose         | Storage      | Features                               |
| ---------- | --------------- | ------------ | -------------------------------------- |
| `nixos`    | Main desktop    | LUKS+LVM     | Full encryption, optimized for desktop |
| `nixos-vm` | Virtual machine | Simple BTRFS | QEMU guest tools, SSH enabled          |
| `huawei`   | Laptop          | LUKS+LVM     | Portable configuration                 |

## 📱 Applications

### Desktop Applications

- **Brave Browser** - Privacy-focused with corporate policies
- **Obsidian** - Knowledge management with auto-sync
- **KeePassXC** - Password manager
- **LibreOffice** - Office suite
- **VLC** - Media player
- **Telegram** - Messaging

### Development Tools

- **Cursor** - AI-powered code editor
- **Git** - Version control with SSH key management
- **Postman** - API testing
- **Claude Code** - AI assistant for development

### System Utilities

- **Kitty** - GPU-accelerated terminal
- **Fastfetch** - System information
- **Bottom/Htop** - System monitoring
- **File managers** - Nautilus + Yazi (terminal)

### Custom Electron Apps

Built-in Electron wrappers for:

- **WhatsApp** - Desktop messaging
- **Discord** - Gaming communication
- **Claude AI** - AI assistant interface
- **DeepSeek** - Code analysis AI

## ⚙️ Key Commands

### System Management

```bash
# Update system
sudo nixos-rebuild switch --flake .#nixos

# Update user environment
home-manager switch --flake .#romank@nixos

# Update flake inputs
nix flake update

# Check flake validity
nix flake check

# Format Nix code
alejandra .
```

### Proxy Management

```bash
# Enable all proxies
xrayctl all-on

# Disable all proxies
xrayctl all-off

# Check proxy status
xrayctl status
```

### Git Operations

```bash
# Sync Obsidian vault (automated on home-manager switch)
git-sync-obsidian

# Update wallpapers
git-sync-wallpapers
```

## 🎨 Theming

The configuration uses **Stylix** for unified theming:

- **Base16 scheme** - Consistent color palette
- **Ubuntu Nerd Font** - Programming ligatures and icons
- **Dark theme** - Optimized for extended use
- **Wallpapers** - Curated collection from personal repository

## 🔧 GNOME Extensions

| Extension         | Purpose               |
| ----------------- | --------------------- |
| Auto Move Windows | Workspace management  |
| Bitcoin Markets   | Cryptocurrency prices |
| Blur My Shell     | Visual effects        |
| Caffeine          | Prevent sleep mode    |
| Clipboard History | Enhanced clipboard    |
| Dash to Dock      | Application dock      |
| Just Perfection   | UI customization      |
| Search Light      | Improved search       |

## 📊 System Monitoring

### Built-in Monitoring

- **Bitcoin Markets** - Cryptocurrency price tracking in GNOME panel
- **System monitors** - htop, btop, bottom with custom configurations
- **Network monitoring** - bandwhich, nethogs for traffic analysis

### Performance Optimizations

- **Linux Zen Kernel** - Desktop-optimized kernel
- **BBR Congestion Control** - Improved network performance
- **CAKE Qdisc** - Better traffic shaping
- **SSD Optimizations** - Proper I/O schedulers and mount options

## 🛡️ Security Features

### Disk Encryption

- **LUKS** - Full disk encryption
- **LVM** - Logical volume management
- **Encrypted Swap** - Random encryption for swap partition

### Network Security

- **DNS over HTTPS** - Cloudflare with DNSSEC
- **SSH Hardening** - Modern ciphers and key exchange
- **Proxy Support** - Xray for traffic routing

### System Hardening

- **Minimal Attack Surface** - Disabled unnecessary services
- **SSH Server Disabled** - Only SSH client enabled by default
- **Package Verification** - Cryptographic verification of packages

## 📚 Documentation

Comprehensive documentation is available in `CLAUDE.md` including:

- Detailed module descriptions
- Configuration options
- Troubleshooting guides
- Development workflow
- State management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Format code with `alejandra .`
4. Test with `nix flake check`
5. Submit a pull request

## 📄 License

This configuration is provided as-is for educational and personal use. Feel free to fork and adapt for your own needs.

## 🔗 Related Projects

- [Wallpapers Collection](https://github.com/roman-kvasnikov/wallpapers)
- [Obsidian Vault](https://github.com/roman-kvasnikov/obsidian-vault)
- [VS Code Settings](https://github.com/roman-kvasnikov/vscode-settings)

---

⭐ **Star this repository if you find it useful!**

Built with ❤️ on NixOS
