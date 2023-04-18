# This file is not complete. I am still working on it.

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $DomainController
)


### Variables ###

$DomainController = "*"


if ($DomainController -eq "*") {

    $DomainController = Get-ADDomainController -filter *

} else {

    Get-ADDomainController -Identity $DomainController
    
}

$DomainController

### Functions
### Function to Test DC Connection
function Test-DC-Connection {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $DomainController
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

# Function to get when a DC was last rebooted
function Get-DC-LastReboot {
    
  [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $DomainController
    )

    ForEach ($DC in $DomainController) {
    $DCBootUpTime = Get-CimInstance -ComputerName $DC.Name -ClassName Win32_OperatingSystem  -Property * | Select LastBootUpTime -ExpandProperty LastBootUpTime

            [PSCustomObject]@{
            DC = $DC
            LastBootUpTime = $DCBootUpTime
        }
    }
}

# Get last installed Hotfix
function Get-DC-HotfixCompliance {
   [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $DomainController
    )

    ForEach ($DC in $DomainController) {
    
        ($DCHotfix = Get-Hotfix -ComputerName $DC | Sort-Object InstalledOn)[-1]
    }

            [PSCustomObject]@{
            DC = $DC
            LastHotfix = $DCHotfix
            }
    }

function Get-DCLastReplication{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValuefromPipelineByPropertyName=$true)]
        $DomainController
    )

    Foreach ($DC in $DomainController) {
    
        $DCReplicationData = Get-ADReplicationPartnerMetadata -Target $DC 
        
        [PSCustomObject]@{
        Server = $DCReplicationData.Server
        LastReplicationAttempt = $DCReplicationData.LastReplicationAttempt
        LastReplicationSuccess = $DCReplicationData.LastReplicationSuccess
        
        }
    }
}
