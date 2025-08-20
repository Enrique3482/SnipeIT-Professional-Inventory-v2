# Quick Start Guide - SnipeIT Professional Inventory v2.2.0 (EN)

![Quick Start](https://img.shields.io/badge/Quick%20Start-v2.2.0-brightgreen.svg)
![Time to Setup](https://img.shields.io/badge/Setup%20Time-5%20minutes-blue.svg)
![Difficulty](https://img.shields.io/badge/Difficulty-Beginner-green.svg)

## 🚀 Get Started Immediately - 3 Simple Steps

### Step 1: Download and Extract (1 minute)
```bash
# Download repository
git clone https://github.com/Enrique3482/SnipeIT-Professional-Inventory.git

# OR: Download ZIP file and extract
# Copy files to desired directory (e.g. C:\Scripts\SnipeIT)
```

### Step 2: Adjust Configuration (2 minutes)
```powershell
# Edit SnipeConfig.json with your data
notepad SnipeConfig.json
```

**At minimum, adjust these values:**
```json
{
  "Snipe": {
    "Url": "http://YOUR-SNIPEIT-SERVER/api/v1",
    "Token": "YOUR-API-TOKEN-HERE",
    "StandardCompanyName": "Your Company Ltd"
  }
}
```

### Step 3: Start First Test (2 minutes)
```bash
# Simply double-click:
Test-Modus.bat
```

**🎉 Done! That's it!**

---

## 🎯 The 3 Start Methods Overview

| Method | Target Audience | Difficulty | Time |
|--------|----------------|------------|------|
| **🖱️ Batch Files** | End Users | ⭐ Very Easy | 30 seconds |
| **💻 PowerShell** | Power Users | ⭐⭐ Easy | 1 minute |
| **🔧 VS Code** | Developers | ⭐⭐⭐ Medium | 2 minutes |

---

## 🖱️ Method 1: One-Click for Everyone

### Available Batch Files

**🧪 Test-Modus.bat**
- ✅ **100% safe** - No real changes
- ✅ Complete simulation
- ✅ Ideal for testing and learning
- 🎯 **Just double-click!**

**🚀 Produktions-Modus.bat**
- ⚠️ **Live system** - Real API calls
- ✅ Creates/updates assets
- ✅ Security confirmation required
- 🎯 **Only use after successful test!**

**💬 Interaktiv-Starten.bat**
- ✅ Guided menu
- ✅ Integrated help
- ✅ Mode selection in dialog
- 🎯 **Perfect for beginners!**

### What happens on first start?

1. **Automatic checks**
   - PowerShell version
   - Execution policy (automatically adjusted)
   - Network connection

2. **Security confirmation**
   ```
   ⚠️  IMPORTANT: You are starting SnipeIT Professional Inventory
   
   Test Mode: [SAFE] No real API calls
   Production Mode: [LIVE] Real changes to Snipe-IT
   
   Do you want to continue? (Y/N):
   ```

3. **Execution**
   - Colorful progress display
   - Live status updates  
   - Automatic error handling

---

## 💻 Method 2: PowerShell for Power Users

### Intelligent Starter
```powershell
# Interactive menu with mode selection
.\Start-SnipeInventory.ps1
```

**The menu shows:**
```
+=================================================================+
|         SNIPE-IT PROFESSIONAL INVENTORY STARTER                |
|                    Interactive Mode v2.2.0                     |
+=================================================================+

Select desired mode:

[1] 🧪 Test Mode (SAFE)
    ➤ Simulation without real API calls
    ➤ Ideal for testing and validation

[2] 🚀 Production Mode (LIVE)  
    ➤ Real API calls to Snipe-IT
    ➤ Creates/updates assets

[3] 💬 Interactive Mode
    ➤ Step-by-step guidance
    ➤ With explanations and help

[4] 📊 Advanced Options
    ➤ Simulated hardware
    ➤ Verbose logging
    ➤ Custom parameters

[0] ❌ Exit

Your choice (0-4):
```

### Direct Parameter Usage
```powershell
# Show all available parameters
Get-Help .\SnipeIT-Professional-Inventory.ps1 -Detailed

# Test mode with verbose logging
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging

# Production mode for specific customer
.\SnipeIT-Professional-Inventory.ps1 -CustomerName "ACME Corp"

# With simulated hardware (for demos)
.\SnipeIT-Professional-Inventory.ps1 -TestMode -SimulateHardware
```

---

## 🔧 Method 3: VS Code for Developers

### Open Workspace
```bash
# Start VS Code with complete workspace
code workspace.code-workspace
```

### First Steps in VS Code

1. **Install extensions** (automatically suggested)
   - PowerShell Extension
   - GitLens (for Git integration)
   - Error Lens (for better error display)

2. **Use integrated tasks**
   - `Ctrl+Shift+P` → "Tasks: Run Task"
   - Select from available modes:
     - 🧪 Test Mode (Safe)
     - 🚀 Production Mode
     - 💬 Interactive Mode
     - 📊 Code Analysis

3. **Enable debugging**
   - Set breakpoints (click left of line number)
   - `F5` to start debugging
   - Monitor variables in real-time

### VS Code Features in Detail

**IntelliSense (Code Completion)**
```powershell
# Suggestions appear automatically while typing
$system  # → IntelliSense shows available properties
```

**Live Error Checking**
```powershell
# Syntax errors are immediately underlined in red
$invalidVariable =   # ← Error shown immediately
```

**Integrated Terminal**
```powershell
# Terminal directly in VS Code
PS C:\Scripts\SnipeIT> .\Start-SnipeInventory.ps1
```

---

## ⚙️ Configuration - The Minimum

### SnipeConfig.json - Only 3 Values to Change!

```json
{
  "Snipe": {
    "Url": "http://snipeit.yourcompany.com/api/v1",     ← YOUR SNIPE-IT SERVER
    "Token": "YOUR_API_TOKEN_HERE...",          ← YOUR API TOKEN  
    "StandardCompanyName": "Your Company Ltd"          ← YOUR COMPANY NAME
  }
}
```

### Where do I find my Snipe-IT data?

**1. Create API Token**
```
Snipe-IT → Settings → API → Create New Token
↓
Permission: [All] or [Read/Write for Assets]
↓
Copy token and paste into SnipeConfig.json
```

**2. Determine Server URL**
```
Your Snipe-IT URL: http://snipeit.yourcompany.com
API URL: http://snipeit.yourcompany.com/api/v1
                                       ^^^^^^^^
                                       Important: append /api/v1!
```

**3. Set Company Name**
```
The name under which assets will be created in Snipe-IT
Examples:
- "ACME Corp"
- "Smith IT Solutions" 
- "Main Office Berlin"
```

---

## 🧪 First Test - Step by Step

### Test Run (recommended for initial configuration)

1. **Start Test Mode**
   ```bash
   # Double-click:
   Test-Modus.bat
   ```

2. **What you will see:**
   ```
   +=================================================================+
   |         SNIPE-IT PROFESSIONAL INVENTORY SYSTEM                 |
   |                    Professional Edition                         |
   +=================================================================+
   
   Version: 2.2.0
   Client: Your Company Ltd
   Mode: TEST MODE
   
   [INFO] Loading configuration...
   [SUCCESS] Configuration loaded from: .\SnipeConfig.json
   [INFO] Initializing custom field management...
   [SUCCESS] Custom field management initialized successfully
   [INFO] Hardware Detection - Collecting system information
   ```

3. **Successful test shows:**
   ```
   +- SYSTEM SUMMARY -----------------------------------------------+
   | Computer: DESKTOP-ABC123
   | Hardware: Dell OptiPlex 7090
   | Serial: ABC123XYZ
   | Type: Desktop
   | CPU: Intel Core i7-10700 (8 cores, 16 threads)
   | RAM: 16.0 GB
   | OS: Windows 11 Pro Build 22000
   +----------------------------------------------------------------+
   
   +- INVENTORY RESULTS --------------------------------------------+
   | Computer Asset: [OK] Synchronized
   | Custom Fields: [OK] Updated (23 fields)
   +----------------------------------------------------------------+
   
   +=================================================================+
   |           INVENTORY COMPLETED SUCCESSFULLY                     |
   |                    Professional Signature                      |
   +=================================================================+
   ```

4. **In case of problems:**
   ```
   [ERROR] API Authentication failed - check your API token
   [WARN] Configuration file not found, creating default configuration
   [ERROR] Failed to connect to: http://your-server/api/v1
   ```
   → **Solution**: Check SnipeConfig.json values

---

## 🚀 Production Start After Successful Test

### If test was successful:

1. **Start Production Mode**
   ```bash
   # Double-click:
   Produktions-Modus.bat
   ```

2. **Security Confirmation**
   ```
   ⚠️  PRODUCTION MODE CONFIRMATION
   
   You are starting SnipeIT Professional Inventory System in LIVE MODE.
   
   This means:
   ✓ Real API calls to your Snipe-IT server
   ✓ Assets will be created or updated
   ✓ Custom fields will be automatically created
   ✓ Checkout status will be managed
   
   Server: http://snipeit.yourcompany.com/api/v1
   Company: Your Company Ltd
   
   Do you want to continue? (Y/N):
   ```

3. **Monitor first execution**
   - Watch live output
   - Check result in Snipe-IT
   - Review log files

4. **Check result in Snipe-IT**
   ```
   Snipe-IT → Assets → Hardware
   ↓
   New computer should appear with:
   ✓ Correct hardware data
   ✓ All custom fields populated
   ✓ Status "Deployable" or "In Use"
   ```

---

## 📊 What Happens During Execution?

### Hardware Detection (10-15 seconds)
```
[INFO] Hardware Detection - Basic system information
[INFO] Hardware Detection - CPU information  
[INFO] Hardware Detection - Memory information
[INFO] Hardware Detection - Storage information
[INFO] Hardware Detection - Network information
[SUCCESS] Detected RAM: 16.0 GB (2 modules)
[SUCCESS] Detected storage: 512.0 GB SSD, 1000.0 GB HDD
```

### API Synchronization (5-10 seconds)
```
[INFO] Syncing computer asset: DESKTOP-ABC123
[SUCCESS] Using existing company: Your Company Ltd (ID: 1)
[SUCCESS] Created new category: Desktop (ID: 5)
[SUCCESS] Updated computer asset: DESKTOP-ABC123 (ID: 42)
```

### Custom Fields (3-5 seconds)
```
[SUCCESS] Found existing field: MacAddress (ID: 12)
[SUCCESS] Created field: ProcessorInfo (ID: 24)
[SUCCESS] Associated field ID 24 with fieldset ID 2
```

### Completion
```
+- INVENTORY RESULTS --------------------------------------------+
| Computer Asset: [OK] Synchronized  
| Custom Fields: [OK] Updated (23 fields)
+----------------------------------------------------------------+

View in Snipe-IT: http://snipeit.yourcompany.com/hardware
```

---

## 🔍 Troubleshooting - Common Cases

### Problem 1: "PowerShell Execution Policy Error"
```
Error: Execution of scripts is disabled on this system.
```
**Solution:** Use batch files (solve this automatically) or:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Problem 2: "API Authentication failed"
```
[ERROR] API Authentication failed - check your API token
```
**Solution:**
1. Check Snipe-IT token (expired?)
2. Check token permission (read/write assets?)
3. URL correct? (with /api/v1 at the end?)

### Problem 3: "Cannot connect to server"
```
[ERROR] Failed to connect to: http://your-server/api/v1
```
**Solution:**
1. Server reachable? `ping your-server`
2. Firewall/proxy blocking?
3. URL spelled correctly?

### Problem 4: "Custom Fields not created"
```
[WARN] Failed to create field: ProcessorInfo
```
**Solution:**
1. Token has custom field permission?
2. Test mode for diagnosis: `.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging`

---

## 📁 Automation - Regular Execution

### Windows Task Scheduler
```powershell
# Create task for daily execution at 9:00 AM
schtasks /create /tn "SnipeIT Inventory" /tr "C:\Scripts\SnipeIT\Produktions-Modus.bat" /sc daily /st 09:00
```

### PowerShell Scheduled Job
```powershell
$trigger = New-JobTrigger -Daily -At "9:00 AM"
$scriptPath = "C:\Scripts\SnipeIT\SnipeIT-Professional-Inventory.ps1"
Register-ScheduledJob -Name "SnipeIT-Inventory" -ScriptBlock { 
    & $scriptPath -CustomerName "Your Company Ltd" 
} -Trigger $trigger
```

### Logon Script (GPO)
```batch
REM As logon script in Group Policy
REM Runs on every user login
cd /d "\\server\share\SnipeIT"
Test-Modus.bat
```

---

## 🎯 Next Steps After Quick Start

### 1. Make Customizations
- **Custom Field Mapping** in SnipeConfig.json
- **Company-specific categories** definition
- **Maintenance intervals** configuration

### 2. Use Advanced Features
- **VS Code Workspace** for development
- **Simulated hardware** for demos
- **Automatic scheduling** setup

### 3. Set Up Monitoring
- **Log files** regular review
- **Performance metrics** monitoring
- **Error alerts** configuration

### 4. Team Integration
- **Git repository** for version control
- **Documentation** for the team
- **Training** for end users

---

## 📞 Support and Help

### Documentation
- **README-EN.md**: Complete English documentation
- **CHANGELOG-v2.2.0-EN.md**: All new features
- **GitHub Wiki**: Extended guides

### Community
- **GitHub Issues**: [Report problems](https://github.com/Enrique3482/SnipeIT-Professional-Inventory/issues)
- **Discussions**: Questions and exchange
- **Pull Requests**: Contribute your improvements

### Direct Support
```powershell
# Collect debug information
.\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging > debug-output.txt

# Keep log files ready for support
Get-Content "C:\ProgramData\SnipeIT\Inventory\SnipeIT-Inventory.log"
```

---

**✅ Quick Start Complete!**

*You are now ready to use the SnipeIT Professional Inventory System productively.*

**🎯 Next Step:** Check out the complete [README-EN.md](README-EN.md) for advanced features!
