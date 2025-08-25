# Home VPN Configuration

This directory contains configuration for Home VPN service.

## Files:

- `config.json` - Main configuration file
- `config.example.json` - Example configuration
- `connections.log` - Service log file (created when homevpnctl runs)
- `.daemon.pid` - PID file (created when homevpnctl runs)

## Security Notes:

- Logs are written to ~/.config/homevpn/connections.log

## Usage:

```bash
homevpnctl connect                      # Smart connect (checks if at home first)
homevpnctl check-home                   # Check if currently at home network
homevpnctl force-connect                # Force connect bypassing home detection
homevpnctl status                       # Show connection status
homevpnctl logs                         # Show recent log entries
homevpnctl config                       # Show config file paths and settings
```

## SystemD Service:

The service automatically connects to all configured VPN connections on login.

- Enable: `homevpnctl service-enable`
- Start: `homevpnctl service-start`
- Status: `homevpnctl status`
- Stop: `homevpnctl service-stop`
- Restart: `homevpnctl service-restart`
- Disable: `homevpnctl service-disable`
