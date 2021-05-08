$Result=@()
$groups = Get-DistributionGroup -ResultSize Unlimited
$totalmbx = $groups.Count
$i = 1
$groups | ForEach-Object {
Write-Progress -activity "Processing $_.DisplayName" -status "$i out of $totalmbx completed"
$group = $_
Get-DistributionGroupMember -Identity $group.Name -ResultSize Unlimited | ForEach-Object {
$member = $_
$Result += New-Object PSObject -property @{GroupName = $group.DisplayName
Member = $member.Name
EmailAddress = $member.PrimarySMTPAddress
RecipientType= $member.RecipientType
GroupType= $_.GroupType
}}
$i++
}

$Result | Export-CSV "C:\Users\TestLab\Desktop\All_Groups\All-Distribution-Group-Members.csv" -NoTypeInformation -Encoding UTF8

$Groups1 = Get-UnifiedGroup -ResultSize Unlimited
$Groups1 | ForEach-Object {
$group = $_
Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members -ResultSize Unlimited | ForEach-Object {
New-Object -TypeName PSObject -Property @{
Group = $group.DisplayName
Member = $_.Name
EmailAddress = $_.PrimarySMTPAddress
RecipientType= $_.RecipientType
GroupType= $_.GroupType
}}} | Export-CSV "C:\Users\TestLab\Desktop\All_Groups\Office365GroupMembers.csv" -NoTypeInformation -Encoding UTF8

$getFirstLine = $true

get-childItem "C:\Users\TestLab\Desktop\All_Groups\*.csv" | foreach {
    $filePath = $_

    $lines = Get-Content $filePath  
    $linesToWrite = switch($getFirstLine) {
           $true  {$lines}
           $false {$lines | Select -Skip 1}

    }

    $getFirstLine = $false
    Add-Content "C:\Users\TestLab\Desktop\All_Groups\final_groups.csv" $linesToWrite
    }