# Shows the values in HostPrivateData and returns how they look like right now.
# This was first published on Jeff Hicks Subscription Blog at Behind the PowerShell pipeline.

Function Show-HostPrivateData {
    #this command writes to the host
    [cmdletbinding()]
    [OutputType("None", "System.String")]
    Param()

    #this won't work properly in the ISE
    if ($host.name -match "ISE") {
        Write-Warning "This command will not work properly in the PowerShell ISE"
        return
    }

    <#
     PowerShell 7.2 uses $PSStyle which overwrites the
     legacy $host.privatedata for some settings
     #>

    if ($PSStyle.Formatting) {
        $settings = "Error", "Warning", "Verbose", "Debug"
        foreach ($item in $settings) {
            $rawansi = $psstyle.Formatting.$item -replace "`e", ""
            $text = "This is a sample $($item)"
            "`e{0}{1}`e[0m" -f $rawansi, $text
        }
        $rawansi = $psstyle.progress.style -replace "`e", ""
        $text = "This is a sample Progress"
        "`e{0}{1}`e[0m" -f $rawansi, $text
    }
    else {
        $data = Get-HostPrivateData | Group-Object -Property TokenKind | Sort-Object -Property Count

        foreach ($item in $data) {
            $text = "This is a sample $($item.name)"
            $wh = @{
                Object = $text.Trim()
            }
            if ($item.count -eq 1) {
                $wh.Add("Foregroundcolor", $item.Group.Value)
            }
            else {
                $item.group | ForEach-Object -Process {
                    foreach ($setting in $_) {
                        if ($setting.value -ne -1) {
                            $wh.add($setting.setting.value, $setting.value)
                        }
                    } #foreach $setting
                }
            }
            Write-Host @wh
        } #foreach item
    }

} #close Show-HostPrivateData
