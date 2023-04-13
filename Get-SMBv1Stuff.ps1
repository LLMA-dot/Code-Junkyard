
# Read Information into Variable 
$SMBv1Config = Get-SmbServerConfiguration
$SMBv1State = Get-WindowsOptionalFeature -Online -Featurename SMB1Protocol

# Execute on Server
# Check if Smb1Audit Logs are enabled.
If ($SMBv1Config.AuditSmb1Access) {
    Write-Host "AuditSmb1Access is enabled." -ForegroundColor Red
} else {
    Write-Host "AuditSmb1Access is false." -ForegroundColor green
}

#Check if SMBv1 is enabled
if ($SMBv1State.State -eq "Enabled") {
    Write-Host "SMBv1 is Enabled!" -ForegroundColor Red
} else {
    Write-Host "SMBv1 is Disabled!" -ForegroundColor green
}

# Disable Smb1Audit Logs verify
Set-SmbServerConfiguration -AuditSmb1Access $false
Write-Host "Audit Log for SMBv1 Access has been disabled!" -ForegroundColor Green
$SMBv1Config = Get-SmbServerConfiguration
If ($SMBv1Config.AuditSmb1Access) {
    Write-Host "AuditSmb1Access is enabled." -ForegroundColor Red
} else {
    Write-Host "AuditSmb1Access is false." -ForegroundColor green
}

# Disable SMB v1 and verify
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
Write-Host "SMBv1 has been disabled on this Object!" -ForegroundColor Green
$SMBv1State = Get-WindowsOptionalFeature -Online -Featurename SMB1Protocol
if ($SMBv1State.State -eq "Enabled") {
    Write-Host "SMBv1 is Enabled!" -ForegroundColor Red
} else {
    Write-Host "SMBv1 is Disabled!" -ForegroundColor green
}
