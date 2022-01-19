$data = Import-csv E:\photo.csv
$path = "E:\School_Logo.jpg"

#Import-csv E:\photo.csv | foreach-Object {Set-UserPhoto -Identity $_.UserPrincipalName -PictureData ([System.IO.File]::ReadAllBytes("E:\School_Logo.jpg"))} -Confirm:$false



$MSOLCred = Get-Credential
$ExSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/?proxymethod=rps -Credential $MSOLCred -Authentication Basic -AllowRedirection
$Import = Import-PSSession $ExSession -CommandName Set-UserPhoto -AllowClobber

Write-Host "Uploading user photos:"
$count = 0
try {
$data | ForEach {
 Write-Host "$($_.User)..." -nonewline
 try {
  Set-UserPhoto -Identity $_.UserPrincipalName -PictureData ([System.IO.File]::ReadAllBytes($path)) -Confirm:$false
  Write-Host " done" -f green
  $count++
 }
 catch [System.Exception] {
  Write-Host " failed!" -f red
 }
}
}
finally {
Remove-PSSession $ExSession
}
