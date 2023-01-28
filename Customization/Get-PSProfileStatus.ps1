#requires -version 5.1

Function Get-PSProfileStatus {
    <#
    .SYNOPSIS
    List PowerShell Profiles
    .DESCRIPTION
    Get a summary of PowerShell profile scripts.
    .INPUTS
    None
    .EXAMPLE
    PS C:\> Get-PSProfileStatus

        PSHost: ConsoleHost [7.2.1]

    Profile      : AllUsersAllHosts
    Path         : C:\Program Files\PowerShell\7\profile.ps1
    Size         : 854
    LastModified : 1/26/2022 5:22:54 PM

    Profile      : AllUsersCurrentHost
    Path         : C:\Program Files\PowerShell\7\Microsoft.PowerShell_profile.ps1
    Size         :
    LastModified :

    Profile      : CurrentUserAllHosts
    Path         : C:\Users\Jeff\Documents\PowerShell\profile.ps1
    Size         : 384
    LastModified : 1/25/2022 1:22:00 PM

    Profile      : CurrentUserCurrentHost
    Path         : C:\Users\Jeff\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
    Size         : 4443
    LastModified : 1/28/2022 5:07:10 PM

    Profiles not in use will be displayed in red.

    #>
    [cmdletbinding()]
    [OutputType("PSProfileStatus")]
    Param()
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        $files = $profile.psobject.properties.where({ $_.name -ne 'length' })
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting profile status for PS $($PSVersionTable.psversion) "
        foreach ($item in $files) {
            if (Test-Path -Path $item.value) {
                $f = Get-Item -Path $item.value
                $Valid = $true
                if ($f.target) {
                    $t = Get-Item $f.target
                    $profileSize = $t.Length
                    $profileModified = $t.LastWriteTime
                }
                else {
                    $profileSize = $f.Length
                    $profileModified = $f.LastWriteTime
                }
            }
            else {
                $Valid = $false
                $profileSize = $null
                $profileModified = $null
            }
            [pscustomobject]@{
                PSTypeName   = "PSProfileStatus"
                Profile      = $item.name
                Path         = $item.Value
                Size         = $profileSize
                LastModified = $profileModified
                Exists       = $valid
                PSHost       = $host.name
                PSVersion    = $PSVersionTable.PSVersion
            }
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Get-PSProfileStatus

#format file
Update-FormatData $PSScriptRoot\psprofilestatus.format.ps1xml
