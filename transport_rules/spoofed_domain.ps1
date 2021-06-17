$ruleName = "Unverified Sender - No SPF Validation - SELF SPOOFING"
$DOMAIN = @('EXAMPLE.COM')
$Username = "EMAIL"
$Password = ConvertTo-SecureString ‘PASSWORD’ -AsPlainText -Force
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -ConfigurationName Microsoft.Exchange -Credential $credentials `
    -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber
$rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
if (!$rule) {
    Write-Host "Rule found, updating rule" -ForegroundColor Green
    Set-TransportRule -Identity $ruleName -Priority 1  -Quarantine $True -SenderDomainIs $DOMAIN -RecipientDomainIs $DOMAIN -HeaderContainsMessageHeader "Authentication-Results"`
    -HeaderContainsWords "spf=TempError","spf=PermError","spf=None","spf=Neutral","spf=SoftFail","spf=Fail"`
    -Comments "Rule Created by https://github.com/sparksbenjamin/base-secure-exchange"
    
}
else {
    Write-Host "No Rule found, Creating rule" -ForegroundColor Green
    Set-TransportRule -Identity $ruleName -Priority 1  -Quarantine $True -SenderDomainIs $DOMAIN -RecipientDomainIs $DOMAIN -HeaderContainsMessageHeader "Authentication-Results"`
    -HeaderContainsWords "spf=TempError","spf=PermError","spf=None","spf=Neutral","spf=SoftFail","spf=Fail"`
    -Comments "Rule Created by https://github.com/sparksbenjamin/base-secure-exchange"
}
Remove-PSSession $Session
