Connect-ExchangeOnline 
#Set-InboundConnector "from spmsrvmx002" -TreatMessagesAsInternal $true

Get-TransportRule "RejectEmailOutside" | Export-Csv -Path C:\Users\TestLab\Desktop\PowerShell_Scrips\trans.csv -NoTypeInformation