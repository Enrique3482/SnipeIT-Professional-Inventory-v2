# SnipeIT Professional Inventory System - README (EN)

![Version](https://img.shields.io/badge/Version-2.2.0-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)

## 🎯 Overview

The **SnipeIT Professional Inventory System** is an enterprise-grade solution for automated hardware inventory with complete Snipe-IT integration. Version 2.2.0 introduces complete VS Code workspace integration and user-friendly one-click deployment options.

### 🌟 Key Features

- **🔄 Automatic Hardware Detection**: Complete system analysis with intelligent component identification
- **🔗 Seamless Snipe-IT Integration**: Direct API synchronization with extended custom fields
- **🖥️ VS Code Workspace**: Professional development environment with integrated tasks and debugging
- **🚀 One-Click Deployment**: Batch files for immediate execution without command line knowledge
- **🛡️ Test/Production Mode**: Safe test environment with complete API simulation
- **📊 Extended Reporting**: Detailed logs and execution reports
- **🔧 Automatic Maintenance Tracking**: Intelligent asset lifecycle management

## 📦 Quick Start

### Option 1: One-Click for End Users
```bash
# 1. Double-click one of the batch files:
Test-Modus.bat           # For safe testing without API calls
Produktions-Modus.bat    # For live environment with real API calls
Interaktiv-Starten.bat   # For guided execution with menu
```

### Option 2: PowerShell for Power Users
```powershell
# Intelligent starter with interactive menu
.\Start-SnipeInventory.ps1

# Direct execution with parameters
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging
```

### Option 3: VS Code for Developers
```bash
# Open workspace
code workspace.code-workspace

# Use integrated tasks:
# Ctrl+Shift+P → "Tasks: Run Task" → Select desired mode
```

## 🛠️ Installation

### System Requirements
- **Operating System**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: Version 5.1 or higher
- **Network**: Access to your Snipe-IT server
- **Optional**: Visual Studio Code for development

### Installation Steps

1. **Clone or download repository**
   ```bash
   git clone https://github.com/Enrique3482/SnipeIT-Professional-Inventory.git
   cd SnipeIT-Professional-Inventory
   ```

2. **Adjust configuration**
   ```powershell
   # Edit SnipeConfig.json
   notepad SnipeConfig.json
   ```
   
   Important settings:
   ```json
   {
     "Snipe": {
       "Url": "http://your-snipeit-server.com/api/v1",
       "Token": "Your-API-Token-here",
       "StandardCompanyName": "Your Company Ltd"
     }
   }
   ```

3. **Perform first test**
   ```bash
   # Double-click Test-Modus.bat
   # OR
   .\Start-SnipeInventory.ps1
   ```

## 🎮 Usage

### For End Users (Easiest Method)

**Test-Modus.bat**
- Performs complete simulation
- No real API calls
- Safe for testing and validation

**Produktions-Modus.bat**  
- Real API calls to Snipe-IT
- Creates/updates actual assets
- Requires confirmation before execution

**Interaktiv-Starten.bat**
- Guided menu for mode selection
- Integrated help and explanations
- Ideal for new users

### For Power Users (PowerShell)

```powershell
# Show all available parameters
Get-Help .\SnipeIT-Professional-Inventory.ps1 -Full

# Test mode with verbose logging
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging

# Production mode for specific customer
.\SnipeIT-Professional-Inventory.ps1 -CustomerName "ACME Corp" -VerboseLogging

# With simulated hardware for testing purposes
.\SnipeIT-Professional-Inventory.ps1 -TestMode -SimulateHardware -VerboseLogging
```

### For Developers (VS Code)

1. **Open workspace**
   ```bash
   code workspace.code-workspace
   ```

2. **Install recommended extensions** (automatically suggested)
   - PowerShell Extension
   - GitLens
   - Error Lens

3. **Use integrated tasks**
   - `Ctrl+Shift+P` → "Tasks: Run Task"
   - Available tasks:
     - 🧪 Test Mode (Safe)
     - 🚀 Production Mode  
     - 💬 Interactive Mode
     - 📊 Code Analysis

4. **Debugging**
   - Set breakpoints
   - `F5` to start debugging
   - Real-time variable inspection

## 🔧 Configuration

### SnipeConfig.json Structure

```json
{
  "Snipe": {
    "Url": "http://your-snipeit-server/api/v1",
    "Token": "YOUR_API_TOKEN_HERE...",
    "StandardCompanyName": "Your Company Ltd",
    "StandardStatusName": "In Use",
    "StandardModelFieldsetId": 2,
    "StandardCategoryId": 1
  },
  "CustomFieldMapping": {
    "_snipeit_mac_address_1": "MacAddress",
    "_snipeit_os_version_2": "OperatingSystem",
    "_snipeit_cpu_4": "Processor",
    "_snipeit_ram_gb_5": "Memory"
  },
  "Performance": {
    "ApiTimeout": 60,
    "MaxRetries": 3,
    "RetryDelay": 2
  }
}
```

### Advanced Configuration

**Auto-create custom fields**
```powershell
# Script automatically creates all required custom fields
# Mapping can be customized in SnipeConfig.json
```

**Adjust maintenance intervals**
```json
{
  "Maintenance": {
    "IntervalDays": 365,    // Maintenance every 365 days
    "WarningDays": 30,      // Warning 30 days in advance
    "CriticalDays": 7       // Critical 7 days in advance
  }
}
```

## 📊 Features in Detail

### Hardware Detection
- **CPU**: Detailed processor information with cores and threads
- **RAM**: Memory modules with capacity and count
- **Storage**: Internal and external storage devices with type detection
- **Network**: IP addresses, MAC addresses, active adapters
- **GPU**: Graphics card identification
- **Monitor**: External monitor detection (optional)
- **Docking Stations**: USB hub and docking station detection

### Asset Management
- **Automatic Category Assignment**: Based on hardware type
- **Intelligent Status Assignment**: "Deployable" or "In Use" based on user matching
- **Custom Fields Management**: Automatic creation and assignment
- **Asset Checkout**: Automatic checkout on user-computer match

### Maintenance and Monitoring
- **System Age Calculation**: Automatic determination based on installation
- **Maintenance Status**: OVERDUE/CRITICAL/WARNING/OK
- **Performance Metrics**: Execution time tracking
- **Detailed Logs**: Multiple log levels for different purposes

## 🚀 Advanced Features

### Test Mode (Safety)
```powershell
# Complete simulation without real API calls
.\SnipeIT-Professional-Inventory.ps1 -TestMode
```
- Simulates all API responses
- No changes to Snipe-IT
- Perfect for testing and development
- Full functionality for validation

### Production Mode (Live)
```powershell
# Real API calls with live data
.\SnipeIT-Professional-Inventory.ps1 -CustomerName "ACME Corp"
```
- Real asset creation/updates
- Custom fields are created
- Automatic checkout on matching
- Complete synchronization

### Simulated Hardware
```powershell
# Simulate additional hardware for testing purposes
.\SnipeIT-Professional-Inventory.ps1 -TestMode -SimulateHardware
```
- Additional monitors
- Docking stations
- Extended specifications
- Ideal for demo and training

## 📁 Project Structure

```
SnipeIT-Professional-Inventory/
│
├── 📄 SnipeIT-Professional-Inventory.ps1    # Main script
├── 🚀 Start-SnipeInventory.ps1              # Intelligent starter
├── ⚙️ SnipeConfig.json                       # Configuration
├── 🏢 workspace.code-workspace               # VS Code workspace
├── 📋 PSScriptAnalyzerSettings.psd1         # Code quality rules
│
├── 🎯 Launcher/
│   ├── Test-Modus.bat                       # Test starter
│   ├── Produktions-Modus.bat                # Production starter
│   └── Interaktiv-Starten.bat               # Interactive starter
│
├── 📚 Documentation/
│   ├── README-DE.md                         # German documentation
│   ├── README-EN.md                         # English documentation
│   ├── SCHNELLSTART-DE.md                   # German quick start guide
│   ├── QUICKSTART-EN.md                     # English quick start guide
│   ├── CHANGELOG-v2.2.0-DE.md              # German changelog
│   └── CHANGELOG-v2.2.0-EN.md              # English changelog
│
└── 📊 Logs/ (created automatically)
    ├── SnipeIT-Inventory.log               # Main log
    ├── SnipeIT-Errors.log                  # Error log
    └── Backups/                             # Automatic backups
```

## 🔍 Troubleshooting

### Common Issues

**1. PowerShell Execution Policy Error**
```powershell
# Temporary solution (automatically done by batch files)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Permanent solution (requires admin rights)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

**2. API Connection Error**
```powershell
# Test API connection
Invoke-RestMethod -Uri "http://your-server/api/v1/models" -Headers @{'Authorization'='Bearer YOUR-TOKEN'}
```

**3. Missing Custom Fields**
```powershell
# Script automatically creates missing fields
# For issues: Use TestMode for validation
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging
```

### Debug Information

**Enable verbose logging**
```powershell
.\SnipeIT-Professional-Inventory.ps1 -VerboseLogging
```

**Check log files**
```powershell
# Main log
Get-Content "C:\ProgramData\SnipeIT\Inventory\SnipeIT-Inventory.log" -Tail 50

# Error log
Get-Content "C:\ProgramData\SnipeIT\Errorlog\SnipeIT-Errors.log" -Tail 20
```

## 📈 Performance and Optimization

### Optimization for Large Environments

**Adjust batch size**
```json
{
  "Performance": {
    "BatchSize": 100,        // Larger batches for more efficiency
    "ApiTimeout": 120,       // Longer timeouts for large datasets
    "MaxRetries": 5          // More retries for stability
  }
}
```

**Use caching**
- Entity cache reduces API calls
- Automatic caching of manufacturers, models, etc.
- Cache is reset per session

### Monitoring

**Performance metrics**
```
Hardware Detection Time: 00:12.500
API Synchronization Time: 00:08.200  
Field Management Time: 00:03.100
Total Execution Time: 00:23.800
```

**Execution statistics**
- Number of processed assets
- API calls counted
- Errors and warnings logged
- Success/failure rate

## 🔐 Security

### Best Practices

**API token security**
```powershell
# Store token in secure file (not in script)
$config = Get-Content "secure-config.json" | ConvertFrom-Json
```

**Execution policy**
```powershell
# Use minimal permissions
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Test-first approach**
```powershell
# Always validate in test mode first
.\SnipeIT-Professional-Inventory.ps1 -TestMode
```

### Audit and Compliance

**Complete logging**
- All API calls are logged
- Errors with line numbers
- Execution time and user
- Asset changes documented

**Rollback capabilities**
- Automatic backups before changes
- Recovery functions
- Version control via Git

## 🤝 Contributing and Support

### Community

- **GitHub Issues**: [Report problems](https://github.com/Enrique3482/SnipeIT-Professional-Inventory/issues)
- **Feature Requests**: Suggest new features
- **Pull Requests**: Code contributions welcome
- **Wiki**: Community documentation

### Development

**Local development**
```bash
git clone https://github.com/Enrique3482/SnipeIT-Professional-Inventory.git
cd SnipeIT-Professional-Inventory
code workspace.code-workspace
```

**Code quality**
- PSScriptAnalyzer integration
- Automated tests available
- Standardized code formatting
- Documentation required

### Roadmap

**Version 2.3.0 (planned)**
- Active Directory integration
- Web-based dashboard  
- Automatic updates
- Multi-tenant support
- REST API for external integration

**Version 3.0.0 (future)**
- Cross-platform support (Linux/macOS)
- Container-based deployment
- Machine learning for asset predictions
- Extended reporting features

## 📄 License

This project is licensed under the [MIT License](LICENSE.md).

```
MIT License

Copyright (c) 2025 Henrique Sebastiao

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

## 🙏 Acknowledgments

- **Snipe-IT Community**: For the great asset management platform
- **PowerShell Team**: For the robust scripting framework  
- **VS Code Team**: For the excellent development environment
- **Community Contributors**: For feedback and improvements

---

**Developed with ❤️ for professional IT asset management**

*Last updated: August 20, 2025 | Version 2.2.0*
