param([string]$csv="")

$O365credential = Get-Credential
$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365credential -Authentication Basic -AllowRedirection
Import-PSSession $O365Session -DisableNameChecking -AllowClobber

Import-CSV $csv | ForEach-Object {
Add-DistributionGroupMember -Identity $_.Group -Member $_.Email
}
