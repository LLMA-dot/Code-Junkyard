# This file is not complete. I am still working on it.

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]
    $DomainController
)


### Variables ###

$DomainController = "*"


if ($DomainController -eq "*") {

    $DomainController = Get-ADDomainController -filter *

}
else {

    Get-ADDomainController -Identity $DomainController
    
}

$DomainController

### Functions
### Function to Test DC Connection
function Test-DC-Connection {
    <#
.SYNOPSIS
Retrieves specific information about one or more computers, using WMI or CIM.
.DESCRIPTION
This command uses either WMI or CIM to retrieve specific information about one or more computers. You must run this command as a user who has permission to remotely query CIM or WMI on the machines involved. You can specifiy a starting protocol (CIM by default), and specify that, in the event of a failure, the other protocol be used on a per-machine basis.
.PARAMETER ComputerName
One or more computer names. When using WMI, this can also be IP addresses. IP addresses may not work for CIM.
.PARAMETER LogFailuresToPath
A path and filename to Write rfailed computer names to. If omitted, no log will be written. 
.PARAMETER Protocol
Valid values: Wsman (uses CIM) or Dcom (uses WMI). Will be used for all machines. "Wsman" is the default.
.PARAMETER ProtocolFallback
Specify this to automatically try the other protocol if a machine fails.
.EXAMPLE 
Get-MachineInfo -ComputerName ONE,TWO,THREE
This example will query the three machines.
.EXAMPLE
Get-AD-Computer -filter * | Select-Expand Name | Get-MachineInfo
This example will attempt to query all machines in AD.
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DomainController
    )

    Begin {

    } #BEGIN

    Process {

        # Get DC if it's a String
        ForEach ($DC in $DomainController) {
        
            try {
                $DC = Get-ADDomainController -Identity $DC -ErrorAction Stop
            }
            catch {
                Write-Host "Object named $DC not found. Check if the name of the Domain Controller is correct." -ForegroundColor Red
                Write-Host "The script will exit." -ForegroundColor Red
            } #try

            [PSCustomObject]@{
                DC        = $DC
                IPv4      = $DC.IPv4Address
                Reachable = (Test-NetConnection -Computername $DC).PingSucceeded
            }
        }
    } #PROCESS

    End {

    } #END

} #Function

# Function to get when a DC was last rebooted
function Get-DC-LastReboot {
    <#
.SYNOPSIS
Retrieves specific information about one or more computers, using WMI or CIM.
.DESCRIPTION
This command uses either WMI or CIM to retrieve specific information about one or more computers. You must run this command as a user who has permission to remotely query CIM or WMI on the machines involved. You can specifiy a starting protocol (CIM by default), and specify that, in the event of a failure, the other protocol be used on a per-machine basis.
.PARAMETER ComputerName
One or more computer names. When using WMI, this can also be IP addresses. IP addresses may not work for CIM.
.PARAMETER LogFailuresToPath
A path and filename to Write rfailed computer names to. If omitted, no log will be written. 
.PARAMETER Protocol
Valid values: Wsman (uses CIM) or Dcom (uses WMI). Will be used for all machines. "Wsman" is the default.
.PARAMETER ProtocolFallback
Specify this to automatically try the other protocol if a machine fails.
.EXAMPLE 
Get-MachineInfo -ComputerName ONE,TWO,THREE
This example will query the three machines.
.EXAMPLE
Get-AD-Computer -filter * | Select-Expand Name | Get-MachineInfo
This example will attempt to query all machines in AD.
#>

    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DomainController
    )

    ForEach ($DC in $DomainController) {

        try {
        
            $DCBootUpTime = Get-CimInstance -ComputerName $DC.Name -ClassName Win32_OperatingSystem  -Property * -ErrorAction Stop | Select LastBootUpTime -ExpandProperty LastBootUpTime 

            [PSCustomObject]@{
                DC               = $DC
                LastBootUpTime   = Get-Date $DCBootUpTime -Format "yyyy/M/d"
                RebootCompliance = TBD
            
            } 
        }
        catch {
        
            Write-Host "Domain Controller $DC is not reachable by WinRM. Check for an issue manually!" -ForegroundColor Red
        
        } # try/catch
            
    } # Foreach
        
}

# Get last installed Hotfix
function Get-DC-HotfixCompliance {
    <#
.SYNOPSIS
Retrieves specific information about one or more computers, using WMI or CIM.
.DESCRIPTION
This command uses either WMI or CIM to retrieve specific information about one or more computers. You must run this command as a user who has permission to remotely query CIM or WMI on the machines involved. You can specifiy a starting protocol (CIM by default), and specify that, in the event of a failure, the other protocol be used on a per-machine basis.
.PARAMETER ComputerName
One or more computer names. When using WMI, this can also be IP addresses. IP addresses may not work for CIM.
.PARAMETER LogFailuresToPath
A path and filename to Write rfailed computer names to. If omitted, no log will be written. 
.PARAMETER Protocol
Valid values: Wsman (uses CIM) or Dcom (uses WMI). Will be used for all machines. "Wsman" is the default.
.PARAMETER ProtocolFallback
Specify this to automatically try the other protocol if a machine fails.
.EXAMPLE 
Get-MachineInfo -ComputerName ONE,TWO,THREE
This example will query the three machines.
.EXAMPLE
Get-AD-Computer -filter * | Select-Expand Name | Get-MachineInfo
This example will attempt to query all machines in AD.
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        $DomainController
    )

    ForEach ($DC in $DomainController) {
    
        ($DCHotfix = Get-Hotfix -ComputerName $DC | Sort-Object InstalledOn)[-1]
    }

    [PSCustomObject]@{
        DC         = $DC
        LastHotfix = $DCHotfix
    }
}

function Get-DCLastReplication {
    <#
.SYNOPSIS
Retrieves specific information about one or more computers, using WMI or CIM.
.DESCRIPTION
This command uses either WMI or CIM to retrieve specific information about one or more computers. You must run this command as a user who has permission to remotely query CIM or WMI on the machines involved. You can specifiy a starting protocol (CIM by default), and specify that, in the event of a failure, the other protocol be used on a per-machine basis.
.PARAMETER ComputerName
One or more computer names. When using WMI, this can also be IP addresses. IP addresses may not work for CIM.
.PARAMETER LogFailuresToPath
A path and filename to Write rfailed computer names to. If omitted, no log will be written. 
.PARAMETER Protocol
Valid values: Wsman (uses CIM) or Dcom (uses WMI). Will be used for all machines. "Wsman" is the default.
.PARAMETER ProtocolFallback
Specify this to automatically try the other protocol if a machine fails.
.EXAMPLE 
Get-MachineInfo -ComputerName ONE,TWO,THREE
This example will query the three machines.
.EXAMPLE
Get-AD-Computer -filter * | Select-Expand Name | Get-MachineInfo
This example will attempt to query all machines in AD.
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValuefromPipelineByPropertyName = $true)]
        $DomainController
    )

    Foreach ($DC in $DomainController) {
    
        $DCReplicationData = Get-ADReplicationPartnerMetadata -Target $DC 
        
        [PSCustomObject]@{
            Server                 = $DCReplicationData.Server
            LastReplicationAttempt = Get-Date $DCReplicationData.LastReplicationAttempt -Format "yyyy/M/d HH:mm"
            LastReplicationSuccess = Get-Date $DCReplicationData.LastReplicationSuccess -Format "yyyy/M/d HH:mm"
        
        }
    }
}


### Compliance Status Testing
If ($DCBootUpTime -lt $DCBootUpTime.AddDays(-60)) {
    Write-Host "lol"
}
else {
    
}
