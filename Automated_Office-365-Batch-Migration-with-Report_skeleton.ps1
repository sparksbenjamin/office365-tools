# Declaration of variables to be used. Gets system date and time. Will name the batch based on the date, set the times to begin the migration as well as begin the completion of the batch and then converts those times to UTC so Exchange 365 can utilize the times provided. Sets a location for the migration batch CSV that will be uploaded to Office 365, identifying which users require migration.

$date = $(Get-Date -f MM-dd-yyyy)
$startstamp = "$date 9:00PM"
$finishstamp = "$date 11:59PM"
$finishtime = ([DateTime]$finishstamp).ToUniversalTime()
$starttime = ([DateTime]$startstamp).ToUniversalTime()
$file = "\\<servername>\<share>\<folder>\migrate-me_$date.csv"
$Batch = "Batch_$date"
$365uname = "yourserviceadmin@thebloodconnection.org"
$exchuname = "domain\yourserviceadmin"
$AESKey = Get-Content "\\server\folder\location\of\your\keyfile\Key_yourkeyfilename.key"
$pass = Get-Content "\\server\folder\location\of\your\passfile\yourpassfile.txt"
$securePwd = $pass | ConvertTo-SecureString -Key $AESKey

# Creation of Array to get users to migrate, based on the designated security group
$grpmem = @()
$grpmemdet = Get-ADGroupMember -Identity "<YourSecurityGroupHere>" -Recursive | Get-ADUser -Properties sAMAccountName | Select-Object sAMAccountName
$grpmem += $grpmemdet

# Validate users to be migrated by thier attribute. If the AD attribute msExchRemoteRecipientType is <not set> (or null), the user will be migrated
$migcheck = $grpmem | ForEach-Object{

$user = $_.sAMAccountName

Get-ADUser -Identity $user -Properties mail,msExchRemoteRecipientType | Select-Object mail, msExchRemoteRecipientType | Where {$_.msExchRemoteRecipientType -eq $null}

}

# Export the CSV required to create the migration batch
$migcheck | Select-Object @{expression={$_.mail}; label='EmailAddress'} | Export-CSV $file -NoTypeInformation

# Definition of Credentials required for the migration. This requires two sets of credentials: Exchange Admin credentials and O365 Admin credentials.
$365cred = New-Object System.Management.Automation.PSCredential -ArgumentList $365uname, $securePwd
$exadmin = New-Object System.Management.Automation.PSCredential -ArgumentList $exchuname, $securePwd

# Define the Administrators to be emailed about the migration batch
$emailadmins = "admin@yourdomain.com","admin2@yourdomain.com"

# Define the endpoint to be used in Office 365 for the migration
$endpoint = "Your-Migration-Endpoint-Name"

# Initiate the O365 powershell session
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid" -Credential $365cred -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession -AllowClobber

# Create the batch and set the parameters, based on the variables declared so far
$MigrationEndpointOnPrem = Get-MigrationEndpoint $endpoint
$OnboardingBatch = New-MigrationBatch -Name $Batch -SourceEndpoint $MigrationEndpointOnPrem.Identity -TargetDeliveryDomain <yourdomain>.onmicrosoft.com -CSVData ([System.IO.File]::ReadAllBytes("$file")) -StartAfter $starttime -CompleteAfter $finishtime -NotificationEmails $emailadmins

# Clean up the powershell session upon completion
Remove-PSSession outlook.office365.com
