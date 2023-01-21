# The function creates an actual sample of each stream. The $host.ui object has methods that implement the 
# different streams like WriteVerboseLine(). This works except for writing errors in PowerShell 7.

# First published in Jeff Hick's subscription blog "Behind the PowerShell Pipeline"

Function Test-HostPrivateData {
    #results may be incomplete in PowerShell 7.2
    [CmdletBinding()]
    Param()

    $streams = "Verbose", "Warning", "Debug"
    foreach ($s in $streams) {
        $text = "I am a sample $s stream"
        $method = "Write$($s)Line"
        $host.ui.$method($text)
    }

    # Error formatting is handled differently in PowerShell 7.2
    $text = "I am a sample Error stream"
    if ($psstyle.Formatting.Error) {
        #display an ANSI formatted string
        "{0}{1}{2}" -f $psstyle.formatting.Error, $text, $psstyle.Reset
    }
    else {
        $host.ui.WriteErrorLine($text)
    }

    Read-Host "Press Enter to see a 2 second progress sample"
    $progrec = [System.Management.Automation.ProgressRecord]::new(0, "Sample Activity", "Status Description")
    $progrec.PercentComplete = 50
    $progrec.CurrentOperation = "sample current operation"
    1..2 | ForEach-Object { $host.ui.WriteProgress(100, $progrec); Start-Sleep 1 }

}
