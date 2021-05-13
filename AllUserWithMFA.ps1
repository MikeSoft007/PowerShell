Write-Host "Finding Azure Active Directory Accounts..."
Connect-MsolService
$Users = Get-MsolUser -All | ? { $_.UserType -ne "Guest" }
$Report = [System.Collections.Generic.List[Object]]::new() # Create output file
Write-Host "Processing" $Users.Count "accounts..." 
ForEach ($User in $Users) {
    $MFAMethods = $User.StrongAuthenticationMethods.MethodType
    $MFAEnforced = $User.StrongAuthenticationRequirements.State
    #$MFAPhone = $User.StrongAuthenticationUserDetails.PhoneNumber
    $DefaultMFAMethod = ($User.StrongAuthenticationMethods | ? { $_.IsDefault -eq "True" }).MethodType
    If (($MFAEnforced -eq "Enforced") -or ($MFAEnforced -eq "Enabled")) {
        Switch ($DefaultMFAMethod) {
            "OneWaySMS" { $MethodUsed = "One-way SMS" }
            "TwoWayVoiceMobile" { $MethodUsed = "Phone call verification" }
            "PhoneAppOTP" { $MethodUsed = "Hardware token or authenticator app" }
            "PhoneAppNotification" { $MethodUsed = "Authenticator app" }
        }
    }
    Else {
        $MFAEnforced = "Not Enabled"
        $MethodUsed = "MFA Not Used" 
    }
  
    $ReportLine = [PSCustomObject] @{
        User        = $User.UserPrincipalName
        Name        = $User.DisplayName
        MFAUsed     = $MFAEnforced
        MFAMethod   = $MethodUsed 
    }
                 
    $Report.Add($ReportLine) 
}
Write-Host "Report is inC:\Users\TestLab\desktop\MFAUsers.CSV"
$Report | Select Name, MFAUsed, MFAMethod | Sort Name | Out-GridView
$Report | Sort Name | Export-CSV -NoTypeInformation C:\Users\TestLab\desktop\MFAUsers.csv



Get-mailboxfolderpermission -Identity michael@wave38.tk