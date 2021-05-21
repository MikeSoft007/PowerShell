$Phoneinfo = @()
$MobileDeviceList = Get-MobileDevice -ResultSize unlimited 
foreach ($Device in $MobileDeviceList) {
    $Stats = Get-MobileDeviceStatistics -Identity $Device.Guid.toString() | Select-Object LastSuccessSync
    $LastSuccSynDate = $Stats.LastSuccessSync
    #set month to check for to two months but I used 366 to test for devices for a year old
    $MonthsBack = (Get-Date).AddDays(-366)
    #Get any device that the last sync time is equal to 2 months ago but not less from the current month returning 'true'
    if ($LastSuccSynDate -ge $MonthsBack) {
        Write-Output $true
        $Phoneinfo += [pscustomobject]@{
            
            "Device UserMailbox Name" = $Device.UserDisplayName
    
            "Device DeviceID" = $Device.DeviceID 
        
            "Device LastSuccSynDate" = $LastSuccSynDate
    
            "Device OS" = $Device.DeviceOS
    
            "Device Type" = $Device.DeviceType
    
            "Device UserAgent" = $Device.DeviceUserAgent
    
            "Device Model" = $Device.DeviceModel 
            "Device Guid" = $Device.Guid
            "Device Date Ref status" = "true"
        }  
        
    }
    else { 
        Write-Output $false
        $Phoneinfo += [pscustomobject]@{
            
            "Device UserMailbox Name" = $Device.UserDisplayName
    
            "Device DeviceID" = $Device.DeviceID 
        
            "Device LastSuccSynDate" = $LastSuccSynDate
    
            "Device OS" = $Device.DeviceOS
    
            "Device Type" = $Device.DeviceType
    
            "Device UserAgent" = $Device.DeviceUserAgent
    
            "Device Model" = $Device.DeviceModel
            "Device Guid" = $Device.Guid
            "Device Date Ref status" = "false"
        }  
    }
}
#EXport to CSV
$Phoneinfo | Export-Csv .\Phoneinfo.csv -NoTypeInformation
#You can hold on on running this code snippet till you confirm from the CSV if the value for "Device Date Ref status" matches what wants to be removed
foreach ($item in $Phoneinfo) {
    #check the if statement if the condition matches the value in the CSV that you desire "false in this case"
    if (($item)."Device Date Ref status" -like "false") {
        Write-Host "I am removing the device below `n"($item)."Device DeviceID" `n"that was signed in by the user below `n"($item)."Device UserMailbox Name" `n"where the last successful login was `n"($item)."Device LastSuccSynDate" `n`r
        #code to remove devices 
        Remove-MobileDevice -Identity ($item)."Device Guid".ToString() -Confirm:$false
    }
}