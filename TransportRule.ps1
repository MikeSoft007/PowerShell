# Set the path to your CSV file containing the list of allowed senders
$csvFilePath = "C:\Users\micha\OneDrive\Desktop\uss.csv"

# Read the CSV file to retrieve the allowed senders
$allowedSenders = (Import-Csv -Path $csvFilePath).EmailAddress

# Set the rule conditions
$conditions = @{
    'From' = $allowedSenders
}

# Set the rule actions
$actions = @{
    'RejectMessageReasonText' = 'User blocked from sending Outside'
    'RejectStatusCode' = '5.7.1'
}

# Create the transport rule
New-TransportRule -Name 'Block Outside Senders' -Priority '0' -FromScope 'NotInOrganization' -SentToScope 'NotInOrganization' -FromAddressMatchesPatterns $conditions['From'] -RejectMessageReasonText $actions['RejectMessageReasonText'] -RejectMessageEnhancedStatusCode $actions['RejectStatusCode']
