# Install the OpenSSH Server
try {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}
catch {
    Write-Error "Failed to install OpenSSH Server with err:`n$_"
    return
}

# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Adjust sshd_config
$sshdConfig = "C:\ProgramData\ssh\sshd_config"

"# Authentication methods" | Out-File -FilePath $sshdConfig -Append
"PubkeyAuthentication yes" | Out-File -FilePath $sshdConfig -Append
"GSSAPIAuthentication yes" | Out-File -FilePath $sshdConfig -Append
