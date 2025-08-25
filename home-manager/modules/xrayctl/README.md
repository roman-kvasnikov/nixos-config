# XrayCtl Configuration

This directory contains configuration for Xray proxy service management.

## Files:

- `config.json` - Main Xray configuration file
- `config.example.json` - Example Xray configuration
- `proxy-env` - Environment variables for terminal proxy (auto-generated)
- `proxy-env.fish` - Fish shell proxy variables (auto-generated)
- `proxy-enabled` - Flag file indicating proxy state (auto-generated)

## Features:

- **Global Proxy Management**: Enable/disable system-wide proxy settings in GNOME
- **Terminal Proxy Support**: Persistent proxy environment variables for all shells
- **Service Integration**: Full systemd service management
- **Multi-shell Support**: Works with bash, zsh, fish shells
- **Automatic Configuration**: Smart proxy detection and configuration

## Security Notes:

- All proxy settings are user-scoped (no root privileges required)
- GNOME system proxy settings are managed via gsettings
- Environment variables are sourced from user configuration files
- Service runs with restricted permissions and sandboxing

## Usage:

### Quick Commands:

```bash
xrayctl global-enable           # Start Xray + enable global proxy settings
xrayctl global-disable          # Stop Xray + disable global proxy settings
```

### Service Management:

```bash
xrayctl service-enable          # Enable autostart
xrayctl service-start           # Start Xray service
xrayctl service-stop            # Stop Xray service
xrayctl service-restart         # Restart Xray service
xrayctl service-disable         # Disable autostart
xrayctl service-status          # Show service status
xrayctl service-logs            # Show service logs
```

### System Proxy (GNOME):

```bash
xrayctl system-enable           # Enable system-wide proxy
xrayctl system-disable          # Disable system-wide proxy
xrayctl system-status           # Show system proxy status
```

### Terminal Proxy:

```bash
xrayctl terminal-enable         # Enable terminal proxy (persistent)
xrayctl terminal-disable        # Disable terminal proxy
xrayctl terminal-status         # Show terminal proxy status
xrayctl env-proxy              # Show manual environment variables
xrayctl clear-env              # Clear proxy environment variables
```

### Configuration:

```bash
xrayctl config                  # Show config file paths
```

## SystemD Services:

The module provides two systemd user services:

### 1. xray.service

- **Purpose**: Runs the Xray proxy server
- **Type**: Simple long-running service
- **Config**: Uses the JSON configuration file
- **Security**: Sandboxed with restricted permissions

### 2. xrayctl.service

- **Purpose**: Manages global proxy settings on login
- **Type**: Oneshot service that remains active
- **Function**: Automatically enables global proxy when started
- **Integration**: Depends on xray.service

### Service Control:

```bash
# Direct systemctl commands (alternative)
systemctl --user enable xray.service       # Enable Xray autostart
systemctl --user start xray.service        # Start Xray
systemctl --user status xray.service       # Show Xray status
systemctl --user stop xray.service         # Stop Xray

systemctl --user enable xrayctl.service    # Enable proxy management
systemctl --user start xrayctl.service     # Start proxy management
```

## Configuration Structure:

The `config.json` follows standard Xray configuration format:

```json
{
	"log": {
		"loglevel": "warning"
	},
	"inbounds": [
		{
			"port": 1080,
			"listen": "127.0.0.1",
			"protocol": "socks",
			"settings": {
				"auth": "noauth",
				"udp": true
			},
			"tag": "socks-in"
		}
	],
	"outbounds": [
		{
			"protocol": "freedom",
			"settings": {},
			"tag": "freedom-out"
		}
	],
	"routing": {
		"rules": [
			{
				"type": "field",
				"inboundTag": ["socks-in"],
				"outboundTag": "freedom-out"
			}
		]
	}
}
```

## Environment Integration:

### Terminal Proxy Variables:

When terminal proxy is enabled, these variables are set:

- `http_proxy` - HTTP proxy URL
- `https_proxy` - HTTPS proxy URL
- `ftp_proxy` - FTP proxy URL
- `no_proxy` - Bypass list for local addresses

### Shell Integration:

The tool automatically detects your shell and adds appropriate configuration:

- **Fish**: `~/.config/fish/conf.d/xray-proxy.fish`
- **Bash**: `~/.bashrc`
- **Zsh**: `~/.zshrc`

## Proxy Types Supported:

- **SOCKS5**: Primary proxy protocol
- **HTTP/HTTPS**: Alternative proxy protocol
- **Transparent**: System-level transparent proxying
- **Mixed**: Combination of multiple protocols

## Troubleshooting:

1. **Service won't start**: Check `xrayctl service-status` and `xrayctl service-logs`
2. **Proxy not working**: Verify configuration with `xrayctl config`
3. **Terminal proxy issues**: Check shell integration with `xrayctl terminal-status`
4. **System proxy problems**: Use `xrayctl system-status` to diagnose

## Dependencies:

- `xray` - Core proxy software
- `jq` - JSON configuration processing
- `gsettings` - GNOME settings management
- `systemd` - Service management
- Standard shell utilities (grep, sed, cut, etc.)
