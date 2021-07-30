## Build parameters
$mailParams = @{
    SmtpServer                 = 'wave38-tk.mail.protection.outlook.com'
    Port                       = '25'
    #UseSSL                     = $true   
    From                       = 'michael@wave38.tk'
    To                         = 'tolu@wave38.tk'
    Subject                    = "Direct Send $(Get-Date -Format g)"
    Body                       = 'This is a test email using Direct Send'
    DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
}

## Send the email
Send-MailMessage @mailParams