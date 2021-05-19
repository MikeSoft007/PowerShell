  
$searchDays = Read-Host -prompt "A device is considered 'stale' if it has not synchronised in how many days?"
$confirmation = Read-Host Read-Host "Devices that have not synchronised with Exchange since" (Get-Date).AddDays(-$searchDays) "will be deleted. Press Y to confirm"
if ($confirmation -eq 'Y') {
$staleDevices = Get-Mailbox | ForEach {Get-ActiveSyncDeviceStatistics -Mailbox:$_.Identity} | where {$_.LastSuccessSync -lt ((Get-Date).AddDays(-$searchDays))} | select -expand Identity
foreach ($device in $staleDevices) {Remove-MobileDevice -Identity $device -confirm:$false}
}
write-host "Aborted. You did not confirm the deletion." -ForegroundColor Red

$allDevice = Get-Mailbox -ResultSize unlimited | ForEach {Get-ActivesyncDeviceStatistics -Mailbox:$_.Identity } | where {$_.LastSuccessSync -lt ((Get-Date).AddDays(-60))} | fl

#Get all mobile devices in the org
$MobileDeviceList = Get-MobileDevice
 
 
$tim = foreach ($Device in $MobileDeviceList) {
    $Stats = Get-MobileDeviceStatistics -Identity $Device.Guid.toString()
    [PSCustomObject]@{
        Identity              = $Device.Identity -replace "\\.+"
        LastSuccessSync       = $Stats.LastSuccessSync
    }
}
$validDevices = $tim -lt ((Get-Date).AddDays(-60));
if ($validDevice){
write-host "This is the devices" $validDevice
}
write-host "Not valid"
foreach ($device in $validDevices) {
    Remove-MobileDevice -Identity $device -confirm:$false
}
