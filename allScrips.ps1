Connect-ExchangeOnline 
#Set-InboundConnector "from spmsrvmx002" -TreatMessagesAsInternal $true

#Get-TransportRule "Restrict-General Email" | Export-Csv -Path C:\Users\TestLab\Desktop\PowerShell_Scrips\trans.csv -NoTypeInformation

#Get-OrganizationConfig |FL *Event*

#Set-OrganizationConfig -ShortenEventScopeDefault 2

#Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize:Unlimited | Select Identity,Alias,DisplayName


