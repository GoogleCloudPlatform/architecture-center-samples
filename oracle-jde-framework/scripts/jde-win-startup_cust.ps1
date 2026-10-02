# Enable and configure WinRM quietly
winrm quickconfig -q

# Enable PowerShell Remote Management
Enable-PSRemoting -Force

# Create Inbound Firewall Rule
New-NetFirewallRule -DisplayName "JDESMC_RDP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort @("445","3389","5150","5985","6017-6022","14502-14510")

# Create Outbound Firewall Rule
New-NetFirewallRule -DisplayName "JDESMC_RRD_out" -Direction Outbound -Action Allow -Protocol Any

# Change Security Option (NTLMv2 only)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 3 -Type DWord

# Set MTU to 1500 for the Ethernet interface
Get-NetIPInterface | Where-Object { ($_.InterfaceAlias -eq "Ethernet") -and ($_.AddressFamily -eq "IPv4") -and ($_.NlMtu -gt 0) } | Set-NetIPInterface -NlMtuBytes 1500