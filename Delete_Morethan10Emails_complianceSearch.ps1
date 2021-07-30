For($i=1;$i -lt 100;$i++){
do
{
New-ComplianceSearchAction -SearchName testdelete2 -Purge -PurgeType HardDelete -Confirm:$false -Force;

Sleep 2
}
While($i -ge 100)

}
