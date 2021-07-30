################################################  
  
#Accept input parameters  
Param(  
    [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true)]  
    [string] $OutputFile 
)  
  
#Set default output file path if not passed.
if ([string]::IsNullOrEmpty($OutputFile) -eq $true) 
{ 
    $OutputFile = "C:\Users\TestLab\Desktop\o365-users-mfa-status.csv"      
}

$Result=@() 
Connect-MsolService
$users = Get-MsolUser -All
$users | ForEach-Object {
$user = $_
if ($user.StrongAuthenticationRequirements.State -ne $null){
$mfaStatus = $user.StrongAuthenticationRequirements.State
}else{
$mfaStatus = "Disabled" }
   
$Result += New-Object PSObject -property @{ 
UserName = $user.DisplayName
UserPrincipalName = $user.UserPrincipalName
MFAStatus = $mfaStatus
}
}
#Export user details to CSV.
#$Result | Export-CSV $OutputFile -NoTypeInformation -Encoding UTF8
$Result | Out-GridView
#Write-Host "Report exported successfully"  -ForegroundColor Yellow