# Configuration
$ruleName = "Unverified Sender - Failed SPF/DMARC"
$spamScoreIncrement = 6  # Adjust this value (1-9) based on desired strictness
$Username = "EMAIL"
$Password = ConvertTo-SecureString 'PASSWORD' -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($Username, $Password)

# Spam Score Reference:
# SCL 5-6 = Spam folder
# SCL 7-8 = Quarantine (with default settings)
# SCL 9 = High confidence spam / Delete (with aggressive settings)

$Session = New-PSSession -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -ConfigurationName Microsoft.Exchange -Credential $credentials `
    -Authentication Basic -AllowRedirection

Import-PSSession $Session -AllowClobber

# Optional: Audit current connectors for TreatMessagesAsInternal
Write-Host "`nAuditing Inbound Connectors..." -ForegroundColor Cyan
$riskyConnectors = Get-InboundConnector | Where-Object {$_.TreatMessagesAsInternal -eq $true}
if ($riskyConnectors) {
    Write-Host "WARNING: Found connectors treating external mail as internal:" -ForegroundColor Red
    $riskyConnectors | Select-Object Name, Enabled, SenderDomains | Format-Table
}

$rule = Get-TransportRule | Where-Object {$_.Identity -eq $ruleName}

$ruleParams = @{
    Name = $ruleName
    Priority = 0
    HeaderContainsMessageHeader = "Authentication-Results"
    HeaderContainsWords = "spf=fail","spf=softfail","spf=permerror","spf=none","dmarc=fail"
    # Intentionally NO FromScope exclusion - catches the "misconfiguration" MS won't fix
    SetSCL = $spamScoreIncrement
    PrependSubject = "[UNVERIFIED SENDER] "
    SetHeaderName = "X-SPF-DMARC-Failed"
    SetHeaderValue = "TRUE"
    Comments = "Compensating control for Exchange Online default spoofing vulnerability. SCL=$spamScoreIncrement. Created by https://github.com/sparksbenjamin/base-secure-exchange"
}

if (!$rule) {
    Write-Host "`nRule not found, creating rule with SCL=$spamScoreIncrement" -ForegroundColor Green
    New-TransportRule @ruleParams
} else {
    Write-Host "`nRule found, updating rule with SCL=$spamScoreIncrement" -ForegroundColor Green
    Set-TransportRule -Identity $ruleName @ruleParams
}

Write-Host "`nCurrent Configuration:" -ForegroundColor Cyan
Write-Host "  Spam Score Increment: $spamScoreIncrement" -ForegroundColor Yellow
Write-Host "  Scope: ALL SENDERS (compensates for MS 'misconfiguration')" -ForegroundColor Yellow
Write-Host "  MS Support Status: 'Working as designed' (2021)" -ForegroundColor DarkGray

Remove-PSSession $Session
