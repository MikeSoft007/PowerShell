Clear-Host
# Connect to Exchange Online

$searchName = "PurgeEmails"

$items = (Get-ComplianceSearch -Identity $searchName).Items
if ($items -gt 0) {​​​​​​​​
    $searchStatistics = Get-ComplianceSearch -Identity $searchName | Select-Object -Expand SearchStatistics | Convertfrom-JSON
    $sources = $searchStatistics.ExchangeBinding.Sources | Where-Object {​​​​​​​​ $_.ContentItems -gt 0 }​​​​​​​​
    Write-Host ""
    Write-Host "Total Items found matching query:" $items 
    Write-Host ""
    Write-Host "Items found in the following mailboxes"
    Write-Host "--------------------------------------"
    foreach ($source in $sources) {​​​​​​​​
        Write-Host $source.Name "has" $source.ContentItems "items of size" $source.ContentSize
    }​​​​​​​​
    Write-Host ""
    $iterations = 0;
    
    $itemsProcessed = 0
    
    while ($itemsProcessed -lt $items) {​​​​​​​​
        $iterations++
        Write-Host "Deleting items iteration $($iterations)"
        New-ComplianceSearchAction -SearchName $searchName -Purge -PurgeType HardDelete -Confirm:$false | Out-Null
        while ((Get-ComplianceSearchAction -Identity "$($searchName)_Purge").Status -ne "Completed") {​​​​​​​​ 
            Start-Sleep -Seconds 2
        }​​​​​​​​
        $itemsProcessed = $itemsProcessed + 10
        
        # Remove the search action so we can recreate it
        Remove-ComplianceSearchAction -Identity "$($searchName)_Purge" -Confirm:$false  
    }​​​​​​​​
}​​​​​​​​ else {​​​​​​​​
    Write-Host "No items found"
}​​​​​​​​
Write-Host ""
Write-Host "COMPLETED!"


