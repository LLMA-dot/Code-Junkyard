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

function Test-DC-Connection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$DomainController
    )

    Begin {

    } #BEGIN

    Process {

        # Get DC if it's a String
        ForEach ($DC in $DomainController) {
        
        try {
            $DC = Get-ADDomainController -Identity $DC -ErrorAction Stop
            } catch {
            Write-Host "Object named $DC not found. Check if the name of the Domain Controller is correct." -ForegroundColor Red
            Write-Host "The script will exit." -ForegroundColor Red
        } #try

        [PSCustomObject]@{
            DC = $DC
            IPv4 = $DC.IPv4Address
            Reachable = (Test-NetConnection -Computername $DC).PingSucceeded
        }
    }
    } #PROCESS

    End {

    } #END

} #Function

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
