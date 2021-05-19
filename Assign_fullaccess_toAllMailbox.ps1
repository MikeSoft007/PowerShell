#Script to assign full access permission to admin in all mailbox in tenant

# $Mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
$Mailboxes = Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'UserMailbox') -and (Alias -ne 'Admin')}
$Total_Mailboxes = $Mailboxes.Count
Write-Host "TOTAL MAILBOXES = $Total_Mailboxes"
$i = 0
$First = Read-Host 'Enter First Number'
$Last = Read-Host 'Enter Last Number'
if($null -eq $First -or $First -eq ""){
    Write-Host "You did not enter any number: therefore default value zero is used"
    $First = 0
}
if($null -eq $Last -or $Last -eq ""){
    Write-Host "You did not enter any number: therefore default value is $Total_Mailboxes"
    $Last = $Total_Mailboxes
}
foreach($Mailbox in $Mailboxes){
    $i++
    if(($i -ge $First) -and ($i -le $Last)){ 
        Start-Sleep -m 0.5;
        Write-Host $i ($Mailbox).UserPrincipalName
        # $ExportToCsv = Get-MailboxJunkEmailConfiguration -Identity $Mailbox.UserPrincipalName -ResultSize unlimited
       $traction = Add-MailboxPermission -Identity $Mailbox.UserPrincipalName -User michael@wave38.tk -AccessRights fullaccess -InheritanceType all -AutoMapping:$false
        # $ExportToCsv | Export-Csv -NoTypeInformation -Path .\Test.csv -Append
    }
    if ($i -eq $Last) {
        Write-Host "I am ending my shift :)"
        $i = 0
        break
    }
}
#EndRegion
