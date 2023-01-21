# Quick function to return the PSHOstPrivateData values for further processing.
# First published in Jeff Hick's subscription blog: Behind the PowerShell Pipeline.

# Note that this will show ASCI sync values in PS 7 and the actual colors in Windows PowerShell.

Function Get-HostPrivateData {
    [cmdletbinding()]
    [outputtype("PSHostPrivateData")]
    Param()

    <#
     PowerShell 7.2 uses $PSStyle which overwrites the
     legacy $host.privatedata for some settings
     #>

    if ($psstyle.Formatting) {
        $settings = "Error", "Warning", "Verbose", "Debug"
        foreach ($item in $settings) {
            $rawansi = $psstyle.Formatting.$item -replace "`e", ""

            [pscustomobject]@{
                PSTypename = "PSHostPrivateData"
                Host       = $host.name
                Option     = $item
                TokenKind  = $item
                Setting    = "PSStyle.Formatting.$item"
                Value      = '`e{0}' -f $rawansi
            }
        }
        $rawansi = $psstyle.progress.style -replace "`e", ""
        [pscustomobject]@{
            PSTypename = "PSHostPrivateData"
            Host       = $host.name
            Option     = "Progress"
            TokenKind  = "Progress"
            Setting    = "PSStyle.Formatting.$item"
            Value      = '`e{0}' -f $rawansi
        }

    }
    else {
        #regular expression to parse property name
        [regex]$rx = "(Back|Fore).*"
        $colorOptions = $host.PrivateData | Select-Object -Property *color
        $colorOptions.psobject.properties | ForEach-Object {
            $token = $rx.split($_.name)[0]
            if ($token -eq 'DefaultToken') {
                $token = 'None'
            }

            [pscustomobject]@{
                PSTypename = "PSHostPrivateData"
                Host       = $host.name
                Option     = $_.name
                TokenKind  = $Token
                Setting    = $rx.match($_.name)
                Value      = $_.value
            }
        } #foreach color option
    }
} #end Get-HostPrivateData
