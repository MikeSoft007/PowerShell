

Import-Csv 'C:\Users\TestLab\Desktop\pswd.csv' | ForEach-Object {
$upn = $_."UserPrincipalName"
$tempPwd = $_."password"
Set-MsolUserPassword -UserPrincipalName $upn –NewPassword $tempPwd -ForceChangePassword $False
}