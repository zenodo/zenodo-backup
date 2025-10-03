Zenodo Backup
=============

Static backup site for Zenodo in case of maintenance and/or unexpected downtime.

## Usage

```bash
./update-message.sh show                                                                   # Show current message
./update-message.sh default                                                                # Reset to default message
./update-message.sh set '2025-10-06 06:30' 'Zenodo will be unavailable for 1-2 minutes.'  # Set message with datetime (UTC)
./update-message.sh set 'Zenodo is currently down.'                                        # Set message without datetime
```
