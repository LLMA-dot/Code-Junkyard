
# Quick Script to get the last boot time of all Domain Controllers in your environment.

# Get all ALL Domain Controllers and put them into a variable
$OrgDcs = Get-ADDomainController -Filter * | Select-Object Name -ExpandProperty Name

#Start loop
ForEach ($DC in $OrgDCs)
    {
        # For every DC in the Variable, retrieve the Object...
        Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $DC | `
        # ... and Select the Name and the Last BootupTime Properties.
        Select Csname,LastBootuptime | 
        # Finally, export this information out to a CSV Path
        Export-Csv -Path C:\Temp\OrgDCLastReboot.csv -Append -NoTypeInformation`
        # Optional Output to let you know what the script is doing.
        Write-Host -ForegroundColor Green "## Query for $DC is running. Writing to CSV."   

    }
