# S3FSCtl Configuration

This directory contains configuration for S3FSCtl service.

## Files:

- `config.json` - Main configuration file
- `config.example.json` - Example configuration
- `s3fsctl.log` - Service log file (created when s3fsctl runs)

## Security Notes:

- Password files should have 600 permissions
- Only use absolute paths
- Avoid mounting in system directories (/bin, /usr, /etc, etc.)
- Logs are written to ~/.config/s3fs/s3fsctl.log

## Usage:

```bash
s3fsctl mount [bucket]           # Mount all configured buckets
s3fsctl unmount [bucket]         # Unmount all buckets
s3fsctl status [bucket]          # Show mount status
s3fsctl test [bucket]            # Test bucket configuration
s3fsctl logs [lines]             # Show recent log entries
s3fsctl clear-logs               # Clear log file
s3fsctl config                   # Show current configuration
s3fsctl list                     # List all configured buckets
```

## SystemD Service:

The service automatically mounts all configured buckets on login.

- Enable: `systemctl --user enable s3fsctl.service`
- Start: `systemctl --user start s3fsctl.service`
- Status: `systemctl --user status s3fsctl.service`
