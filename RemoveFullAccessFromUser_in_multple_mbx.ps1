#Remove full access permission for a user in multiple mailbox

$allmbxs = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize:Unlimited | Select Identity,Alias,DisplayName
$i = 1
foreach ($mbx in $allmbxs) {
Write-Progress -activity "Processing user michael" -status "$i out of $totalmbxs completed"
Remove-MailboxPermission -Identity $mbx.Identity -User michael@wave38.tk -AccessRights FullAccess -InheritanceType All -Confirm:$false
$i++
}