#Start-Transcript

{ 
    param 
    ( 
        $Credential 
    ) 
     
    $UserCredential = $Credential 
     
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection 
     
    Import-PSSession $Session -Prefix "EOL" -AllowClobber 
} 

#format Date

$date = get-date -format d
$date = $date.ToString().Replace(“/”, “-”)

$days = (get-date).adddays(-60)

$output = ".\logs\" + "Clearpartnership" + $date + "_.txt"

$casm = get-casmailbox -resultsize unlimited

$casm | foreach-object{
$user = get-user $_.name
$devices = Get-ActiveSyncDeviceStatistics -Mailbox $_.Identity | Where-Object {$_.LastSuccessSync -le $days}

if($devices -ne $null)
{
$devices | foreach{
$deviicemod = $_.DeviceModel
$usrname = $user.name

Write-host  "processing....$usrname....Device....$deviicemod" -foreground green

Add-content $output "processing....$usrname....Device....$deviicemod"

Remove-ActiveSyncDevice ([string]$_.Guid) -confirm:$false
}
}
}
