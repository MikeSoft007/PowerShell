$UserEmail= "michael@wave38.tk"

$Mailbox_ = Get-Mailbox | Where {$_.PrimarySmtpAddress -eq $UserEmail}

$Groups = Get-DistributionGroup -ResultSize unlimited

$match_group = $Groups | where { (Get-DistributionGroupMember $_.PrimarySmtpAddress | foreach {$_.name}) -contains $Mailbox_.Alias}

$Total_Mailboxes = $Groups.Count
$Total_usrgroup = $match_group.count

Write-Host "TOTAL Distribution Groups = $Total_Mailboxes"
Write-Host "TOTAL Distribution Groups $UserEmail belongs = $Total_usrgroup"
$i = 0
$First = Read-Host 'Enter First Number'
$Last = Read-Host 'Enter Last Number'
if($null -eq $First -or $First -eq ""){
    Write-Host "You did not enter any number: therefore default value zero is used"
    $First = 0
}
if($null -eq $Last -or $Last -eq ""){
    Write-Host "You did not enter any number: therefore default value is $Total_Mailboxes"
    $Last = $Total_usrgroup
}
foreach($Mailbox in $match_group){
    $i++
    if(($i -ge $First) -and ($i -le $Last)){ 
        Start-Sleep -m 0.5;

        Write-Host $i ($Mailbox).Displayname
        $Result = New-Object PSObject -property @{ 
        GroupName = $Mailbox.DisplayName
        }
        $Result | Out-GridView
        $Result | Export-Csv -NoTypeInformation -Path "C:\Users\TestLab\Desktop\TheGroups.csv" -Append
    }
    if ($i -eq $Last) {
        Write-Host "FEMI we are done here :)"
        $i = 0
        break
    }
}
#EndRegion

