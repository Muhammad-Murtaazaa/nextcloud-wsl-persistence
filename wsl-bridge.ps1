# ==============================================================================
# WSL 2 Network Bridge Script
# Purpose: Bridges Windows Host Ports (80/443) to WSL 2 dynamic IP
# Save as wsl-bridge.ps1. Must be run as Administrator.
# ==============================================================================

# 1. Get the current WSL IP
$wsl_ip = (wsl -d Ubuntu hostname -I).Trim().Split(" ")[0]

if (-not $wsl_ip) {
    Write-Error "Could not detect WSL IP. Ensure Ubuntu is running."
    exit
}

# 2. Define Ports to bridge (HTTP and HTTPS)
$ports = @(80, 443)
$addr = "0.0.0.0" # Listen on all network interfaces

Write-Host "Targeting WSL IP: $wsl_ip" -ForegroundColor Cyan

foreach ($port in $ports) {
    # Remove old proxy rules for these ports to prevent conflicts
    netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$addr | Out-Null
    
    # Add the new bridge rule
    netsh interface portproxy add v4tov4 listenport=$port listenaddress=$addr connectport=$port connectaddress=$wsl_ip
    
    Write-Host "成功 (Success): Port $port bridged to $wsl_ip" -ForegroundColor Green
}

# 3. Open Windows Firewall for these ports (if not already open)
$ruleName = "Nextcloud_WSL_Inbound"
if (-not (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort 80,443 -Protocol TCP -Action Allow
    Write-Host "Firewall rule created." -ForegroundColor Yellow
}

Write-Host "`nBridge Active. You can now access Nextcloud via your Windows IP." -ForegroundColor White
