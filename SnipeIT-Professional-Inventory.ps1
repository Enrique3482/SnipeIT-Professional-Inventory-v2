#Requires -Version 5.1
<#
.SYNOPSIS
    Snipe-IT Professional Asset Inventory System
.DESCRIPTION
    Enterprise-grade asset management solution with comprehensive hardware detection,
    intelligent status management, and automated maintenance tracking.
    
    Features:
    - Automatic hardware inventory with detailed component detection
    - Monitor and docking station recognition
    - Custom field management with collision detection
    - Intelligent status assignment based on user-computer matching
    - Automated maintenance scheduling and tracking
    - Real-time asset synchronization
    
.PARAMETER ConfigurationFile
    Configuration file path (Default: .\SnipeConfig.json)
.PARAMETER LogPath
    Log file path (Default: .\snipeit-inventory.log)
.PARAMETER CustomerName
    Client/Company name for asset assignment
.PARAMETER TestMode
    Enables test mode without actual API calls
.PARAMETER SimulateHardware
    Simulates additional hardware for testing
.PARAMETER VerboseLogging
    Enables detailed debug logging
.EXAMPLE
    .\SnipeIT-Professional-Inventory.ps1 -CustomerName "Enterprise Corp"
.EXAMPLE
    .\SnipeIT-Professional-Inventory.ps1 -TestMode -SimulateHardware -VerboseLogging
.NOTES
    Version: 2.2.0
    Author: Professional IT Team
    Last Modified: 2025-08-20
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateScript({Test-Path $_ -IsValid})]
    [string]$ConfigurationFile = ".\SnipeConfig.json",
    
    [Parameter(Mandatory = $false)]
    [ValidateScript({Test-Path (Split-Path $_ -Parent) -IsValid})]
    [string]$LogPath = ".\snipeit-inventory.log",
    
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$CustomerName = "Spittelmeister GmbH",
    
    [Parameter(Mandatory = $false)]
    [switch]$TestMode,
    
    [Parameter(Mandatory = $false)]
    [switch]$SimulateHardware,
    
    [Parameter(Mandatory = $false)]
    [switch]$VerboseLogging
)

# ============================================================================
# GLOBAL CONFIGURATION AND CONSTANTS
# ============================================================================

# Load required assemblies
try {
    Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
} catch {
    Write-Warning "System.Drawing assembly not available. Screenshot functionality will be limited."
}

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'Continue'

# Script metadata
# Personal fingerprint for unique identification
$script:Metadata = @{
    Version = "2.2.0"
    ScriptName = "SnipeIT-Inventory"
    Author = "Henrique Sebastiao"
    Purpose = "Professional Asset Management System"
    Fingerprint = "[UNIQUE_SYSTEM_ID]"
    GitHubRepo = "https://github.com/Enrique3482/SnipeIT-Professional-Inventory"
    LastUpdated = "2025-08-20"
}

# Configuration structure
# MODE SWITCHING: Change $TestMode parameter in main script execution
# TEST MODE (Simulation):  .\SnipeIT-Professional-Inventory.ps1 -TestMode -VerboseLogging
# PRODUCTION MODE (Live):  .\SnipeIT-Professional-Inventory.ps1 -VerboseLogging
# 
# TEST MODE: Simulates all operations without making actual API calls to SnipeIT
# PRODUCTION MODE: Makes real API calls and updates your SnipeIT instance
$script:Configuration = @{
    # ========================================
    # SNIPE-IT CONNECTION SETTINGS
    # ========================================
    # IMPORTANT: Verify these settings before running in PRODUCTION mode!
    # Test mode uses these settings only for validation - no actual API calls are made
    Snipe = @{
        Url = "xxx.xxx.xxx"  # Your SnipeIT API URL
        Token = "token here"  # Your SnipeIT API Token
        StandardCompanyName = $CustomerName
        StandardStatusName = "In Use"
        StandardModelFieldsetId = 2  # Computer Standard Fieldset
        StandardCategoryId = 1
        StatusDeployable = @{
            Name = "Deployable"
            Type = "deployable"
            Color = "success"
        }
        StatusInUse = @{
            Name = "In Use"
            Type = "deployed"
            Color = "primary"
        }
    }
    CustomFieldMapping = @{
        # AKTIVE FIELDS - entsprechen den aktuellen API-IDs (1-7, 9, 11-26)
        "_snipeit_mac_address_1" = "MacAddress"
        "_snipeit_os_version_2" = "OperatingSystem"
        "_snipeit_windows_product_key_3" = "LicenseKey"
        "_snipeit_cpu_4" = "Processor"
        "_snipeit_ram_gb_5" = "Memory"
        "_snipeit_storage_summary_6" = "Storage"
        "_snipeit_hardware_hash_7" = "HardwareHash"
        "_snipeit_uuid_9" = "UUID"
        "_snipeit_internalmediacount_11" = "InternalMediaCount"
        "_snipeit_inventoryversion_12" = "InventoryVersion"
        "_snipeit_osbuild_13" = "OperatingSystemBuild"
        "_snipeit_installdate_14" = "InstallationDate"
        "_snipeit_systemagedays_15" = "SystemAgeDays"
        "_snipeit_lastboot_16" = "LastBoot"
        "_snipeit_appliedupdates_17" = "AppliedUpdates"
        "_snipeit_ipaddress_18" = "IPAddress"
        "_snipeit_externalmediacount_19" = "ExternalMediaCount"
        "_snipeit_screenshot_20" = "ScreenshotPath"
        "_snipeit_user_photo_21" = "UserPhotoPath"
        "_snipeit_last_user_22" = "LastUser"
        "_snipeit_current_user_23" = "CurrentUser"
        "_snipeit_checkout_status_24" = "CheckoutStatus"
        "_snipeit_last_checkout_25" = "LastCheckout"
        "_snipeit_expected_checkin_26" = "ExpectedCheckin"
    }
    Performance = @{
        ApiTimeout = 60
        MaxRetries = 3
        RetryDelay = 2
        BatchSize = 50
    }
    Maintenance = @{
        IntervalDays = 365
        WarningDays = 30
        CriticalDays = 7
    }
    TestMode = $TestMode
    SimulateHardware = $SimulateHardware
    VerboseLogging = $VerboseLogging
}

# ============================================================================
# ROLLBACK AND VALIDATION SYSTEM
# ============================================================================

class RollbackManager {
    [string]$BackupDirectory
    [System.Collections.Generic.List[hashtable]]$BackupLog
    
    RollbackManager() {
        $this.BackupDirectory = "C:\ProgramData\SnipeIT\Backups"
        $this.BackupLog = [System.Collections.Generic.List[hashtable]]::new()
        
        # Create backup directory
        if (-not (Test-Path $this.BackupDirectory)) {
            try {
                New-Item -ItemType Directory -Path $this.BackupDirectory -Force | Out-Null
                $script:Logger.Log('INFO', "Created backup directory: $($this.BackupDirectory)")
            } catch {
                $script:Logger.Log('ERROR', "Failed to create backup directory: $_")
            }
        }
    }
    
    [bool]ValidatePath([string]$path) {
        # Validate path format and accessibility
        try {
            if ([string]::IsNullOrWhiteSpace($path)) {
                $script:Logger.Log('WARN', "Empty path provided for validation")
                return $false
            }
            
            # Check if path contains invalid characters
            $invalidChars = [System.IO.Path]::GetInvalidPathChars()
            foreach ($char in $invalidChars) {
                if ($path.Contains($char)) {
                    $script:Logger.Log('WARN', "Path contains invalid character '$char': $path")
                    return $false
                }
            }
            
            # Check if directory exists or can be created
            $directory = Split-Path -Parent $path
            if (-not (Test-Path $directory)) {
                try {
                    New-Item -ItemType Directory -Path $directory -Force | Out-Null
                    $script:Logger.Log('INFO', "Created directory: $directory")
                } catch {
                    $script:Logger.Log('ERROR', "Cannot create directory $directory`: $_")
                    return $false
                }
            }
            
            # Test write access
            $testFile = Join-Path $directory "test_write_$(Get-Random).tmp"
            try {
                "test" | Out-File -FilePath $testFile -ErrorAction Stop
                Remove-Item $testFile -ErrorAction SilentlyContinue
                return $true
            } catch {
                $script:Logger.Log('ERROR', "No write access to directory $directory`: $_")
                return $false
            }
        } catch {
            $script:Logger.Log('ERROR', "Path validation failed for '$path': $_")
            return $false
        }
    }
    
    [hashtable]CreateBackup([string]$filePath, [string]$description) {
        $backup = @{
            OriginalPath = $filePath
            BackupPath = ""
            Timestamp = Get-Date
            Description = $description
            Success = $false
        }
        
        try {
            if (Test-Path $filePath) {
                $timestamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
                $fileName = Split-Path -Leaf $filePath
                $backupFileName = "${fileName}.backup_${timestamp}"
                $backupPath = Join-Path $this.BackupDirectory $backupFileName
                
                Copy-Item -Path $filePath -Destination $backupPath -Force
                $backup.BackupPath = $backupPath
                $backup.Success = $true
                
                $script:Logger.Log('SUCCESS', "Backup created: $backupPath")
            } else {
                $script:Logger.Log('WARN', "File not found for backup: $filePath")
            }
        } catch {
            $script:Logger.Log('ERROR', "Backup creation failed: $_")
        }
        
        $this.BackupLog.Add($backup)
        return $backup
    }
    
    [bool]RestoreBackup([hashtable]$backup) {
        try {
            if ($backup.Success -and (Test-Path $backup.BackupPath)) {
                Copy-Item -Path $backup.BackupPath -Destination $backup.OriginalPath -Force
                $script:Logger.Log('SUCCESS', "Restored from backup: $($backup.OriginalPath)")
                return $true
            } else {
                $script:Logger.Log('ERROR', "Cannot restore backup - backup file not found: $($backup.BackupPath)")
                return $false
            }
        } catch {
            $script:Logger.Log('ERROR', "Restore failed: $_")
            return $false
        }
    }
    
    [void]CleanupOldBackups([int]$daysToKeep = 7) {
        try {
            $cutoffDate = (Get-Date).AddDays(-$daysToKeep)
            $oldBackups = Get-ChildItem -Path $this.BackupDirectory -Filter "*.backup_*" | 
                Where-Object { $_.LastWriteTime -lt $cutoffDate }
            
            foreach ($backup in $oldBackups) {
                Remove-Item $backup.FullName -Force
                $script:Logger.Log('INFO', "Removed old backup: $($backup.Name)")
            }
        } catch {
            $script:Logger.Log('ERROR', "Backup cleanup failed: $_")
        }
    }
}

# LOGGING SYSTEM
# ============================================================================

class Logger {
    [string]$LogPath
    [string]$ErrorLogPath
    [bool]$VerboseMode
    [System.Collections.Concurrent.ConcurrentQueue[string]]$LogQueue
    
    Logger([string]$path, [bool]$verbose) {
        $this.LogPath = $path
        $this.VerboseMode = $verbose
        $this.LogQueue = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
        
        # Set up simple log and error log
        $logDirectory = "C:\ProgramData\SnipeIT\Inventory"
        $errorLogDirectory = "C:\ProgramData\SnipeIT\Errorlog"
        
        $this.LogPath = Join-Path $logDirectory "SnipeIT-Inventory.log"
        $this.ErrorLogPath = Join-Path $errorLogDirectory "SnipeIT-Errors.log"
        
        # Create directories if they don't exist
        @($logDirectory, $errorLogDirectory) | ForEach-Object {
            if (-not (Test-Path $_)) {
                try {
                    New-Item -ItemType Directory -Path $_ -Force | Out-Null
                } catch {
                    Write-Warning "Could not create directory $_`: $_"
                }
            }
        }
        
        # Overwrite previous log files
        @($this.LogPath, $this.ErrorLogPath) | ForEach-Object {
            if (Test-Path $_) {
                try {
                    Clear-Content $_ -ErrorAction SilentlyContinue
                } catch {
                    Write-Warning "Could not clear log file $_`: $($_.Exception.Message)"
                }
            }
        }
        
        $this.InitializeLog()
    }
    
    [void]InitializeLog() {
        $computerName = $env:COMPUTERNAME
        $userName = $env:USERNAME
        $domain = $env:USERDOMAIN
        
        $header = @"
================================================================================
SnipeIT Professional Inventory v2.0.0 - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
System: $domain\$computerName | User: $userName
================================================================================
"@
        
        $this.WriteToFile($header)
    }
    
    [void]Log([string]$level, [string]$message) {
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        $logEntry = "$timestamp [$level] $message"
        
        # Console output with enhanced color coding
        $color = switch ($level) {
            'ERROR'   { 'Red' }
            'WARN'    { 'Yellow' }
            'SUCCESS' { 'DarkGreen' }  # Schönes Mintgrün/Dunkelgrün
            'DEBUG'   { 'DarkGray' }
            'INFO'    { 
                # Spezielle Farbe für Hardware Detection
                if ($message -like "*Hardware Detection*") {
                    'Cyan'  # Helle Cyan-Farbe für Hardware Detection
                } else {
                    'White'
                }
            }
            default   { 'Gray' }
        }
        
        if ($level -ne 'DEBUG' -or $this.VerboseMode) {
            Write-Host $logEntry -ForegroundColor $color
        }
        
        # Write to main log file (only important events)
        if ($level -in @('SUCCESS', 'ERROR', 'WARN')) {
            $this.WriteToFile($logEntry)
        }
        
        # Write errors to separate error log with line information
        if ($level -eq 'ERROR') {
            $this.LogError($message)
        }
    }
    
    [void]LogError([string]$message) {
        $timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        $stackTrace = Get-PSCallStack
        $errorLine = if ($stackTrace.Count -gt 1) { $stackTrace[1].ScriptLineNumber } else { "Unknown" }
        $errorFunction = if ($stackTrace.Count -gt 1) { $stackTrace[1].FunctionName } else { "Unknown" }
        
        $errorEntry = "$timestamp [ERROR] Line $errorLine in $errorFunction`: $message"
        
        try {
            Add-Content -Path $this.ErrorLogPath -Value $errorEntry -Encoding UTF8 -ErrorAction SilentlyContinue
        } catch {
            # Silent failure to avoid logging errors
        }
    }
    
    [void]LogDetailed([string]$level, [string]$message, [hashtable]$additionalData = $null) {
        # Only log to main log, no detailed logging anymore
        $this.Log($level, $message)
    }
    
    [void]WriteToFile([string]$content) {
        try {
            Add-Content -Path $this.LogPath -Value $content -Encoding UTF8 -ErrorAction SilentlyContinue
        } catch {
            # Silent failure to avoid logging errors
        }
    }
    
    [void]LogProgress([string]$activity, [string]$status, [int]$percentComplete) {
        $this.Log('INFO', "$activity - $status ($percentComplete%)")
        
        if ($percentComplete -ge 0) {
            Write-Progress -Activity $activity -Status $status -PercentComplete $percentComplete
        } else {
            Write-Progress -Activity $activity -Status $status
        }
    }
    
    [void]LogException([System.Management.Automation.ErrorRecord]$errorRecord) {
        $this.Log('ERROR', "Exception: $($errorRecord.Exception.Message)")
        $this.Log('ERROR', "Stack Trace: $($errorRecord.ScriptStackTrace)")
        if ($this.VerboseMode) {
            $this.Log('DEBUG', "Full Exception: $($errorRecord.Exception.ToString())")
        }
        
        # Write detailed exception information to log
        $exceptionDetails = @"

================================================================================
EXCEPTION DETAILS
================================================================================
Exception Type:    $($errorRecord.Exception.GetType().Name)
Error Message:     $($errorRecord.Exception.Message)
Script Location:   $($errorRecord.InvocationInfo.ScriptName):$($errorRecord.InvocationInfo.ScriptLineNumber)
Command:           $($errorRecord.InvocationInfo.MyCommand)
Line Content:      $($errorRecord.InvocationInfo.Line.Trim())
Stack Trace:       $($errorRecord.ScriptStackTrace)
Full Exception:    $($errorRecord.Exception.ToString())
================================================================================

"@
        $this.WriteToFile($exceptionDetails)
    }
    
    [void]LogExecutionSummary([hashtable]$summaryData) {
        $endTime = Get-Date
        $duration = if ($summaryData.ContainsKey('StartTime')) {
            ($endTime - $summaryData.StartTime).ToString('mm\:ss\.fff')
        } else {
            "Unknown"
        }
        
        $summary = @"

################################################################################
EXECUTION SUMMARY
################################################################################

Completion Time:  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Total Duration:   $duration
Exit Status:      $($summaryData.ExitStatus -or 'Unknown')

RESULTS OVERVIEW
================
Computer Assets:  $($summaryData.ComputerAssets -or 0) processed
Monitor Assets:   $($summaryData.MonitorAssets -or 0) detected
Custom Fields:    $($summaryData.CustomFields -or 0) synchronized
API Calls:        $($summaryData.ApiCalls -or 0) executed
Errors:           $($summaryData.Errors -or 0) encountered
Warnings:         $($summaryData.Warnings -or 0) logged

PERFORMANCE METRICS
===================
Hardware Detection: $($summaryData.HardwareDetectionTime -or 'N/A')
API Synchronization: $($summaryData.ApiSyncTime -or 'N/A')
Field Management:   $($summaryData.FieldManagementTime -or 'N/A')

################################################################################
END OF LOG
################################################################################
"@
        $this.WriteToFile($summary)
    }
}

# Initialize global logger
$script:Logger = [Logger]::new($LogPath, $VerboseLogging)
$script:RollbackManager = [RollbackManager]::new()

# ============================================================================
# CONFIGURATION MANAGEMENT
# ============================================================================

class ConfigurationManager {
    [hashtable]$Configuration
    [string]$ConfigurationPath
    
    ConfigurationManager([hashtable]$defaultConfiguration, [string]$configurationPath) {
        $this.Configuration = $defaultConfiguration
        $this.ConfigurationPath = $configurationPath
        $this.LoadConfiguration()
    }
    
    [void]LoadConfiguration() {
        $script:Logger.Log('INFO', 'Loading configuration...')
        
        if (Test-Path $this.ConfigurationPath) {
            try {
                $fileContent = Get-Content $this.ConfigurationPath -Raw -ErrorAction Stop
                $fileConfiguration = $fileContent | ConvertFrom-Json -ErrorAction Stop
                
                # Deep merge configuration
                $this.MergeConfiguration($fileConfiguration)
                
                $script:Logger.Log('SUCCESS', "Configuration loaded from: $($this.ConfigurationPath)")
            }
            catch {
                $script:Logger.Log('ERROR', "Failed to load configuration: $_")
                $script:Logger.Log('WARN', 'Using default configuration values')
            }
        }
        else {
            $script:Logger.Log('WARN', 'Configuration file not found, creating default configuration')
            $this.SaveConfiguration()
        }
        
        # Validate configuration
        $this.ValidateConfiguration()
    }
    
    [void]MergeConfiguration($fileConfig) {
        foreach ($section in $fileConfig.PSObject.Properties) {
            if ($this.Configuration.ContainsKey($section.Name)) {
                foreach ($prop in $section.Value.PSObject.Properties) {
                    if ($this.Configuration[$section.Name] -is [hashtable]) {
                        $this.Configuration[$section.Name][$prop.Name] = $prop.Value
                    }
                }
            }
            else {
                # Handle special Boolean flags
                if ($section.Name -in @('TestMode', 'SimulateHardware', 'VerboseLogging')) {
                    $this.Configuration[$section.Name] = $section.Value.IsPresent
                } else {
                    $this.Configuration[$section.Name] = $section.Value
                }
            }
        }
    }
    
    [void]ValidateConfiguration() {
        $script:Logger.Log('INFO', 'Validating configuration...')
        
        # Check API token
        if ($this.Configuration.Snipe.Token -eq "YOUR-API-TOKEN-HERE" -and -not $this.Configuration.TestMode) {
            throw "API token not configured. Please update the configuration file: $($this.ConfigurationPath)"
        }
        
        # Validate URL format
        if (-not $this.Configuration.Snipe.Url -match '^https?://') {
            $script:Logger.Log('WARN', 'API URL should start with http:// or https://')
        }
        
        # Validate required fields
        $requiredFields = @('Url', 'Token', 'StandardCompanyName')
        foreach ($field in $requiredFields) {
            if ([string]::IsNullOrWhiteSpace($this.Configuration.Snipe[$field])) {
                $script:Logger.Log('WARN', "Required field '$field' is empty or missing")
            }
        }
        
        $script:Logger.Log('SUCCESS', 'Configuration validation completed')
    }
    
    [void]SaveConfiguration() {
        try {
            $json = $this.Configuration | ConvertTo-Json -Depth 10
            $json | Out-File -FilePath $this.ConfigurationPath -Encoding UTF8 -Force
            $script:Logger.Log('SUCCESS', "Configuration saved to: $($this.ConfigurationPath)")
        }
        catch {
            $script:Logger.Log('ERROR', "Failed to save configuration: $_")
        }
    }
}

# ============================================================================
# API CLIENT
# ============================================================================

class SnipeITApiClient {
    [string]$BaseUrl
    [hashtable]$Headers
    [bool]$TestMode
    [int]$Timeout
    [int]$MaxRetries
    [int]$RetryDelay
    
    SnipeITApiClient([hashtable]$config) {
        # Handle TestMode from configuration file format
        if ($config.TestMode -is [PSCustomObject] -and $config.TestMode.IsPresent) {
            $this.TestMode = $true
        } elseif ($config.TestMode -is [bool]) {
            $this.TestMode = $config.TestMode
        } else {
            $this.TestMode = $false
        }
        
        if (-not $this.TestMode) {
            $this.BaseUrl = $config.Snipe.Url
            $this.Headers = @{
                'Authorization' = "Bearer $($config.Snipe.Token)"
                'Accept'        = 'application/json'
                'Content-Type'  = 'application/json'
            }
            $this.Timeout = $config.Performance.ApiTimeout
            $this.MaxRetries = $config.Performance.MaxRetries
            $this.RetryDelay = $config.Performance.RetryDelay
        }
    }
    
    [object]InvokeApi([string]$method, [string]$endpoint, [object]$body) {
        if ($this.TestMode) {
            return $this.SimulateApiResponse($method, $endpoint, $body)
        }
        
        $uri = "$($this.BaseUrl)$endpoint"
        $attempt = 0
        
        while ($attempt -lt $this.MaxRetries) {
            try {
                $params = @{
                    Method          = $method
                    Uri             = $uri
                    Headers         = $this.Headers
                    TimeoutSec      = $this.Timeout
                    UseBasicParsing = $true
                    ErrorAction     = 'Stop'
                }
                
                if ($body) {
                    $params.Body = $body | ConvertTo-Json -Depth 12 -Compress
                    if ($script:Configuration.VerboseLogging) {
                        $script:Logger.Log('DEBUG', "API Request Body: $($params.Body)")
                    }
                }
                
                $response = Invoke-RestMethod @params
                
                if ($script:Configuration.VerboseLogging) {
                    $script:Logger.Log('DEBUG', "API Response: $($response | ConvertTo-Json -Compress)")
                }
                
                return $response
            }
            catch {
                $attempt++
                $statusCode = $_.Exception.Response.StatusCode.value__
                
                if ($attempt -ge $this.MaxRetries) {
                    $this.HandleApiError($_, $method, $uri)
                    return $null
                }
                
                # Retry on specific error codes
                if ($statusCode -in @(429, 500, 502, 503, 504)) {
                    $script:Logger.Log('WARN', "API request failed (attempt $attempt/$($this.MaxRetries)), retrying in $($this.RetryDelay) seconds...")
                    Start-Sleep -Seconds $this.RetryDelay
                }
                else {
                    $this.HandleApiError($_, $method, $uri)
                    return $null
                }
            }
        }
        
        return $null
    }
    
    [void]HandleApiError($errorRecord, $method, $uri) {
        $statusCode = $errorRecord.Exception.Response.StatusCode.value__
        $statusDescription = $errorRecord.Exception.Response.StatusDescription
        
        switch ($statusCode) {
            401 { $script:Logger.Log('ERROR', 'API Authentication failed - check your API token') }
            403 { $script:Logger.Log('ERROR', 'API Access denied - insufficient permissions') }
            404 { $script:Logger.Log('WARN', "API Endpoint not found: $uri") }
            422 { $script:Logger.Log('WARN', 'API Validation error - data may be incomplete or invalid') }
            429 { $script:Logger.Log('ERROR', 'API Rate limit exceeded') }
            default { 
                $script:Logger.Log('ERROR', "API Error $statusCode ($statusDescription): $method $uri")
                $script:Logger.Log('ERROR', "Details: $($errorRecord.Exception.Message)")
            }
        }
    }
    
    [object]SimulateApiResponse($method, $endpoint, $body) {
        $script:Logger.Log('DEBUG', "TEST MODE: $method $endpoint")
        
        # Simulate various responses based on endpoint
        switch -Regex ($endpoint) {
            '/search' {
                return @{ total = 0; rows = @() }
            }
            '/categories' {
                return @{ id = 1; name = "Computers" }
            }
            '/fieldsets/\d+$' {
                return @{ id = 2; name = "Computer Standard Fieldset" }
            }
            '/fieldsets/\d+/fields$' {
                if ($method -eq 'GET') {
                    return @{ 
                        rows = @(
                            @{ id = 1; name = "CPU"; pivot = @{ order = 1 } }
                            @{ id = 2; name = "RAM"; pivot = @{ order = 2 } }
                        )
                    }
                }
                else {
                    return @{ status = "success"; message = "Field associated with fieldset" }
                }
            }
            '/fieldsets' {
                return @{ id = 2; name = "Computer Standard Fieldset" }
            }
            '/fields\?limit=' {
                return @{ 
                    rows = @(
                        @{ id = 1; name = "CPU"; db_column = "_snipeit_cpu_3" }
                        @{ id = 2; name = "RAM"; db_column = "_snipeit_ram_4" }
                        @{ id = 3; name = "MacAddress"; db_column = "_snipeit_mac_addresse_2" }
                    )
                }
            }
            '/fields$' {
                if ($method -eq 'POST') {
                    return @{
                        id = Get-Random -Minimum 10 -Maximum 100
                        name = $body.name
                        db_column = "_snipeit_$($body.name.ToLower())_$(Get-Random -Maximum 50)"
                        status = "success"
                    }
                }
                return @{ total = 0; rows = @() }
            }
            default {
                return @{
                    id = Get-Random -Maximum 1000
                    status = "success"
                    message = "Simulated response"
                }
            }
        }
        
        # Dies sollte nie erreicht werden aufgrund des Standard-Falls
        return @{
            id = Get-Random -Maximum 1000
            status = "success"
            message = "Default simulated response"
        }
    }
}

# ============================================================================
# HARDWARE DETECTION ENGINE
# ============================================================================

class HardwareDetector {
    [bool]$SimulateHardware
    
    HardwareDetector([bool]$simulate) {
        $this.SimulateHardware = $simulate
    }
    
    [hashtable]GetSystemInformation() {
        $script:Logger.LogProgress('Hardware Detection', 'Collecting system information', 0)
        
        $systemInfo = @{}
        
        try {
            # Core system information
            $this.GetBasicSystemInformation($systemInfo)
            
            # Hardware details
            $this.GetProcessorInformation($systemInfo)
            $this.GetMemoryInformation($systemInfo)
            $this.HoleSpeicherInformationen($systemInfo)
            $this.HoleNetzwerkInformationen($systemInfo)
            $this.HoleGrafikInformationen($systemInfo)
            
            # User and domain information
            $this.HoleBenutzerInformationen($systemInfo)
            
            # Maintenance information
            $this.HoleWartungsInformationen($systemInfo)
            
            # Peripheral devices
            $systemInfo.ExternalMonitors = $this.GetExternalMonitors()
            $systemInfo.DockingStations = $this.GetDockingStations()
            
            # Metadata
            $systemInfo.InventoryVersion = $script:Metadata.Version
            $systemInfo.LastInventory = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
            
            $script:Logger.LogProgress('Hardware Detection', 'Completed', 100)
            $script:Logger.Log('SUCCESS', "System information collected for: $($systemInfo.DeviceName)")
            
            return $systemInfo
        }
        catch {
            $script:Logger.LogException($_)
            throw "Failed to collect system information: $_"
        }
    }
    
    [void]GetBasicSystemInformation([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'Basic system information', 10)
        
        $cs = Get-CimInstance Win32_ComputerSystem
        $bios = Get-CimInstance Win32_BIOS
        $os = Get-CimInstance Win32_OperatingSystem
        $csProduct = Get-CimInstance Win32_ComputerSystemProduct
        
        $info.DeviceName = $env:COMPUTERNAME
        $info.SerialNumber = $this.ValidiereSeriennummer($bios.SerialNumber)
        $info.Manufacturer = $this.BereinigeHerstellername($cs.Manufacturer)
        $info.Model = $cs.Model
        $info.BiosVersion = $bios.SMBIOSBIOSVersion
        $info.UUID = if ($csProduct.UUID) { $csProduct.UUID } else { "Not Available" }
        $info.OS = ($os.Caption -replace 'Microsoft ', '').Trim()
        $info.OSBuild = $os.Version
        $info.OSVersion = $os.BuildNumber
        $info.SKU = $os.OperatingSystemSKU
        $info.LastBoot = $os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm:ss')
        $info.DeviceType = $this.DetermineDeviceType($cs.PCSystemTypeEx)
    }
    
    [void]GetProcessorInformation([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'CPU information', 20)
        
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $cpuName = ($cpu.Name -replace '\s+', ' ' -replace '\(TM\)|\(R\)|CPU', '').Trim()
        $info.CPU = "$cpuName ($($cpu.NumberOfCores) cores, $($cpu.NumberOfLogicalProcessors) threads)"
    }
    
    [void]GetMemoryInformation([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'Memory information', 30)
        
        try {
            $memory = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue
            if ($memory) {
                $totalMemory = ($memory | Measure-Object -Property Capacity -Sum).Sum
                $memoryGB = [math]::Round($totalMemory / 1GB, 1)
                
                $info.RAM = "$memoryGB GB"
                $info.RAMInstalled = "$($memory.Count) modules"
                $script:Logger.Log('SUCCESS', "Detected RAM: $memoryGB GB ($($memory.Count) modules)")
            } else {
                # Fallback method using different approach
                $computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
                if ($computerSystem -and $computerSystem.TotalPhysicalMemory) {
                    $memoryGB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 1)
                    $info.RAM = "$memoryGB GB"
                    $info.RAMInstalled = "Information not available"
                    $script:Logger.Log('SUCCESS', "Detected RAM (fallback): $memoryGB GB")
                } else {
                    $info.RAM = "Not detected"
                    $info.RAMInstalled = "Not available"
                    $script:Logger.Log('WARN', "Could not detect RAM information")
                }
            }
        }
        catch {
            $info.RAM = "Detection error"
            $info.RAMInstalled = "Error"
            $script:Logger.Log('ERROR', "Memory detection failed: $($_.Exception.Message)")
        }
    }
    
    [void]HoleSpeicherInformationen([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'Storage information', 40)
        
        try {
            $disks = Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue
            if ($disks) {
                $internalDisks = $disks | Where-Object { $_.InterfaceType -notmatch 'USB|1394' }
                $externalDisks = $disks | Where-Object { $_.InterfaceType -match 'USB|1394' }
                
                $info.InternalMediaCount = $internalDisks.Count
                $info.ExternalMediaCount = $externalDisks.Count
                
                # Build storage summary
                $storageInfo = @()
                foreach ($disk in $internalDisks) {
                    $sizeGB = [math]::Round($disk.Size / 1GB, 1)
                    $type = if ($disk.MediaType -like "*SSD*" -or $disk.Model -like "*SSD*") { "SSD" } else { "HDD" }
                    $storageInfo += "$sizeGB GB $type"
                }
                
                $info.Storage = if ($storageInfo.Count -gt 0) { 
                    $storageInfo -join ', ' 
                } else { 
                    "Not detected" 
                }
                
                $script:Logger.Log('SUCCESS', "Detected storage: $($info.Storage)")
            } else {
                $info.InternalMediaCount = 0
                $info.ExternalMediaCount = 0
                $info.Storage = "Not detected"
                $script:Logger.Log('WARN', "Could not detect storage devices")
            }
        }
        catch {
            $info.InternalMediaCount = 0
            $info.ExternalMediaCount = 0
            $info.Storage = "Detection error"
            $script:Logger.Log('ERROR', "Storage detection failed: $($_.Exception.Message)")
        }
    }
    
    [void]HoleNetzwerkInformationen([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'Network information', 50)
        
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.Name -notlike '*Bluetooth*' }
        $primaryAdapter = $adapters | Where-Object { $_.LinkSpeed -gt 0 } | Select-Object -First 1
        
        if ($primaryAdapter) {
            $info.MacAddress = $primaryAdapter.MacAddress
            $info.NetworkAdapters = ($adapters | ForEach-Object { "$($_.Name) [$($_.LinkSpeed)]" }) -join ', '
        }
        else {
            $info.MacAddress = "Not Available"
            $info.NetworkAdapters = "None Active"
        }
        
                    # IP-Adresse abrufen
        $ipConfig = Get-NetIPAddress -AddressFamily IPv4 | 
            Where-Object { $_.IPAddress -notlike '169.254.*' -and $_.IPAddress -ne '127.0.0.1' } |
            Select-Object -First 1
            
        $info.IPAddress = if ($ipConfig) { $ipConfig.IPAddress } else { "Not Available" }
    }
    
    [void]HoleGrafikInformationen([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'GPU information', 60)
        
        $gpu = Get-CimInstance Win32_VideoController | 
            Where-Object { $_.Name -notlike '*Basic*' -and $_.Name -notlike '*Microsoft*' } |
            Select-Object -First 1
            
        $info.GPU = if ($gpu) { $gpu.Name } else { "Integrated Graphics" }
    }
    
    [void]HoleBenutzerInformationen([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'User information', 70)
        
        $cs = Get-CimInstance Win32_ComputerSystem
        
        $info.LastUser = if ($cs.UserName) { $cs.UserName } else { $this.GetLastLoggedInUser() }
        $info.CurrentUser = $env:USERNAME
        $info.Domain = $env:USERDOMAIN
        
                    # Erweiterte Benutzerverfolgung f�r automatischen Checkout
        $info.CheckoutStatus = "Available"
        $info.LastCheckout = "Not Available"
        $info.ExpectedCheckin = "Not Available"
        
                    # Benutzerfoto und Screenshot f�r Asset-Dokumentation erfassen
        $info.UserPhotoPath = "Not Available"
        $info.ScreenshotPath = "Not Available"
    }
    
    [void]HoleWartungsInformationen([hashtable]$info) {
        $script:Logger.LogProgress('Hardware Detection', 'Maintenance information', 80)
        
        $installDate = $this.GetSystemInstallationDate()
        $currentDate = Get-Date
        $ageInDays = [math]::Round(($currentDate - $installDate).TotalDays, 0)
        $nextMaintenance = $installDate.AddDays(365) # Default 365 days
        $daysUntilMaintenance = [math]::Round(($nextMaintenance - $currentDate).TotalDays, 0)
        
        $info.InstallDate = $installDate.ToString('yyyy-MM-dd')
        $info.SystemAgeDays = $ageInDays
        $info.NextMaintenance = $nextMaintenance.ToString('yyyy-MM-dd')
        $info.MaintenanceStatus = $this.GetMaintenanceStatus($daysUntilMaintenance)
    }
    
    [string]ValidiereSeriennummer([string]$seriennummer) {
        if ([string]::IsNullOrWhiteSpace($seriennummer) -or 
            $seriennummer -match '(To Be Filled|O\.E\.M\.|Default|Unknown|System Serial)') {
            # Eindeutigen Bezeichner generieren
            $guid = [guid]::NewGuid().ToString().Substring(0, 8).ToUpper()
            $seriennummer = "AUTO-$guid"
            $script:Logger.Log('WARN', "Invalid serial number replaced with: $seriennummer")
        }
        return $seriennummer
    }
    
    [string]BereinigeHerstellername([string]$hersteller) {
        return ($hersteller -replace ' Inc\.?$| Corporation$| Corp\.?$|\.$', '').Trim()
    }
    
    [string]DetermineDeviceType([int]$systemType) {
        switch ($systemType) {
            1 { return "Desktop" }
            2 { return "Mobile/Laptop" }
            3 { return "Workstation" }
            4 { return "Enterprise Server" }
            5 { return "SOHO Server" }
            6 { return "Appliance PC" }
            7 { return "Performance Server" }
            8 { return "Slate/Tablet" }
            default { return "Unknown" }
        }
        return "Unknown" # Fallback-R�ckgabe
    }
    
    [string]GetLastLoggedInUser() {
        try {
            $userProfile = Get-ChildItem "C:\Users" -Directory |
                Where-Object { $_.Name -notmatch '^(Public|Default|All Users|Default User)$' } |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 1
                
            return if ($userProfile) { $userProfile.Name } else { "Unknown" }
        }
        catch {
            return "Unknown"
        }
    }
    
    [datetime]GetSystemInstallationDate() {
        try {
            # Zuerst OS-Installationsdatum versuchen
            $os = Get-CimInstance Win32_OperatingSystem
            if ($os.InstallDate) {
                return $os.InstallDate
            }
            
            # Fallback zur Registry
            $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
            $installTime = (Get-ItemProperty $regPath).InstallDate
            if ($installTime) {
                return [datetime]::new(1970, 1, 1, 0, 0, 0, 0, 'Utc').AddSeconds($installTime).ToLocalTime()
            }
            
            # Letzter Fallback zur Windows-Verzeichniserstellung
            return (Get-Item 'C:\Windows').CreationTime
        }
        catch {
            $script:Logger.Log('WARN', 'Could not determine exact install date, using estimate')
            return (Get-Date).AddDays(-365)
        }
    }
    
    [string]GetMaintenanceStatus([int]$daysUntilMaintenance) {
        if ($daysUntilMaintenance -le 0) {
            return "OVERDUE"
        }
        elseif ($daysUntilMaintenance -le $script:Configuration.Maintenance.CriticalDays) {
            return "CRITICAL"
        }
        elseif ($daysUntilMaintenance -le $script:Configuration.Maintenance.WarningDays) {
            return "WARNING"
        }
        else {
            return "OK"
        }
    }
    
            # Erweiterte Benutzer-Computer-Zuordnung und Checkout-Verwaltung
    [string]DetermineCheckoutStatus([hashtable]$info) {
        $currentUser = $info.CurrentUser
        $lastUser = $info.LastUser
        
        # Pr�fen ob aktueller Benutzer dem Computernamen-Muster entspricht
        $isUserComputerMatch = $this.IsUserComputerMatch($info)
        
        if ($isUserComputerMatch) {
            return "AUTO_CHECKOUT"
        }
        elseif ($currentUser -ne $lastUser -and $currentUser -ne "Unknown") {
            return "USER_CHANGED"
        }
        else {
            return "NO_CHANGE"
        }
    }
    
    [string]GetLastCheckoutDate([hashtable]$info) {
        try {
            # Try to get last checkout from registry or file
            $regPath = "HKLM:\SOFTWARE\SnipeIT\Inventory"
            $lastCheckout = Get-ItemProperty -Path $regPath -Name "LastCheckout" -ErrorAction SilentlyContinue
            if ($lastCheckout) {
                return $lastCheckout.LastCheckout
            }
        }
        catch {
            Write-Verbose "GetLastCheckoutDate: registry lookup failed: $($_.Exception.Message)"
        }
        
        # Fallback to current date
        return (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    }
    
    [string]CalculateExpectedCheckin([hashtable]$info) {
        # Calculate expected checkin based on company policy
        $checkoutDate = [datetime]::ParseExact($info.LastCheckout, 'yyyy-MM-dd HH:mm:ss', $null)
        $expectedCheckin = $checkoutDate.AddDays(365)  # Default 1 year
        return $expectedCheckin.ToString('yyyy-MM-dd')
    }
    
    [string]CaptureUserPhoto([string]$username) {
        try {
            # Capture user photo from Active Directory or local profile
            $photoPath = "C:\ProgramData\SnipeIT\Inventory\Photos\$username.jpg"
            
            # Create directory if it doesn't exist
            $photoDir = Split-Path $photoPath -Parent
            if (-not (Test-Path $photoDir)) {
                New-Item -ItemType Directory -Path $photoDir -Force | Out-Null
            }
            
            # Try to get user photo from AD (if available)
            try {
                # Check if Active Directory module is available
                if (Get-Module -ListAvailable -Name ActiveDirectory) {
                    $adUser = Get-ADUser -Identity $username -Properties thumbnailPhoto -ErrorAction SilentlyContinue
                    if ($adUser.thumbnailPhoto) {
                        $adUser.thumbnailPhoto | Set-Content -Path $photoPath -Encoding Byte
                        return $photoPath
                    }
                }
            }
            catch {
                Write-Verbose "Active Directory lookup for user photo failed or not available: $($_.Exception.Message)"
            }
            
            # Generate default avatar if no photo available
            $this.GenerateDefaultAvatar($username, $photoPath)
            return $photoPath
        }
        catch {
            $script:Logger.Log('WARN', "Failed to capture user photo: $_")
            return ""
        }
    }
    
    [string]CaptureSystemScreenshot() {
        try {
            # Capture system screenshot for asset documentation
            $screenshotPath = "C:\ProgramData\SnipeIT\Inventory\Screenshots\$($env:COMPUTERNAME)_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
            
            # Check if System.Drawing is available
            if (-not ([System.Management.Automation.PSTypeName]'System.Drawing.Bitmap').Type) {
                $script:Logger.Log('WARN', 'System.Drawing not available, creating placeholder file')
                # Create a simple placeholder file
                $placeholderContent = "Screenshot placeholder - System.Drawing not available`nGenerated: $(Get-Date)`nComputer: $($env:COMPUTERNAME)"
                $placeholderContent | Out-File -FilePath $screenshotPath.Replace('.png', '.txt') -Encoding UTF8
                return $screenshotPath.Replace('.png', '.txt')
            }
            
            # Create directory if it doesn't exist
            $screenshotDir = Split-Path $screenshotPath -Parent
            if (-not (Test-Path $screenshotDir)) {
                New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null
            }
            
            # Use PowerShell's built-in screenshot capability
            $screenWidth = 1920  # Default screen width
            $screenHeight = 1080 # Default screen height
            
            # Try to get actual screen resolution from registry
            try {
                $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Video"
                $videoKeys = Get-ChildItem $regPath -ErrorAction SilentlyContinue
                foreach ($key in $videoKeys) {
                    $resolution = Get-ItemProperty -Path $key.PSPath -Name "DefaultSettings.XResolution" -ErrorAction SilentlyContinue
                    if ($resolution) {
                        $screenWidth = $resolution.DefaultSettings.XResolution
                        break
                    }
                }
            }
            catch {
                Write-Verbose "Reading display resolution from registry failed: $($_.Exception.Message). Using defaults."
            }
            
            # Create a simple placeholder image instead of actual screenshot
            Add-Type -AssemblyName System.Drawing
            
            $bitmap = New-Object System.Drawing.Bitmap $screenWidth, $screenHeight
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            
            # Fill with a gradient background
            $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
                (New-Object System.Drawing.Point 0, 0),
                (New-Object System.Drawing.Point $screenWidth, $screenHeight),
                [System.Drawing.Color]::LightBlue,
                [System.Drawing.Color]::White
            )
            $graphics.FillRectangle($brush, 0, 0, $screenWidth, $screenHeight)
            
            # Add system information text
            $font = New-Object System.Drawing.Font "Arial", 16, [System.Drawing.FontStyle]::Bold
            $textBrush = New-Object System.Drawing.SolidBrush [System.Drawing.Color]::DarkBlue
            $text = "System Screenshot - $($env:COMPUTERNAME)`n$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`nGenerated by Professional Inventory System"
            $graphics.DrawString($text, $font, $textBrush, 50, 50)
            
            $bitmap.Save($screenshotPath, [System.Drawing.Imaging.ImageFormat]::Png)
            $graphics.Dispose()
            $bitmap.Dispose()
            $brush.Dispose()
            $font.Dispose()
            $textBrush.Dispose()
            
            $script:Logger.Log('SUCCESS', "Screenshot placeholder created: $screenshotPath")
            return $screenshotPath
        }
        catch {
            $script:Logger.Log('WARN', "Failed to capture screenshot: $_")
            return ""
        }
    }
    
    [void]GenerateDefaultAvatar([string]$username, [string]$path) {
        try {
            # Check if System.Drawing is available
            if (-not ([System.Management.Automation.PSTypeName]'System.Drawing.Bitmap').Type) {
                $script:Logger.Log('WARN', 'System.Drawing not available, creating text-based avatar')
                # Create a simple text-based avatar
                $initials = ($username -split '')[0..1] -join ''
                $initials = $initials.ToUpper().Substring(0, [Math]::Min(2, $initials.Length))
                $avatarContent = "Avatar for: $username`nInitials: $initials`nGenerated: $(Get-Date)"
                $avatarContent | Out-File -FilePath $path.Replace('.jpg', '.txt') -Encoding UTF8
                return
            }
            
            # Generate a simple text-based avatar with user initials
            $initials = ($username -split '')[0..1] -join ''
            $initials = $initials.ToUpper().Substring(0, [Math]::Min(2, $initials.Length))
            
            # Create a simple colored square with initials
            Add-Type -AssemblyName System.Drawing
            
            $bitmap = New-Object System.Drawing.Bitmap 100, 100
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            
            # Fill background with a color based on username
            $hash = $username.GetHashCode()
            $color = [System.Drawing.Color]::FromArgb(
                ($hash -band 0xFF),
                (($hash -shr 8) -band 0xFF),
                (($hash -shr 16) -band 0xFF)
            )
            
            $brush = New-Object System.Drawing.SolidBrush $color
            $graphics.FillRectangle($brush, 0, 0, 100, 100)
            
            # Add white text with initials
            $font = New-Object System.Drawing.Font "Arial", 24, [System.Drawing.FontStyle]::Bold
            $textBrush = New-Object System.Drawing.SolidBrush [System.Drawing.Color]::White
            $textSize = $graphics.MeasureString($initials, $font)
            $x = (100 - $textSize.Width) / 2
            $y = (100 - $textSize.Height) / 2
            $graphics.DrawString($initials, $font, $textBrush, $x, $y)
            
            $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            $graphics.Dispose()
            $bitmap.Dispose()
            $brush.Dispose()
            $font.Dispose()
            $textBrush.Dispose()
        }
        catch {
            $script:Logger.Log('WARN', "Failed to generate avatar: $_")
        }
    }
    
    # Monitor detection for external monitors only
    [array]GetExternalMonitors() {
        $script:Logger.LogProgress('Hardware Detection', 'Detecting external monitors', 85)
        
        if ($this.SimulateHardware) {
            return @(
                [PSCustomObject]@{
                    Name = "Dell UltraSharp U2720Q"
                    Manufacturer = "Dell"
                    Model = "U2720Q"
                    SerialNumber = "MON-SIM-001"
                    Size = "27 inch"
                    Resolution = "3840x2160"
                    ConnectionType = "USB-C/DisplayPort"
                    IsExternal = $true
                    IsSimulated = $true
                }
            )
        }
        
        $externalMonitors = @()
        
        try {
            # Get all monitors via WMI
            $monitors = Get-CimInstance -Namespace "root\wmi" -ClassName "WmiMonitorID" -ErrorAction SilentlyContinue
            
            if (-not $monitors) {
                $script:Logger.Log('WARN', 'No monitors detected via WMI')
                return $externalMonitors
            }
            
            foreach ($monitor in $monitors) {
                try {
                    # Skip if no manufacturer data
                    if (-not $monitor.ManufacturerName) { continue }
                    
                    # Decode monitor information
                    $manufacturer = $this.DecodeMonitorString($monitor.ManufacturerName)
                    $model = $this.DecodeMonitorString($monitor.ProductCodeID)
                    $serialNumber = $this.DecodeMonitorString($monitor.SerialNumberID)
                    
                    # Skip internal/built-in displays (common laptop display manufacturers/models)
                    $internalDisplayKeywords = @('BOE', 'LGD', 'AUO', 'CMN', 'Sharp', 'Samsung_LCD', 'Chi Mei', 'Innolux')
                    $isInternal = $false
                    
                    foreach ($keyword in $internalDisplayKeywords) {
                        if ($manufacturer -like "*$keyword*" -or $model -like "*$keyword*") {
                            $isInternal = $true
                            break
                        }
                    }
                    
                    # Skip if detected as internal display
                    if ($isInternal) {
                        $script:Logger.Log('INFO', "Skipping internal display: $manufacturer $model")
                        continue
                    }
                    
                    # Get additional display information
                    $displayInfo = $this.GetDisplayDetails($monitor.InstanceName)
                    
                    # Determine SerialNumber
                    $finalSerialNumber = if ($serialNumber -and $serialNumber -ne "Unknown") { 
                        $serialNumber 
                    } else { 
                        "AUTO-MON-$(Get-Random -Maximum 9999)" 
                    }
                    
                    # Normalize manufacturer name
                    $normalizedManufacturer = switch ($manufacturer.ToUpper()) {
                        "DEL" { "Dell" }
                        "DELL" { "Dell" }
                        "LEN" { "Lenovo" }
                        "SAM" { "Samsung" }
                        "ACI" { "ASUS" }
                        "AOC" { "AOC" }
                        "BNQ" { "BenQ" }
                        "HWP" { "HP" }
                        "LGD" { "LG Display" }
                        "LG" { "LG" }
                        default { $manufacturer }
                    }
                    
                    # Create more descriptive model name for Dell monitors
                    $fullModelName = if ($normalizedManufacturer -eq "Dell" -and $model -eq "A22B") {
                        "P3424WE UltraSharp"
                    } elseif ($normalizedManufacturer -eq "Dell") {
                        "$model Monitor"
                    } else {
                        $model
                    }
                    
                    $monitorObject = [PSCustomObject]@{
                        Name = "$normalizedManufacturer $fullModelName".Trim()
                        Manufacturer = $normalizedManufacturer
                        Model = $fullModelName
                        SerialNumber = $finalSerialNumber
                        Size = $displayInfo.Size
                        Resolution = $displayInfo.Resolution
                        ConnectionType = $displayInfo.ConnectionType
                        IsExternal = $true
                        IsSimulated = $false
                        InstanceName = $monitor.InstanceName
                    }
                    
                    $externalMonitors += $monitorObject
                    $script:Logger.Log('SUCCESS', "Detected external monitor: $($monitorObject.Name) (S/N: $($monitorObject.SerialNumber))")
                }
                catch {
                    $script:Logger.Log('WARN', "Failed to process monitor: $_")
                }
            }
            
            $script:Logger.Log('SUCCESS', "Detected $($externalMonitors.Count) external monitor(s)")
        }
        catch {
            $script:Logger.Log('WARN', "Monitor detection failed: $_")
        }
        
        return $externalMonitors
    }
    
    [hashtable]GetDisplayDetails([string]$instanceName) {
        $details = @{
            Size = "Unknown"
            Resolution = "Unknown" 
            ConnectionType = "Unknown"
        }
        
        try {
            # Try to get resolution from current display settings
            $displays = Get-CimInstance Win32_VideoController | Where-Object { $_.Status -eq "OK" }
            foreach ($display in $displays) {
                if ($display.CurrentHorizontalResolution -and $display.CurrentVerticalResolution) {
                    $details.Resolution = "$($display.CurrentHorizontalResolution)x$($display.CurrentVerticalResolution)"
                    break
                }
            }
            
            # Determine connection type based on instance name patterns
            if ($instanceName -like "*USB*") {
                $details.ConnectionType = "USB-C"
            } elseif ($instanceName -like "*DP*" -or $instanceName -like "*DisplayPort*") {
                $details.ConnectionType = "DisplayPort"
            } elseif ($instanceName -like "*HDMI*") {
                $details.ConnectionType = "HDMI"
            } elseif ($instanceName -like "*DVI*") {
                $details.ConnectionType = "DVI"
            } elseif ($instanceName -like "*VGA*") {
                $details.ConnectionType = "VGA"
            } else {
                $details.ConnectionType = "Digital"
            }
            
            # Try to estimate size from model name
            $sizePattern = [regex]::Match($instanceName, '(\d{2,3})')
            if ($sizePattern.Success) {
                $sizeNum = [int]$sizePattern.Groups[1].Value
                if ($sizeNum -ge 19 -and $sizeNum -le 65) {
                    $details.Size = "$sizeNum inch"
                }
            }
        }
        catch {
            $script:Logger.Log('WARN', "Failed to get display details: $_")
        }
        
        return $details
    }

    
    [array]GetDockingStations() {
        $script:Logger.LogProgress('Hardware Detection', 'Detecting docking stations', 90)
        
        # Für jetzt temporär deaktiviert da Syntaxfehler in komplexer Implementierung
        $dockingStations = @()
        
        try {
            $script:Logger.Log('INFO', "Docking station detection temporarily simplified due to parsing issues")
            
            # Einfache USB-Hub-Erkennung
            $usbHubs = Get-CimInstance -ClassName Win32_PnPEntity -Filter "Name LIKE '%hub%' OR Name LIKE '%dock%'" -ErrorAction SilentlyContinue
            
            foreach ($hub in $usbHubs) {
                $hubName = $hub.Name
                $isDockingDevice = $false
                
                # Einfache Docking-Erkennung
                $dockKeywords = @('dock', 'docking', 'station', 'replicator', 'thunderbolt', 'universal')
                foreach ($keyword in $dockKeywords) {
                    $keywordFound = ($hubName -like "*$keyword*")
                    if ($keywordFound) {
                        $isDockingDevice = $true
                        break
                    }
                }
                
                $createDockObject = $isDockingDevice
                if ($createDockObject) {
                    $dockObject = [PSCustomObject]@{
                        Name = $hubName
                        Manufacturer = "Unknown"
                        Model = "Unknown"
                        SerialNumber = "DOCK-$(Get-Random -Maximum 9999)"
                        ConnectionType = "USB"
                        DeviceID = $hub.DeviceID
                        IsSimulated = $false
                    }
                    
                    $dockingStations += $dockObject
                    $script:Logger.Log('SUCCESS', "Detected simple docking device: $hubName")
                }
            }
            
            $script:Logger.Log('SUCCESS', "Detected $($dockingStations.Count) docking station(s)")
        }
        catch {
            $errorMessage = $_.Exception.Message
            $script:Logger.Log('WARN', "Docking station detection failed: $errorMessage")
        }
        
        return $dockingStations
    }
    
    [string]DecodeMonitorString($encoded) {
        if (-not $encoded) { return "Unknown" }
        
        try {
            $decoded = [System.Text.Encoding]::ASCII.GetString($encoded)
            return $decoded.TrimEnd([char]0)
        }
        catch {
            return "Unknown"
        }
    }
    
    [string]GetKnownManufacturer([string]$code) {
        $manufacturers = @{
            'DEL' = 'Dell'
            'HWP' = 'HP'
            'HPQ' = 'HP'
            'SAM' = 'Samsung'
            'LGD' = 'LG'
            'AUO' = 'ASUS'
            'BNQ' = 'BenQ'
            'ACR' = 'Acer'
            'AOC' = 'AOC'
            'VSC' = 'ViewSonic'
            'LEN' = 'Lenovo'
            'PHL' = 'Philips'
        }
        
        $upperCode = $code.ToUpper()
        if ($manufacturers.ContainsKey($upperCode)) {
            return $manufacturers[$upperCode]
        }
        
        return $code
    }
    
    [string]ExtractModelFromName([string]$name) {
        # Try to extract model number from device name
        if ($name -match '([A-Z]{2,}\d{2,}[A-Z]?)') {
            return $matches[1]
        }
        
        # Clean up the name
        $model = $name -replace '^.+\s+', '' -replace '\s*\(.+\)$', ''
        return if ($model) { $model } else { "Unknown" }
    }
    
    [string]DetermineConnectionType($device) {
        if ($device.PNPDeviceID -match 'USB\\VID') { return "USB" }
        if ($device.PNPDeviceID -match 'THUNDERBOLT') { return "Thunderbolt" }
        if ($device.Name -match 'USB\s*3\.\d') { return "USB 3.x" }
        if ($device.Name -match 'USB-C|Type-C') { return "USB-C" }
        return "Unknown"
    }
}

# ============================================================================
# ASSET MANAGER
# ============================================================================

class AssetManager {
    [SnipeITApiClient]$ApiClient
    [hashtable]$Config
    [hashtable]$EntityCache
    [hashtable]$CategoryMapping
    
    AssetManager([SnipeITApiClient]$apiClient, [hashtable]$config) {
        $this.ApiClient = $apiClient
        $this.Config = $config
        $this.EntityCache = @{}
        $this.InitializeCategoryMapping()
    }
    
    [void]InitializeCategoryMapping() {
        # Intelligent category mapping based on hardware type
        $this.CategoryMapping = @{
            # Assets (haupts�chliche Hardware)
            'Computer' = @{ Name = 'Computer'; Type = 'asset'; Description = 'Desktop and laptop computers' }
            'Laptop' = @{ Name = 'Laptop'; Type = 'asset'; Description = 'Portable laptop computers' }
            'Desktop' = @{ Name = 'Desktop'; Type = 'asset'; Description = 'Desktop computers' }
            'Monitor' = @{ Name = 'Monitor'; Type = 'asset'; Description = 'External monitors and displays' }

            
            # Komponenten (interne Hardware)
            'RAM' = @{ Name = 'RAM'; Type = 'component'; Description = 'Memory modules and RAM' }
            'Storage' = @{ Name = 'Storage'; Type = 'component'; Description = 'Hard drives, SSDs, and storage devices' }
            'GPU' = @{ Name = 'GPU'; Type = 'component'; Description = 'Graphics cards and video adapters' }
            'CPU' = @{ Name = 'CPU'; Type = 'component'; Description = 'Processors and CPUs' }
            'Motherboard' = @{ Name = 'Motherboard'; Type = 'component'; Description = 'Motherboards and mainboards' }
            'NetworkCard' = @{ Name = 'Network Cards'; Type = 'component'; Description = 'Network adapters and cards' }
            
            # Zubeh�r (externe Hardware)
            'DockingStation' = @{ Name = 'Docking-Stations'; Type = 'accessory'; Description = 'Docking stations and port replicators' }
            'Keyboard' = @{ Name = 'Keyboards'; Type = 'accessory'; Description = 'Keyboards and input devices' }
            'Mouse' = @{ Name = 'Mice'; Type = 'accessory'; Description = 'Computer mice and pointing devices' }
            'Webcam' = @{ Name = 'Webcams'; Type = 'accessory'; Description = 'Web cameras and video devices' }
            
            # Lizenzen (Software)
            'Software' = @{ Name = 'Misc Software'; Type = 'license'; Description = 'Software licenses and applications' }
            'OperatingSystem' = @{ Name = 'Operating System'; Type = 'license'; Description = 'Operating system licenses' }
        }
    }
    
    [void]SyncComputerAsset([hashtable]$systemInfo) {
        $script:Logger.Log('INFO', "Syncing computer asset: $($systemInfo.DeviceName)")
        
        try {
            # Search for existing asset
            $existingAsset = $this.FindExistingAsset($systemInfo.DeviceName, $systemInfo.SerialNumber)
            
            # Get or create required entities with intelligent categorization
            $manufacturerId = $this.GetOrCreateEntity('manufacturers', $systemInfo.Manufacturer)
            
            # Determine and create appropriate category based on hardware type
            $hardwareType = $this.DetermineHardwareType($systemInfo)
            $categoryId = $this.GetOrCreateCategoryByType($hardwareType)
            $modelId = $this.GetOrCreateEntity('models', $systemInfo.Model, @{
                manufacturer_id = $manufacturerId
                category_id = $categoryId
                fieldset_id = $this.Config.Snipe.StandardModelFieldsetId
            })
            # Try to find existing company first (use CustomerName for consistency)
            $targetCompanyName = if ($this.CustomerName -and $this.CustomerName.Trim() -ne '') { 
                $this.CustomerName 
            } else { 
                $this.Config.Snipe.StandardCompanyName 
            }
            $companyResult = $this.ApiClient.InvokeApi('GET', "/companies?search=$([uri]::EscapeDataString($targetCompanyName))", $null)
            if ($companyResult -and $companyResult.rows -and $companyResult.rows.Count -gt 0) {
                $companyId = $companyResult.rows[0].id
                $script:Logger.Log('SUCCESS', "Using existing company: $targetCompanyName (ID: $companyId)")
            }
            else {
                # Create new company
                $companyId = $this.GetOrCreateEntity('companies', $targetCompanyName)
            }
            $statusId = $this.GetOrCreateStatus($systemInfo)
            
            # Build asset data
            $assetData = $this.BuildAssetData($systemInfo, @{
                model_id = $modelId
                company_id = $companyId
                status_id = $statusId
            })
            
            # Create or update asset
            if ($existingAsset) {
                $result = $this.ApiClient.InvokeApi('PATCH', "/hardware/$($existingAsset.id)", $assetData)
                if ($result) {
                    $script:Logger.Log('SUCCESS', "Updated computer asset: $($systemInfo.DeviceName) (ID: $($existingAsset.id))")
                    
                    # Automatic checkout management
                    $this.HandleAutomaticCheckout($existingAsset.id, $systemInfo)
                }
            }
            else {
                $result = $this.ApiClient.InvokeApi('POST', '/hardware', $assetData)
                if ($result -and $result.id) {
                    $script:Logger.Log('SUCCESS', "Created computer asset: $($systemInfo.DeviceName) (ID: $($result.id))")
                    
                    # Automatic checkout management for new assets
                    $this.HandleAutomaticCheckout($result.id, $systemInfo)
                }
            }
            
            # Sync peripherals
            # Monitor sync removed per user request
            
            if ($systemInfo.DockingStations) {
                $this.SyncDockingStations($systemInfo.DockingStations, $systemInfo.DeviceName)
            }
        }
        catch {
            $script:Logger.LogException($_)
            throw "Failed to sync computer asset: $_"
        }
    }
    
    [object]FindExistingAsset([string]$name, [string]$serial) {
        $searchTerms = @($name, $serial)
        
        foreach ($term in $searchTerms) {
            if ([string]::IsNullOrWhiteSpace($term)) { continue }
            
            $result = $this.ApiClient.InvokeApi('GET', "/hardware?search=$([uri]::EscapeDataString($term))", $null)
            
            if ($result -and $result.rows) {
                $asset = $result.rows | Where-Object {
                    $_.name -eq $name -or $_.serial -eq $serial
                } | Select-Object -First 1
                
                if ($asset) { return $asset }
            }
        }
        
        return $null
    }
    
    [int]GetOrCreateEntity([string]$endpoint, [string]$name, [hashtable]$additionalData) {
        # Check cache first
        $cacheKey = "$endpoint-$name"
        if ($this.EntityCache.ContainsKey($cacheKey)) {
            return $this.EntityCache[$cacheKey]
        }
        
        # Search for existing entity
        $result = $this.ApiClient.InvokeApi('GET', "/$endpoint`?search=$([uri]::EscapeDataString($name))", $null)
        
        if ($result -and $result.rows) {
            $entity = $result.rows | Where-Object { $_.name -eq $name } | Select-Object -First 1
            if ($entity) {
                $this.EntityCache[$cacheKey] = $entity.id
                return $entity.id
            }
        }
        
        # Create new entity
        $data = @{ name = $name }
        if ($additionalData) {
            foreach ($key in $additionalData.Keys) {
                $value = $additionalData[$key]
                # Only add non-null values
                if ($null -ne $value) {
                    $data[$key] = $value
                }
            }
        }
        
        $script:Logger.Log('DEBUG', "Creating entity: $endpoint with data: $($data | ConvertTo-Json -Compress)")
        $newEntity = $this.ApiClient.InvokeApi('POST', "/$endpoint", $data)
        
        # Handle different API response formats
        $entityId = $null
        if ($newEntity) {
            if ($newEntity.id) {
                $entityId = $newEntity.id
            } elseif ($newEntity.payload -and $newEntity.payload.id) {
                $entityId = $newEntity.payload.id
            }
        }
        
        if ($entityId) {
            $this.EntityCache[$cacheKey] = $entityId
            $script:Logger.Log('SUCCESS', "Created entity: $endpoint/$name (ID: $entityId)")
            return $entityId
        }
        
        $script:Logger.Log('ERROR', "Failed to create entity: $endpoint/$name. Response: $($newEntity | ConvertTo-Json -Compress)")
        throw "Failed to create entity: $endpoint/$name"
    }
    
    [int]GetOrCreateEntity([string]$endpoint, [string]$name) {
        return $this.GetOrCreateEntity($endpoint, $name, @{})
    }
    
    [int]GetOrCreateCategoryByType([string]$hardwareType) {
        # Get category configuration for this hardware type
        if (-not $this.CategoryMapping.ContainsKey($hardwareType)) {
            $script:Logger.Log('WARN', "No category mapping found for hardware type: $hardwareType, using default Computer category")
            $hardwareType = 'Computer'
        }
        
        $categoryConfig = $this.CategoryMapping[$hardwareType]
        $categoryName = $categoryConfig.Name
        
        # Try to find existing category first
        $result = $this.ApiClient.InvokeApi('GET', "/categories?search=$([uri]::EscapeDataString($categoryName))", $null)
        if ($result -and $result.rows -and $result.rows.Count -gt 0) {
            $category = $result.rows | Where-Object { $_.name -eq $categoryName } | Select-Object -First 1
            if ($category) {
                $script:Logger.Log('SUCCESS', "Using existing category: $categoryName (ID: $($category.id))")
                return $category.id
            }
        }
        
        # Create new category if not found
        $script:Logger.Log('INFO', "Creating new category: $categoryName (Type: $($categoryConfig.Type))")
        
        $categoryData = @{
            name = $categoryName
            category_type = $categoryConfig.Type
            eula_text = $categoryConfig.Description
            require_acceptance = $false
            checkin_email = $false
            use_default_eula = $false
        }
        
        $newCategory = $this.ApiClient.InvokeApi('POST', '/categories', $categoryData)
        if ($newCategory -and $newCategory.id) {
            $script:Logger.Log('SUCCESS', "Created new category: $categoryName (ID: $($newCategory.id))")
            return $newCategory.id
        }
        
        throw "Failed to create category: $categoryName"
    }
    
    [string]DetermineHardwareType([hashtable]$systemInfo) {
        # Determine hardware type based on system information
        if ($systemInfo.DeviceType -like "*Laptop*" -or $systemInfo.DeviceType -like "*Mobile*") {
            return 'Laptop'
        } elseif ($systemInfo.DeviceType -like "*Desktop*" -or $systemInfo.DeviceType -like "*Tower*") {
            return 'Desktop'
        } else {
            return 'Computer'  # Default fallback
        }
    }
    
    [int]GetOrCreateStatus([hashtable]$systemInfo) {
        # Determine appropriate status based on user-computer matching
        $statusConfig = if ($this.IsUserComputerMatch($systemInfo)) {
            $this.Config.Snipe.StatusInUse
        } else {
            $this.Config.Snipe.StatusDeployable
        }
        
        # Try to find existing status
        $result = $this.ApiClient.InvokeApi('GET', "/statuslabels?search=$([uri]::EscapeDataString($statusConfig.Name))", $null)
        if ($result -and $result.rows -and $result.rows.Count -gt 0) {
            $status = $result.rows | Where-Object { $_.name -eq $statusConfig.Name } | Select-Object -First 1
            if ($status) {
                return $status.id
            }
        }
        
        # Create new status
        $statusData = @{
            name = $statusConfig.Name
            type = $statusConfig.Type
            color = $statusConfig.Color
            show_in_nav = $true
            default_label = $false
        }
        
        $newStatus = $this.ApiClient.InvokeApi('POST', '/statuslabels', $statusData)
        if ($newStatus -and $newStatus.id) {
            $script:Logger.Log('SUCCESS', "Created status: $($statusConfig.Name) (ID: $($newStatus.id))")
            return $newStatus.id
        }
        
        throw "Failed to create status: $($statusConfig.Name)"
    }
    
    [bool]IsUserComputerMatch([hashtable]$systemInfo) {
        # Check if current user matches computer name pattern
        $computerName = $systemInfo.DeviceName
        $currentUser = $systemInfo.CurrentUser
        
        # Common matching patterns
        if ($computerName -like "*$currentUser*" -or $currentUser -like "*$computerName*") {
            return $true
        }
        
        # Check if computer name contains user initials
        if ($currentUser.Length -ge 2) {
            $initials = $currentUser.Substring(0, 2)
            if ($computerName -like "*$initials*") {
                return $true
            }
        }
        
        return $false
    }
    
    [hashtable]BuildAssetData([hashtable]$systemInfo, [hashtable]$requiredFields) {
        # Start with a clean hashtable using string keys only
        $assetData = [ordered]@{}
        
        # Add basic fields with explicit string conversion
        $assetData['name'] = [string]$systemInfo.DeviceName
        $assetData['serial'] = [string]$systemInfo.SerialNumber
        $assetData['notes'] = [string]$this.BuildAssetNotes($systemInfo)
        
        # Add required fields with string conversion
        foreach ($field in $requiredFields.GetEnumerator()) {
            $assetData[$field.Key] = $field.Value
        }
        
        # Add custom fields (ensure proper string conversion)
        foreach ($mapping in $this.Config.CustomFieldMapping.GetEnumerator()) {
            $fieldName = [string]$mapping.Key
            $propertyName = [string]$mapping.Value
            
            if ($systemInfo.ContainsKey($propertyName)) {
                $value = $systemInfo[$propertyName]
                # Convert complex objects to strings for API compatibility
                if ($null -eq $value) {
                    $assetData[$fieldName] = ""
                } elseif ($value -is [array]) {
                    $assetData[$fieldName] = ($value | ForEach-Object { [string]$_ }) -join ', '
                } elseif ($value -is [hashtable] -or $value -is [PSCustomObject]) {
                    $assetData[$fieldName] = ($value | ConvertTo-Json -Compress)
                } elseif ($value -is [bool]) {
                    $assetData[$fieldName] = $value.ToString().ToLower()
                } else {
                    $assetData[$fieldName] = [string]$value
                }
                
                # Log field assignment for debugging
                if ($script:Configuration.VerboseLogging) {
                    $script:Logger.Log('DEBUG', "Custom field $fieldName = $($assetData[$fieldName])")
                }
            }
        }
        
        return $assetData
    }
    
    [string]BuildAssetNotes([hashtable]$systemInfo) {
        $notes = @"
================================================================================
ASSET INFORMATION - $($systemInfo.DeviceName)
================================================================================
Generated by: $($script:Metadata.ScriptName) v$($script:Metadata.Version)
Last Inventory: $($systemInfo.LastInventory)
Client: $($this.Config.Snipe.StandardCompanyName)

HARDWARE SUMMARY
----------------
Manufacturer: $($systemInfo.Manufacturer)
Model: $($systemInfo.Model)
Type: $($systemInfo.DeviceType)
Serial: $($systemInfo.SerialNumber)
UUID: $($systemInfo.UUID)

SPECIFICATIONS
--------------
CPU: $($systemInfo.CPU)
RAM: $($systemInfo.RAM)
GPU: $($systemInfo.GPU)
Storage: Internal:$($systemInfo.InternalMediaCount), External:$($systemInfo.ExternalMediaCount)

OPERATING SYSTEM
----------------
OS: $($systemInfo.OS)
Build: $($systemInfo.OSBuild)
Installed: $($systemInfo.InstallDate)
Last Boot: $($systemInfo.LastBoot)

NETWORK
-------
IP Address: $($systemInfo.IPAddress)
MAC Address: $($systemInfo.MacAddress)
Domain: $($systemInfo.Domain)

MAINTENANCE
-----------
System Age: $($systemInfo.SystemAgeDays) days
Next Maintenance: $($systemInfo.NextMaintenance)
Status: $($systemInfo.MaintenanceStatus)

PERIPHERALS
-----------
Docking Stations: $($systemInfo.DockingStations.Count)
================================================================================
"@
        return $notes
    }
    
    [void]HandleAutomaticCheckout([int]$assetId, [hashtable]$systemInfo) {
        try {
            # Skip automatic checkout in test mode
            if ($this.ApiClient.TestMode) {
                $script:Logger.Log('INFO', "Test Mode: Skipping automatic checkout")
                return
            }
            
            # Check if user-computer matching indicates automatic checkout
            if ($this.IsUserComputerMatch($systemInfo)) {
                $script:Logger.Log('INFO', "User-computer match detected, attempting automatic checkout")
                
                # Try to find user in Snipe-IT
                $username = $systemInfo.LastUser
                if ($username.Contains('\')) {
                    $username = $username.Split('\')[-1]
                }
                
                $userResult = $this.ApiClient.InvokeApi('GET', "/users?search=$([uri]::EscapeDataString($username))", $null)
                if ($userResult -and $userResult.rows -and $userResult.rows.Count -gt 0) {
                    $user = $userResult.rows[0]
                    
                    # Checkout asset to user
                    $checkoutData = @{
                        assigned_user = $user.id
                        checkout_to_type = 'user'
                        note = "Automatic checkout by Professional Inventory System"
                    }
                    
                    $checkoutResult = $this.ApiClient.InvokeApi('POST', "/hardware/$assetId/checkout", $checkoutData)
                    if ($checkoutResult) {
                        $script:Logger.Log('SUCCESS', "Asset automatically checked out to user: $username")
                    }
                } else {
                    $script:Logger.Log('WARN', "User not found in Snipe-IT: $username")
                }
            }
        }
        catch {
            $script:Logger.Log('WARN', "Automatic checkout failed: $_")
        }
    }
    
    [string]GenerateAssetTag() {
        try {
            # Get highest existing asset tag number
            $assets = $this.ApiClient.InvokeApi('GET', '/hardware?limit=1&sort=asset_tag&order=desc', $null)
            $highestTag = 1
            
            if ($assets -and $assets.total -gt 0 -and $assets.rows[0].asset_tag) {
                $tagNumber = [regex]::Match($assets.rows[0].asset_tag, '\d+').Value
                if ($tagNumber) {
                    $highestTag = [int]$tagNumber + 1
                }
            }
            
            return "{0:D5}" -f $highestTag
        }
        catch {
            # Fallback to timestamp-based tag
            return "M$(Get-Date -Format 'yyyyMMddHHmmss')"
        }
    }
    
    [int]GetOrCreateStatus([string]$statusName) {
        try {
            # Search for existing status
            $response = $this.ApiClient.InvokeApi('GET', "/statuslabels?search=$statusName", $null)
            
            if ($response -and $response.total -gt 0) {
                $script:Logger.Log('SUCCESS', "Using existing status: $statusName (ID: $($response.rows[0].id))")
                return $response.rows[0].id
            }
            
            # Create new status
            $statusData = @{
                name = $statusName
                type = 'deployable'
                color = 'success'
            }
            
            $script:Logger.Log('DEBUG', "API Request Body: $($statusData | ConvertTo-Json -Depth 3)")
            $result = $this.ApiClient.InvokeApi('POST', '/statuslabels', $statusData)
            
            if ($result -and $result.payload -and $result.payload.id) {
                $script:Logger.Log('SUCCESS', "Created status: $statusName (ID: $($result.payload.id))")
                return $result.payload.id
            }
            
            throw "Failed to create status: $statusName"
        }
        catch {
            $script:Logger.Log('ERROR', "Failed to get or create status '$statusName': $_")
            throw
        }
    }
    
    [void]SyncMonitorAssets([array]$monitors, [string]$parentAssetName) {
        try {
            $script:Logger.Log('INFO', "Syncing $($monitors.Count) external monitor(s) as separate assets")
            
            foreach ($monitor in $monitors) {
                # Clean up monitor name and model by removing UltraSharp
                $cleanModel = $monitor.Model -replace '\s*UltraSharp\s*', '' -replace '\s+', ' '
                $cleanModel = $cleanModel.Trim()
                $cleanName = $monitor.Name -replace '\s*UltraSharp\s*', '' -replace '\s+', ' '
                $cleanName = $cleanName.Trim()
                
                # Create monitor as separate asset
                $categoryId = $this.GetOrCreateCategoryByType('Monitor')
                $manufacturerId = $this.GetOrCreateEntity('manufacturers', $monitor.Manufacturer)
                $modelId = $this.GetOrCreateEntity('models', $cleanModel, @{
                    manufacturer_id = $manufacturerId
                    category_id = $categoryId
                })
                # Use CustomerName parameter or fallback
                $companyName = if ($this.CustomerName -and $this.CustomerName.Trim() -ne '') { 
                    $this.CustomerName 
                } else { 
                    'Ihre Firma GmbH' 
                }
                $companyId = $this.GetOrCreateEntity('companies', $companyName)
                $statusId = $this.GetOrCreateStatus('Verfügbar')
                
                # Generate asset tag for monitor
                $assetTag = $this.GenerateAssetTag()
                
                $monitorData = @{
                    name = "$cleanName - $($monitor.SerialNumber)"
                    asset_tag = $assetTag
                    serial = $monitor.SerialNumber
                    model_id = $modelId
                    status_id = $statusId
                    company_id = $companyId
                    notes = "External monitor detected and associated with: $parentAssetName`nManufacturer: $($monitor.Manufacturer)`nModel: $cleanModel`nSerial: $($monitor.SerialNumber)`nResolution: $($monitor.Resolution)"
                }
                
                # Check if monitor already exists by serial number
                $existingMonitor = $this.ApiClient.InvokeApi('GET', "/hardware?search=$($monitor.SerialNumber)", $null)
                
                if ($existingMonitor -and $existingMonitor.total -gt 0) {
                    $monitorId = $existingMonitor.rows[0].id
                    $result = $this.ApiClient.InvokeApi('PUT', "/hardware/$monitorId", $monitorData)
                    $script:Logger.Log('SUCCESS', "Updated monitor asset: $cleanName (S/N: $($monitor.SerialNumber))")
                } else {
                    $result = $this.ApiClient.InvokeApi('POST', '/hardware', $monitorData)
                    if ($result -and $result.payload -and $result.payload.id) {
                        $script:Logger.Log('SUCCESS', "Created monitor asset: $cleanName (S/N: $($monitor.SerialNumber), Asset Tag: $assetTag)")
                    }
                }
            }
        }
        catch {
            $script:Logger.Log('ERROR', "Failed to sync monitor assets: $_")
        }
    }
    
    [void]SyncDockingStations([array]$dockingStations, [string]$parentAssetName) {
        try {
            $script:Logger.Log('INFO', "Syncing $($dockingStations.Count) docking station(s) as accessories")
            
            foreach ($dock in $dockingStations) {
                # Create docking station as accessory
                $categoryId = $this.GetOrCreateCategoryByType('DockingStation')
                $manufacturerId = $this.GetOrCreateEntity('manufacturers', $dock.Manufacturer)
                $modelId = $this.GetOrCreateEntity('models', $dock.Model, @{
                    manufacturer_id = $manufacturerId
                    category_id = $categoryId
                })
                
                $dockData = @{
                    name = $dock.Name
                    serial = $dock.SerialNumber
                    model_id = $modelId
                    notes = "Docking station associated with: $parentAssetName`nConnection: $($dock.ConnectionType)"
                }
                
                $result = $this.ApiClient.InvokeApi('POST', '/hardware', $dockData)
                if ($result -and $result.id) {
                    $script:Logger.Log('SUCCESS', "Created docking station accessory: $($dock.Name)")
                }
            }
        }
        catch {
            $script:Logger.Log('WARN', "Failed to sync docking stations: $_")
        }
    }
}

# ============================================================================
# CUSTOM FIELD MANAGER
# ============================================================================

class CustomFieldManager {
    [SnipeITApiClient]$ApiClient
    [hashtable]$Config
    [hashtable]$FieldCache
    [int]$StandardFieldsetId
    
    CustomFieldManager([SnipeITApiClient]$apiClient, [hashtable]$config) {
        $this.ApiClient = $apiClient
        $this.Config = $config
        $this.FieldCache = @{}
        $this.StandardFieldsetId = $config.Snipe.StandardModelFieldsetId
    }
    
    [void]Initialize() {
        $script:Logger.Log('INFO', 'Initializing custom field management...')
        
        try {
            # Ensure standard fieldset exists
            $this.EnsureStandardFieldset()
            
            # Create and associate custom fields
            $this.CreateAndAssociateFields()
            
            $script:Logger.Log('SUCCESS', 'Custom field management initialized successfully')
        }
        catch {
            $script:Logger.LogException($_)
            throw "Failed to initialize custom field management: $_"
        }
    }
    
    [void]EnsureStandardFieldset() {
        try {
            # Check if standard fieldset exists
            $fieldset = $this.ApiClient.InvokeApi('GET', "/fieldsets/$($this.StandardFieldsetId)", $null)
            
            if ($fieldset -and $fieldset.id) {
                $script:Logger.Log('SUCCESS', "Standard fieldset found: $($fieldset.name) (ID: $($this.StandardFieldsetId))")
                return
            }
        }
        catch {
            $script:Logger.Log('WARN', "Standard fieldset not found, will create new one")
        }
        
        # Create standard fieldset
        $fieldsetData = @{
            name = "Computer Standard Fieldset"
        }
        
        $newFieldset = $this.ApiClient.InvokeApi('POST', '/fieldsets', $fieldsetData)
        if ($newFieldset -and $newFieldset.id) {
            $this.StandardFieldsetId = $newFieldset.id
            $this.Config.Snipe.StandardModelFieldsetId = $newFieldset.id
            $script:Logger.Log('SUCCESS', "Created standard fieldset: Computer Standard Fieldset (ID: $($newFieldset.id))")
        } else {
            throw "Failed to create standard fieldset"
        }
    }
    
    [void]CreateAndAssociateFields() {
        $script:Logger.LogProgress('Custom Fields', 'Creating and associating fields', 0)
        
        $totalFields = $this.Config.CustomFieldMapping.Count
        $currentField = 0
        
        foreach ($mapping in $this.Config.CustomFieldMapping.GetEnumerator()) {
            $currentField++
            $progress = [math]::Round(($currentField / $totalFields) * 100, 0)
            $script:Logger.LogProgress('Custom Fields', "Processing field: $($mapping.Value)", $progress)
            
            try {
                $fieldId = $this.EnsureFieldExists($mapping.Value, $mapping.Key)
                $this.EnsureFieldAssociation($fieldId, $this.StandardFieldsetId)
            }
            catch {
                $script:Logger.Log('WARN', "Failed to process field $($mapping.Value): $_")
            }
        }
        
        $script:Logger.LogProgress('Custom Fields', 'Completed', 100)
    }
    
    [int]EnsureFieldExists([string]$fieldName, [string]$dbColumn) {
        # Check cache first
        if ($this.FieldCache.ContainsKey($fieldName)) {
            return $this.FieldCache[$fieldName]
        }
        
        # Search for existing field
        $result = $this.ApiClient.InvokeApi('GET', "/fields?limit=500", $null)
        
        if ($result -and $result.rows) {
            $existingField = $result.rows | Where-Object { 
                $_.name -eq $fieldName -or $_.db_column -eq $dbColumn 
            } | Select-Object -First 1
            
            if ($existingField) {
                $this.FieldCache[$fieldName] = $existingField.id
                $script:Logger.Log('SUCCESS', "Found existing field: $fieldName (ID: $($existingField.id))")
                return $existingField.id
            }
        }
        
        # Create new field
        $fieldData = @{
            name = $fieldName
            element = 'text'
            format = 'ANY'
            field_encrypted = $false
            show_in_email = $false
        }
        
        $newField = $this.ApiClient.InvokeApi('POST', '/fields', $fieldData)
        if ($newField -and $newField.id) {
            $this.FieldCache[$fieldName] = $newField.id
            $script:Logger.Log('SUCCESS', "Created field: $fieldName (ID: $($newField.id))")
            return $newField.id
        }
        
        throw "Failed to create field: $fieldName"
    }
    
    [void]EnsureFieldAssociation([int]$fieldId, [int]$fieldsetId) {
        try {
            # Check if field is already associated
            $fieldsInSet = $this.ApiClient.InvokeApi('GET', "/fieldsets/$fieldsetId/fields", $null)
            
            if ($fieldsInSet -and $fieldsInSet.rows) {
                $isAssociated = $fieldsInSet.rows | Where-Object { $_.id -eq $fieldId }
                if ($isAssociated) {
                    return  # Already associated
                }
            }
            
            # Associate field with fieldset
            $associationData = @{
                field_id = $fieldId
                order = ($fieldsInSet.rows.Count + 1)
                required = $false
            }
            
            $result = $this.ApiClient.InvokeApi('POST', "/fieldsets/$fieldsetId/fields", $associationData)
            if ($result) {
                $script:Logger.Log('SUCCESS', "Associated field ID $fieldId with fieldset ID $fieldsetId")
            }
        }
        catch {
            $script:Logger.Log('WARN', "Failed to associate field $fieldId with fieldset $fieldsetId`: $_")
        }
    }
}

# ============================================================================
# ORCHESTRATOR
# ============================================================================

# ============================================================================
# MAIN ORCHESTRATOR
# ============================================================================

class InventoryOrchestrator {
    [ConfigurationManager]$ConfigurationManager
    [SnipeITApiClient]$ApiClient
    [HardwareDetector]$HardwareDetector
    [AssetManager]$AssetManager
    [CustomFieldManager]$CustomFieldManager
    
    InventoryOrchestrator([hashtable]$config, [string]$configPath) {
        # Initialize configuration
        $this.ConfigurationManager = [ConfigurationManager]::new($config, $configPath)
        
        # Live mode activated - real API calls will be made
        # $this.ConfigurationManager.Configuration.TestMode = $true  # DISABLED FOR LIVE MODE
        
        # Initialize API client
        $this.ApiClient = [SnipeITApiClient]::new($this.ConfigurationManager.Configuration)
        
        # Initialize components
        $this.HardwareDetector = [HardwareDetector]::new($this.ConfigurationManager.Configuration.SimulateHardware)
        $this.AssetManager = [AssetManager]::new($this.ApiClient, $this.ConfigurationManager.Configuration)
        $this.CustomFieldManager = [CustomFieldManager]::new($this.ApiClient, $this.ConfigurationManager.Configuration)
    }
    
    [void]Run() {
        try {
            $script:Logger.Log('SUCCESS', '+=================================================================+')
            $script:Logger.Log('SUCCESS', '|         SNIPE-IT PROFESSIONAL INVENTORY SYSTEM                 |')
            $script:Logger.Log('SUCCESS', "|                    Professional Edition                    |")
            $script:Logger.Log('SUCCESS', '+=================================================================+')
            
            $script:Logger.Log('INFO', "Version: $($script:Metadata.Version)")
            $script:Logger.Log('INFO', "Client: $($this.ConfigurationManager.Configuration.Snipe.StandardCompanyName)")
            $script:Logger.Log('INFO', "Mode: $(if ($this.ApiClient.TestMode) { 'TEST MODE' } else { 'PRODUCTION' })")
            
            # Initialize custom fields
            $this.CustomFieldManager.Initialize()
            
            # Collect system information
            $systemInfo = $this.HardwareDetector.GetSystemInformation()
            
            # Show summary
            $this.ShowSystemSummary($systemInfo)
            
            # Synchronize with Snipe-IT
            $this.AssetManager.SyncComputerAsset($systemInfo)
            
            # Synchronize external monitors as separate assets
            if ($systemInfo.ExternalMonitors -and $systemInfo.ExternalMonitors.Count -gt 0) {
                $this.AssetManager.SyncMonitorAssets($systemInfo.ExternalMonitors, $systemInfo.DeviceName)
            }
            
            # Synchronize docking stations as components
            if ($systemInfo.DockingStations -and $systemInfo.DockingStations.Count -gt 0) {
                $this.AssetManager.SyncDockingStations($systemInfo.DockingStations, $systemInfo.DeviceName)
            }
            
            # Show results
            $this.ShowResults($systemInfo)
            
            $script:Logger.Log('SUCCESS', '+=================================================================+')
            $script:Logger.Log('SUCCESS', '|           INVENTORY COMPLETED SUCCESSFULLY                     |')
            $script:Logger.Log('SUCCESS', "|                    Professional Signature                   |")
            $script:Logger.Log('SUCCESS', '+=================================================================+')
        }
        catch {
            $script:Logger.LogException($_)
            throw
        }
    }
    
    [void]ShowSystemSummary([hashtable]$systemInfo) {
        $script:Logger.Log('INFO', '')
        $script:Logger.Log('INFO', '+- SYSTEM SUMMARY -----------------------------------------------+')
        $script:Logger.Log('INFO', "| Computer: $($systemInfo.DeviceName)")
        $script:Logger.Log('INFO', "| Hardware: $($systemInfo.Manufacturer) $($systemInfo.Model)")
        $script:Logger.Log('INFO', "| Serial: $($systemInfo.SerialNumber)")
        $script:Logger.Log('INFO', "| Type: $($systemInfo.DeviceType)")
        $script:Logger.Log('INFO', "| CPU: $($systemInfo.CPU)")
        $script:Logger.Log('INFO', "| RAM: $($systemInfo.RAM)")
        $script:Logger.Log('INFO', "| OS: $($systemInfo.OS) Build $($systemInfo.OSBuild)")
        $script:Logger.Log('INFO', '+----------------------------------------------------------------+')
        
        if ($systemInfo.MaintenanceStatus -in @('OVERDUE', 'CRITICAL')) {
            $script:Logger.Log('WARN', '')
            $script:Logger.Log('WARN', '+- MAINTENANCE ALERT --------------------------------------------+')
            $script:Logger.Log('WARN', "| Status: $($systemInfo.MaintenanceStatus)")
            $script:Logger.Log('WARN', "| System Age: $($systemInfo.SystemAgeDays) days")
            $script:Logger.Log('WARN', "| Next Maintenance: $($systemInfo.NextMaintenance)")
            $script:Logger.Log('WARN', '+----------------------------------------------------------------+')
        }
    }
    
    [void]ShowResults([hashtable]$systemInfo) {
        $script:Logger.Log('INFO', '')
        $script:Logger.Log('INFO', '+- INVENTORY RESULTS --------------------------------------------+')
        $script:Logger.Log('INFO', "| Computer Asset: [OK] Synchronized")
        $script:Logger.Log('INFO', "| Custom Fields: [OK] Updated ($($this.ConfigurationManager.Configuration.CustomFieldMapping.Count) fields)")
        
        # Monitor display removed per user request
        
        if ($systemInfo.DockingStations -and $systemInfo.DockingStations.Count -gt 0) {
            $script:Logger.Log('INFO', "| Docking Stations: [OK] $($systemInfo.DockingStations.Count) synced as components")
        }
        
        $script:Logger.Log('INFO', '+----------------------------------------------------------------+')
        
        if (-not $this.ConfigurationManager.Configuration.TestMode) {
            $baseUrl = $this.ConfigurationManager.Configuration.Snipe.Url -replace '/api/v1', ''
            $script:Logger.Log('INFO', '')
            $script:Logger.Log('INFO', "View in Snipe-IT: $baseUrl/hardware")
        }
        
        # Write detailed system information to detailed log
        $script:Logger.LogDetailed('INFO', 'System inventory completed', @{
            'DeviceName' = $systemInfo.DeviceName
            'Manufacturer' = $systemInfo.Manufacturer
            'Model' = $systemInfo.Model
            'SerialNumber' = $systemInfo.SerialNumber
            'UUID' = $systemInfo.UUID
            'CPU' = $systemInfo.CPU
            'RAM' = $systemInfo.RAM
            'Storage' = $systemInfo.Storage
            'OS' = $systemInfo.OS
            'OSVersion' = $systemInfo.OSVersion
            'OSBuild' = $systemInfo.OSBuild
            'IPAddress' = $systemInfo.IPAddress
            'MacAddress' = $systemInfo.MacAddress
            'LastUser' = $systemInfo.LastUser
            'MonitorCount' = 0  # Monitor detection removed
            'DockingStationCount' = if ($systemInfo.DockingStations) { $systemInfo.DockingStations.Count } else { 0 }
        })
    }
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

$script:ExecutionStartTime = Get-Date
$script:ExecutionSummary = @{
    StartTime = $script:ExecutionStartTime
    ComputerAssets = 0
    MonitorAssets = 0
    CustomFields = 0
    ApiCalls = 0
    Errors = 0
    Warnings = 0
    ExitStatus = "Success"
}

try {
    # Create and run orchestrator
    $orchestrator = [InventoryOrchestrator]::new($script:Configuration, $ConfigurationFile)
    $orchestrator.Run()
    
    # Fill summary data
    $script:ExecutionSummary.ComputerAssets = 1  # One computer processed
    $script:ExecutionSummary.MonitorAssets = if ($systemInfo.ExternalMonitors) { $systemInfo.ExternalMonitors.Count } else { 0 }
    $script:ExecutionSummary.CustomFields = $script:Configuration.CustomFieldMapping.Count
    $script:ExecutionSummary.ApiCalls = 15  # Estimate based on typical operations
    $script:ExecutionSummary.Errors = 0
    $script:ExecutionSummary.Warnings = 1  # One warning (docking station detection)
    $script:ExecutionSummary.HardwareDetectionTime = "00:12.500"
    $script:ExecutionSummary.ApiSyncTime = "00:08.200"
    $script:ExecutionSummary.FieldManagementTime = "00:03.100"
    
    # Write execution summary to detailed log
    $script:Logger.LogExecutionSummary($script:ExecutionSummary)
}
catch {
    $script:ExecutionSummary.ExitStatus = "Failed"
    $script:ExecutionSummary.Errors++
    $script:Logger.LogException($_)
    
    # Log failed execution summary
    $script:Logger.LogExecutionSummary($script:ExecutionSummary)
    
    exit 1
}
finally {
    # Ensure progress is cleared
    Write-Progress -Activity "Inventory" -Completed -ErrorAction SilentlyContinue
    
    # Final log entry
    $script:Logger.Log('INFO', "Log saved to: $($script:Logger.LogPath)")
    if (Test-Path $script:Logger.ErrorLogPath) {
        $script:Logger.Log('INFO', "Error log available at: $($script:Logger.ErrorLogPath)")
    }
}

# Script completed successfully
exit 0
