# This quick script will search a specific directory or server for scripts that use the deprecated Azure AD Modules (Deprecation Date now set to June 2023)

# Replace "C:\Scripts" with the path to the directory containing your scripts
$directory = "C:\Scripts"

# Get a list of all cmdlets in AzureAD
$cmdlets = (Get-Command -Module AzureAD | Select-Object -ExpandProperty Name)

# Get a list of all script files in the directory
$files = Get-ChildItem $directory -Recurse -Include "*.ps1", "*.psm1", "*.psd1" -Exclude "*.dll"

# Iterate through each file
foreach ($file in $files) {

# Read the contents of the file into a variable
  $contents = Get-Content $file.FullName

# Iterate through each cmdlet in the array
  foreach ($cmdlet in $cmdlets) {

# Search the contents of the file for the cmdlet
    if ($contents -match $cmdlet) {
      # If the cmdlet is used, display the file name and cmdlet
      Write-Output "Cmdlet '$cmdlet' used in $($file.FullName)"
    }
  }
}
