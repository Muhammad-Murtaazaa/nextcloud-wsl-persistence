' Nextcloud WSL Background Starter
' This script starts the WSL instance and initiates core services without a terminal window.

Set WinScriptHost = CreateObject("WScript.Shell")

' Command explanation:
' -d Ubuntu: Targets your specific distro
' -u root: Runs as root to ensure services have permission to start
' 0: The "0" at the end tells Windows to run the window hidden

WinScriptHost.Run "wsl -d Ubuntu -u root service apache2 start", 0
WinScriptHost.Run "wsl -d Ubuntu -u root service mysql start", 0
WinScriptHost.Run "wsl -d Ubuntu -u root service redis-server start", 0

Set WinScriptHost = Nothing
