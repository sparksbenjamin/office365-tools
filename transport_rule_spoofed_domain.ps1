$ruleName = "Unverified Sender - No SPF Validation"
$Username = "EMAIL"
$Password = ConvertTo-SecureString ‘PASSWORD’ -AsPlainText -Force
$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -ConfigurationName Microsoft.Exchange -Credential $credentials `
    -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber
$rule = Get-TransportRule | Where-Object {$_.Identity -contains $ruleName}
if (!$rule) {
    Write-Host "Rule not found, creating rule" -ForegroundColor Green
    New-TransportRule -Name $ruleName -Priority 1 -HeaderContainsMessageHeader "Authentication-Results"`
    -HeaderContainsWords "spf=TempError","spf=PermError","spf=None","spf=Neutral","spf=SoftFail","spf=Fail"`
    -PrependSubject "[Unverified Sender] "
    -Quarantine True
    -Comments "Rule Created by https://github.com/sparksbenjamin/base-secure-exchange"
    
}
else {
    Write-Host "Rule found, updating rule" -ForegroundColor Green
    Set-TransportRule -Identity $ruleName -Priority 1 -HeaderContainsMessageHeader "Authentication-Results"`
    -HeaderContainsWords "spf=TempError","spf=PermError","spf=None","spf=Neutral","spf=SoftFail","spf=Fail"`
    -Comments "Rule Created by https://github.com/sparksbenjamin/base-secure-exchange"`
    -PrependSubject "[Unverified Sender] "
}
Remove-PSSession $Session
