# Variables
$installerPath = "\\smb-share\Dell-Command-Update-Windows-Universal-Application_9M35M_WIN_5.4.0_A00.EXE.exe"
$logFile = "C:\DellCommandUpdate_Log.txt"

# Function to write to log file
function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Write-Output $logMessage
    $logMessage | Out-File -Append -FilePath $logFile
}

# 1. Check if Dell Command Update is installed
$installed = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Dell Command | Update*" }
if ($installed) {
    Write-Log "Dell Command Update is already installed (Version: $($installed.Version))."
} else {
    Write-Log "Dell Command Update is not installed. Installing..."
    Start-Process -FilePath $installerPath -ArgumentList "/s" -Wait
    Write-Log "Installation complete."
}

# 2. Check if the application needs an update
$dcuPath = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
if (-Not (Test-Path $dcuPath)) {
    $dcuPath = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
}
if (Test-Path $dcuPath) {
    $dcuVersion = & "$dcuPath" /version
    Write-Log "Current Dell Command Update Version: $dcuVersion"
    if ($dcuVersion -lt "5.4.0") {
        Write-Log "Updating Dell Command Update to the latest version..."
        Start-Process -FilePath $installerPath -ArgumentList "/s" -Wait
        Write-Log "Update complete."
    } else {
        Write-Log "Dell Command Update is already up-to-date."
    }
} else {
    Write-Log "Dell Command Update executable not found. Something went wrong."
    exit 1
}

# 3. Run Dell Command Update to scan for updates (silent mode)
Write-Log "Scanning for updates using Dell Command Update..."
Start-Process -FilePath $dcuPath -ArgumentList "/scan -s" -Wait
Write-Log "Scan complete."

# 4. Apply updates silently
Write-Log "Applying updates silently..."
Start-Process -FilePath $dcuPath -ArgumentList "/applyUpdates -s" -Wait
Write-Log "Updates applied."

# 5. End of process
Write-Log "Dell Command Update process completed."
