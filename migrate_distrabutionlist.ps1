function migrate_DL2o365
{
    
    Param
    (
        [string[]]$Distrabution_List
    )
    if ($Distrabution_List) {} else{exit}
    $dl = Get-ADObject -Filter "mail -eq '$Distrabution_List'" -Properties * 
    if ($dl){} else {write-host "NO DL FOUND!";exit}
    $members = Get-ADGroupMember -Identity $dl.ObjectGUID
    $Cred = Get-Credential
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
    Import-PSSession $Session
    #Import-Module ExchangeOnlineManagement
    #connect-exchangeonline -UserPrincipalName $O365_Account_Name -ShowBanner:$false
    New-DistributionGroup -Name $dl.Name -DisplayName $dl.DisplayName -ModeratedBy $dl.managedBy -PrimarySmtpAddress $dl.mail
    #$members | fl
    #$dl | fl
    Remove-PSSession $Session
}
