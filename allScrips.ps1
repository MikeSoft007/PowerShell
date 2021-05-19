#Connect-ExchangeOnline 
#Set-InboundConnector "from spmsrvmx002" -TreatMessagesAsInternal $true

#Get-TransportRule "Restrict-General Email" | Export-Csv -Path C:\Users\TestLab\Desktop\PowerShell_Scrips\trans.csv -NoTypeInformation

#Get-OrganizationConfig |FL *Event*

#Set-OrganizationConfig -ShortenEventScopeDefault 2

#Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize:Unlimited | Select Identity,Alias,DisplayName

#$user = Get-Mailbox -identity "michael@wave38.tk" | Select Identity,Alias,DisplayName,UserName
$allmbxs = Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize:Unlimited | Select Identity,Alias,DisplayName
$i = 1
foreach ($mbx in $allmbxs) {
Write-Progress -activity "Processing user michael" -status "$i out of $totalmbxs completed"
Remove-MailboxPermission -Identity $mbx.Identity -User michael@wave38.tk -AccessRights FullAccess -InheritanceType All -Confirm:$false
$i++
}

