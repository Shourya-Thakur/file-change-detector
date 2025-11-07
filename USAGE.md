# Usage Guide

## Quick Start

### 1. Basic Monitoring
```bash
./file_monitor.sh test_files/config.txt
```

### 2. Custom Check Interval
```bash
# Check every 5 seconds
./file_monitor.sh -i 5 test_files/config.txt
```

### 3. Enable Logging
```bash
./file_monitor.sh -l logs/monitor.log test_files/config.txt
```

### 4. Monitor Multiple Files
```bash
./file_monitor.sh test_files/config.txt test_files/sample.txt
```

## Testing

**Terminal 1** - Start monitor:
```bash
./file_monitor.sh test_files/config.txt
```

**Terminal 2** - Make changes:
```bash
echo "Testing change detection" >> test_files/config.txt
```

You should see a notification in Terminal 1!

## All Options

| Option | Description | Example |
|--------|-------------|---------|
| `-i N` | Check every N seconds | `-i 3` |
| `-l FILE` | Save logs to FILE | `-l logs/my.log` |
| `-h` | Show help | `-h` |

## Examples

### Example 1: Monitor with 1-second interval
```bash
./file_monitor.sh -i 1 important_file.txt
```

### Example 2: Monitor and log
```bash
./file_monitor.sh -l logs/changes.log config.txt
```

### Example 3: Multiple files with logging
```bash
./file_monitor.sh -i 3 -l logs/multi.log file1.txt file2.txt file3.txt
```

## Stopping the Monitor

Press `Ctrl + C` to stop monitoring.
