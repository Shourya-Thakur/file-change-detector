# 📁 File Change Detector

![Bash](https://img.shields.io/badge/bash-4.0+-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-unix%20%7C%20linux%20%7C%20macOS-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A lightweight Unix shell script that monitors files in real-time and alerts you when their content changes.

## 🎯 What It Does

This tool continuously watches one or more files and notifies you immediately when any modification is detected. Perfect for monitoring configuration files, log files, or any content that needs tracking.

**Example Output:**
```
[2025-11-07 14:30:15] Starting file monitor...
[2025-11-07 14:30:15] Monitoring: config.txt
[2025-11-07 14:30:15] Press Ctrl+C to stop
[2025-11-07 14:31:42] ⚠️  File config.txt has been modified.
```

## ✨ Features

- 🔍 **Checksum-based detection** - Accurate change detection using MD5/SHA256
- ⚡ **Real-time monitoring** - Instant notifications when files change
- 📝 **Optional logging** - Save all alerts to a log file
- 🎛️ **Configurable intervals** - Set custom check frequencies
- 📦 **Multiple file support** - Monitor several files simultaneously
- 🎨 **Color-coded output** - Easy-to-read terminal messages

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/file-change-detector.git
cd file-change-detector

# Make the script executable
chmod +x file_monitor.sh
```

### Basic Usage

**Monitor a single file:**
```bash
./file_monitor.sh config.txt
```

**Monitor with custom 5-second interval:**
```bash
./file_monitor.sh -i 5 config.txt
```

**Monitor multiple files:**
```bash
./file_monitor.sh config.txt data.txt settings.json
```

**Enable logging:**
```bash
./file_monitor.sh -l monitor.log config.txt
```

### Try It Out

Open two terminal windows:

**Terminal 1** - Start monitoring:
```bash
./file_monitor.sh test.txt
```

**Terminal 2** - Modify the file:
```bash
echo "New content" >> test.txt
```

Watch Terminal 1 for the change notification! 🎉

## 📖 Usage

```bash
./file_monitor.sh [OPTIONS] FILE [FILE...]
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-i SECONDS` | Check interval in seconds | 2 |
| `-l LOGFILE` | Log changes to specified file | None |
| `-h` | Display help message | - |

### Examples

**Monitor a config file every 10 seconds:**
```bash
./file_monitor.sh -i 10 /etc/myapp/config.conf
```

**Monitor and log all changes:**
```bash
./file_monitor.sh -l changes.log important.txt
```

**Monitor multiple files with logging:**
```bash
./file_monitor.sh -i 3 -l activity.log file1.txt file2.txt file3.txt
```

## 🛠️ How It Works

1. **Initial Checksum**: Calculates checksum (MD5/SHA256) of each monitored file
2. **Continuous Loop**: Waits for specified interval, then rechecks files
3. **Comparison**: Compares new checksum with previous one
4. **Notification**: Alerts user if checksums differ (file modified)
5. **Update**: Stores new checksum and continues monitoring

## 📋 Requirements

- Unix/Linux or macOS
- Bash 4.0 or higher
- Standard utilities: `md5sum` or `shasum`
- Read permissions for monitored files

**Check your Bash version:**
```bash
bash --version
```

## 🎓 Use Cases

- **Development**: Watch source files for automatic recompilation triggers
- **System Administration**: Monitor critical configuration files
- **Security**: Track unauthorized changes to important files
- **Automation**: Trigger scripts or workflows when files update
- **Debugging**: Track when and how files are being modified

## ⚙️ Technical Details

**Built with:**
- Shell scripting (Bash)
- Checksum utilities (md5sum/shasum)
- Unix file operations
- Signal handling (trap)

**Key concepts:**
- File I/O operations
- Checksum comparison
- Process control
- Command-line argument parsing
- Error handling

## ⚠️ Limitations

- Cannot detect file deletion (only content changes)
- Requires manual stopping (Ctrl+C)
- Very frequent checks may impact system performance
- No built-in file permission change detection

## 🔮 Potential Enhancements

- [ ] Recursive directory monitoring
- [ ] File creation/deletion detection
- [ ] Email/webhook notifications
- [ ] Daemon mode for background operation
- [ ] Configuration file support
- [ ] File permission change detection
- [ ] GUI/Web interface

## 🤝 Contributing

This is a learning project, but suggestions and improvements are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 About

Created as part of Unix Systems Programming coursework to demonstrate:
- Shell scripting proficiency
- Unix command-line tools
- File system operations
- Real-time monitoring concepts

---

**⭐ If you find this useful, please star the repository!**

**📧 Questions?** Open an issue or reach out at [your.email@example.com]

*Last updated: November 2025*
