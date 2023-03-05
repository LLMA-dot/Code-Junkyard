# This file is not complete. I am still working on it.

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [TypeName]
    $ParameterName
)


$CompanyDCs = Get-ADDomainController -filter *
$OnlineDCs = @()
$OfflineDCs = @()
$Logfilepath = "C:\Temp\"

$DC = Get-ADDomainController -Identity "ATHRD1VMS001"

Write-Host "Checking $($CompanyDCs.Count) Domain Controllers for the domain." -ForegroundColor Green

# Implement Begin, Process, End
# Output Online DCs as variable
# Output Online DCs to logfile
# Output Offline DCs to logfile

function Test-DC-Connection {
ForEach ($DC in $CompanyDCs) {



    try {
        Test-Connection -ComputerName $DC -Count 2 -ErrorAction Stop | Out-Null
        Write-Host "DC $DC is responding with IPv4 address $($DC.IPv4Address)." -ForegroundColor Green
        $OnlineDCs = $OnlineDCs + $DC
        
        
    }
    catch {
        Write-Host "DC $DC is not responding and appears to be offline! Please verify." -ForegroundColor Red
        $OfflineDCs = $OfflineDCs + $DC
        Write-Output "The DC $DC did not respond to a PING request on $(Get-Date) from $env:ComputerName." | Out-File $Logfilepath\DCCheck-$((Get-Date).ToString('yyyy-MM-dd')).txt -Append
    }
}

Write-Host "Out of $($CompanyDCs.Count) Domain Controllers, $($OnlineDCs.Count) responded." -ForegroundColor Green
Write-Host "$($OfflineDCs.Count) Domain Controller did not respond!" -ForegroundColor Red


}

# Implement Error Handling (PC is offline)
# Error Handling (CIM Lookup did not work)
# Output not reachable DCs to logfile.
# Include Possibility to get single DC last reboot
# Put out warning for every DC without a reboot in 2 months.

function Get-DC-LastReboot {
    
  #  [CmdletBinding()]
  #  param (
  #      [Parameter()]
  #      [string]
  #      $ComputerName
  #  )

    ForEach ($DC in $CompanyDcs) {
    $DCBootUpTime = Get-CimInstance -ComputerName $DC.Name -ClassName Win32_OperatingSystem  -Property * | Select LastBootUpTime -ExpandProperty LastBootUpTime

    Write-Host "DC $DC last Bootuptime was $DCBootUpTime." -ForegroundColor Green
    }
}

# Write to a logfile
# Put out a warning for every DC who has not seen an update in 2 months


function Get-DC-HotfixCompliance {

    ForEach ($DC in $CompanyDCs) {
    
        (Get-Hotfix -ComputerName $DC | Sort-Object InstalledOn)[-1]
    }
}
