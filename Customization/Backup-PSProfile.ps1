#requires -version 5.1
#requires -module Microsoft.PowerShell.Archive

Function Backup-PSProfile {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, HelpMessage = "Specify the filename and path to the destination zip file.")]
        [ValidatePattern("\.zip$")]
        [ValidateScript({ Test-Path (Split-Path $_ -Parent) })]
        [string]$Destination = "MyProfiles.zip",
        [Parameter(HelpMessage = "Get the completed zip file.")]
        [switch]$Passthru
    )

    #initialize a list to hold profile paths
    $list = [System.Collections.Generic.list[string]]::New()

    #region AllUsers
    #PS7
    Try {
        $PS7Home = Split-Path (Get-Command pwsh.exe -ErrorAction Stop).Source
        #use regex to get profile scripts
        Write-Verbose "Getting PowerShell 7 profiles"
        Get-ChildItem -Path $PS7Home\*.ps1 | Where-Object { $_.name -match "(.*_)?profile.ps1" } |
        ForEach-Object { $list.Add($_.FullName) }
    }
    Catch {
        Write-Warning "PowerShell 7 not found on this computer."
    }

    #WinPS
    Try {
        $WinPSHome = Split-Path (Get-Command powershell.exe -ErrorAction Stop).Source
        Write-Verbose "Getting Windows PowerShell profiles"
        Get-ChildItem -Path $WinPShome\*.ps1 | Where-Object { $_.name -match "(.*_)?profile.ps1" } |
        ForEach-Object { $list.Add($_.FullName) }
    }
    Catch {
        Write-Warning "Windows PowerShell not found on this computer."
    }
    #endregion

    #region CurrentUser

    Write-Verbose "Getting current user profiles"
    if ($IsCoreCLR -AND (-Not $IsWindows)) {
        $CUPath = Split-Path $profile
        Get-ChildItem -Path $CUPath -Filter *.ps1 | Where-Object { $_.name -match "(.*_)?profile.ps1" } |
        ForEach-Object { $list.Add($_.FullName) }
    }
    else {
        #assuming anything else is Windows
        (Get-ChildItem $home\documents\ -Directory).where({ $_.name -match "(Windows)?PowerShell" }).fullname |
        Get-ChildItem -Filter *.ps1 | Where-Object { $_.name -match "(.*_)?profile.ps1" } |
        ForEach-Object { $list.Add($_.FullName) }
    }

    #endregion

    #region Create temporary directory structure

    $tmpDir = New-Item -ItemType Directory ([system.io.path]::GetTempFileName().split(".")[0])
    Write-Verbose "Created temporary directory $tmpDir"
    #endregion

    #region Copy and compress

    foreach ($item in $list) {
        #get the folder without any drive letter
        Write-Verbose "Processing $item"
        $folder = (Split-Path $item) -replace "[A-Zaz]:\\", ""
        #create a temporary version
        Write-Verbose "Re-creating $folder"
        $tmpFolder = New-Item -Path $tmpdir -Name $folder -Force -ItemType Directory
        #copy the profile script to the target destination
        Write-Verbose "Copying $item to $tmpFolder"
        Copy-Item -Path $item -Destination $tmpFolder
    }

    Write-Verbose "Creating zip archive $Destination"
    Get-ChildItem -Path $tmpdir |
    Compress-Archive -DestinationPath $Destination -CompressionLevel Optimal -Force

    #endregion

    #region Cleanup
    If ($Passthru) {
        Get-Item $Destination
    }
    If (Test-Path $tmpDir) {
        Write-Verbose "Removing temporary location"
        Remove-Item $tmpDir -Force -Recurse
    }
    #endregion
}
