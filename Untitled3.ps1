

$UserEmail= "michael@wave38.tk"
$Mailbox = Get-Mailbox | Where {$_.PrimarySmtpAddress -eq $UserEmail}
#$Office365GroupsMember = Get-UnifiedGroup | where { (Get-UnifiedGroupLinks $_.Alias -LinkType Members | foreach {$_.name}) -contains $mailbox.Alias}
$Office365GroupsMember = Get-DistributionGroup -ResultSize unlimited | where { (Get-DistributionGroupMember $_.PrimarySmtpAddress | foreach {$_.name}) -contains $mailbox.Alias} 
$Office365GroupsMember | Format-Table -Property DisplayName, PrimarySmtpAddress
