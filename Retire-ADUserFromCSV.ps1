# Note: This script is using another script which I have not yet shared and will not work on it's own!
# At best it can server as a collection of ideas on how it could look on your end.

# Import CSV with AD User Displayname set
$RetireUser = Get-Content C:\Temp\export.csv

# Define Internal Ticket number 
$TicketNumber = "23802345"

# Define internal requester
$Requester = "Firstname Lastname"

# Start ForEach loop for each user in the Variable
ForEach ($User in $RetireUser)
{
    # Convert username from displayname
    $UserSAMAccountName = Get-ADUser -Identity (Get-ADUser -filter {DisplayName -like $User})
    
    # Starting to retire current account    
    Write-Host "Retiring the account: $UserSamAccountName.SamAccountName"

    # Execute RetireAccount-Script with the necessary parameters
    .\RetireAccount.ps1 -Username $UserSAMAccountName.SamAccountName -Requester $Requester -Ticketnumber $TicketNumber

    # Done Retiring current account, loop will start again or exit.
    Write-Host "Done with Retiring $UserSamAccountName.SamAccountName, trying the next." -ForegroundColor Green
}
