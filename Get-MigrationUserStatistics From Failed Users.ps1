$o365credential = Get-Credential
$o365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $o365credential -Authentication Basic -AllowRedirection
Import-PSSession $o365Session -DisableNameChecking -AllowClobber

$failed = Get-MigrationUser -ResultSize unlimited | where {$_.status -eq "Failed"};

if ( $failed -eq $null ) {
    Write-Host No Accounts have Failed at this time...
} else {
    $Activity = "Number of Accounts in ERROR: "+$failed.count;
    $i = 0;
    foreach ($user in $failed) { 
        $i++;
        Write-Progress -Activity $Activity -status "Processing: $i" -percentComplete ($i / $failed.count*100);
        Get-MigrationUserStatistics -Identity $user.Identity| Select BatchID, identity, state, status, *count*;
    };
    $Activity;
};

$synching = Get-MigrationUser -ResultSize unlimited | where {$_.status -ne 'synced' -and $_.status -ne 'failed' -and $_.status -ne 'Completed'};

if ( $synching -eq $null ) {
    Write-Host No Accounts Synching at this time...
} else {
    $Activity = "Accounts that are synching"+$synching.Count;
    $i = 0;
    foreach ($sync in $synching) { 
        $i++;
        Write-Progress -Activity $Activity -status "Processing: $i" -percentComplete ($i / $synching.count*100);
        Get-MigrationUserStatistics -Identity $sync.Identity| Select BatchID, identity, state, status, *count*;
        $Activity;
     };
};

Remove-PSSession $o365Session
