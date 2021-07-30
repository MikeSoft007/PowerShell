

[CmdletBinding()]
param (
    [System.Management.Automation.PSCredential]$Credential,
    [switch]$ExcludeLegacyExchangePolicies = $True,
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelineByPropertyName = $True,Position=1)]
    $Identity,
    [switch]$IncludeInheritedPolicies,
    [string]$OutputFile
)

begin
{
    If (!(Get-Command Get-Mailbox -ea silentlycontinue))
    {
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
        Import-PSSession $Session
    }
    
    If (!(Get-Command Get-CaseHoldPolicy -ea silently continue))
    {
        $ComplianceSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid -Credential $Credential -Authentication Basic -AllowRedirection
        Import-PSSession $ComplianceSession -AllowClobber
    }
    
    # Check parameters
    If ($PSBoundParameters.ContainsKey('Identity') -and $MyInvocation.PipelineLength -eq 1)
    {
        [object[]]$Identity = Get-Mailbox $Identity
    }
    [pscustomobject]$ErrorData = @()
    [pscustomobject]$Data = @()
        
    # Exclude processing of legacy Exchange Retention Policies if
    # -ExcludeLegacyExchangePolicies is set. This checks for policies that have
    # policy tags with retention enabled.
    If (!($ExcludeLegacyExchangePolicies))
    {
        $LegacyRetentionPolicies = Get-RetentionPolicy
        $LegacyRetentionPoliciesWithRetentionEnabled = @()
        Get-RetentionPolicy | % {
            foreach ($tag in $_.RetentionPolicyTagLinks)
            {
                If ((Get-RetentionPolicyTag $Tag).RetentionEnabled -eq $True) { $LegacyRetentionPoliciesWithRetentionEnabled += $_.Name }
            }
        }
        $LegacyRetentionPoliciesWithRetentionEnabled = $LegacyRetentionPoliciesWithRetentionEnabled | Sort -Unique
    } # End If !$ExcludeLegacyExchangePolicies
    
    # Retrieve inherited policies created in the Security & Compliance Center.
    # This is determined by looking for policies where the ExchangeLocation is
    # specified as "All", since those policies are not stamped on the mailbox.
    If ($IncludeInheritedPolicies)
    {
        $InheritedPolicies = (Get-RetentionCompliancePolicy -DistributionDetail) | ? { $_.ExchangeLocation -match "All" -and $_.Enabled -eq $True -and $_.DistributionStatus -eq "Success" -and $_.Mode -eq "Enforce"}
    } # End If $IncludeInheritedPolicies
}
process
{
    If ($PSBoundParameters.ContainsKey('Identity') -and $MyInvocation.PipelineLength -eq 1)
    {
        $DisplayName = $Identity.Name
        $PrimarySmtp = $Identity.PrimarySmtpAddress
        $InPlaceHoldPolicies = $Identity.InPlaceHolds
        [bool]$LitigationHold = $Identity.LitigationHoldEnabled
        If ($Identity.RetentionPolicy -iin $LegacyRetentionPoliciesWithRetentionEnabled)
            {
            $ExoRetentionPolicy = $Identity.RetentionPolicy        
            }
    }
        
    Else
    {
        $DisplayName = $_.Name
        $PrimarySmtp = $_.PrimarySmtpAddress
        $InPlaceHoldPolicies = $_.InPlaceHolds
        [bool]$LitigationHold = $_.LitigationHoldEnabled
            If ($_.RetentionPolicy -iin $LegacyRetentionPoliciesWithRetentionEnabled)
            {
                $ExoRetentionPolicy = $_.RetentionPolicy
            }
        }
    
    # Process values that appear in InPlaceHoldPolicies
    Foreach ($pol in $InPlaceHoldPolicies)
    {
        # eDiscovery Cases
        if ($pol -match "UniH")
        {
            $Type = "eDiscoveryCase"
            $policy = $pol.Substring(4)
            try
            {
                $Data += Get-CaseHoldPolicy -Identity $Policy | Select `
                                                                       @{ N = "Username"; E = { $DisplayName } },
                                                                       @{ N = "Mail"; E = { $PrimarySmtp } },
                                                                       @{ N = "Hold Placed By"; E = { $_.Name } },
                                                                       @{ N = "Policy Guid"; E = { $Policy } },
                                                                       @{ N = "Case Name"; E = { (Get-ComplianceCase $_.CaseID).Name } },
                                                                       @{ N = "Case Guid"; E = { $_.CaseID } },
                                                                       @{ N = "Hold Type"; E = { $Type } },
                                                                       @{ N = "Delete Type";  E= { "N/A" } }
            }
            catch
            {
                $ErrorDetail = $_.Exception.Message.ToString()
                $ErrorData += @{
                    'Username'        = $DisplayName;
                    'Mail'            = $PrimarySmtp;
                    'ErrorMesage'   = $ErrorDetail
                }
            }
        }
        
        # Security & Compliance Center Retention Policies. These policies are
        # reflected in the "InPlaceHolds" property of a mailbox.
        if ($pol -match "^mbx")
        {
            $Type = "SecComplianceRetentionPolicy-Mailbox"
            $policy = $pol.Substring(3).Split(":")[0]
            $policyDeleteTypeValue = $pol.Substring(3).Split(":")[1]
            switch ($PolicyDeleteTypeValue)
            {
                1 { $PolicyDeleteType = "DeleteOnly" }
                2 { $PolicyDeleteType = "RetainNoDeleteAtExpiration" }
                3 { $PolicyDeleteType = "RetainAndDeleteAtExpiration"}
            }
            $Data += Get-RetentionCompliancePolicy $policy | select `
                                                                    @{ N = "Username"; E = { $DisplayName } },
                                                                    @{ N = "Mail"; E = { $PrimarySmtp } },
                                                                    @{ N = "Hold Placed By"; E = { $_.Name } },
                                                                    @{ N = "Policy Guid"; E = { $policy } },
                                                                    @{ N = "Case Name"; E = { "Not Applicable" } },
                                                                    @{ N = "Case Guid"; E = { "Not Applicable" } },
                                                                    @{ N = "Hold Type"; E = { $Type } },
                                                                    @{ N = "Delete Type"; E = { $PolicyDeleteType } }
        }
        if ($pol -match "^\-mbx")
        {
            $Type = "ExcludedSecComplianceRetentionPolicy"
            $policy = $pol.Substring(4).Split(":")[0]
            $policyDeleteTypeValue = $pol.Substring(3).Split(":")[1]
            switch ($PolicyDeleteTypeValue)
            {
                1 { $PolicyDeleteType = "DeleteOnly" }
                2 { $PolicyDeleteType = "RetainNoDeleteAtExpiration" }
                3 { $PolicyDeleteType = "RetainAndDeleteAtExpiration" }
            }
            $Data += Get-RetentionCompliancePolicy $policy | select `
                                                                    @{ N = "Username"; E = { $DisplayName } },
                                                                    @{ N = "Mail"; E = { $PrimarySmtp } },
                                                                    @{ N = "Hold Placed By"; E = { $_.Name } },
                                                                    @{ N = "Policy Guid"; E = { $policy } },
                                                                    @{ N = "Case Name"; E = { "Not Applicable" } },
                                                                    @{ N = "Case Guid"; E = { "Not Applicable" } },
                                                                    @{ N = "Hold Type"; E = { $Type } },
                                                                    @{ N = "Delete Type"; E = { $PolicyDeleteType } }
        }
        if ($pol -match "^skp")
        {
            $Type = "SecComplianceRetentionPolicy-Skype"
            $policy = $pol.Substring(3).Split(":")[0]
            $policyDeleteTypeValue = $pol.Substring(3).Split(":")[1]
            switch ($PolicyDeleteTypeValue)
            {
                1 { $PolicyDeleteType = "DeleteOnly" }
                2 { $PolicyDeleteType = "RetainNoDeleteAtExpiration" }
                3 { $PolicyDeleteType = "RetainAndDeleteAtExpiration" }
            }
            $Data += Get-RetentionCompliancePolicy $policy | select `
                                                                    @{ N = "Username"; E = { $DisplayName } },
                                                                    @{ N = "Mail"; E = { $PrimarySmtp } },
                                                                    @{ N = "Hold Placed By"; E = { $_.Name } },
                                                                    @{ N = "Policy Guid"; E = { $policy } },
                                                                    @{ N = "Case Name"; E = { "Not Applicable" } },
                                                                    @{ N = "Case Guid"; E = { "Not Applicable" } },
                                                                    @{ N = "Hold Type"; E = { $Type } },
                                                                    @{ N = "Delete Type"; E = { $PolicyDeleteType } }
        }
    } # End Foreach $pol in $InPlaceHoldPolicies
    
    # Check for Object's LitigationHold property. You can query this property
    # via Get-Mailbox and look for the LitigationHoldEnabled property.
    If ($LitigationHold -eq $True)
    {
        $Type = "LitigationHold"
        $Policy = "Mailbox Litigation Hold"
        $LitigationHoldData = @{
                    'Username' = $DisplayName;
                    'Mail' = $PrimarySmtp;
                    'Hold Placed By' = $Policy;
                    'Policy Guid' = "Not Applicable";
                    'Case Name'    = "Not Applicable";
                    'Case Guid'    = "Not Applicable";
                    'Hold Type'    = $Type;
                    'Delete Type' = "Not Applicable"
        }
        $LitigationHoldRowData = [pscustomobject]$LitigationHoldData
        $Data += $LitigationHoldRowData
    } # End If $LitigationHold
    
    # Include Inherited policies from the Security & Compliance Center. These
    # policies are not stamped on the mailbox.
    If ($IncludeInheritedPolicies)
    {
        foreach ($InheritedPolicy in $InheritedPolicies)
        {
            $Type = "SecComplianceRetentionPolicy (Inherited)"
            $Policy = $InheritedPolicy.Name
            $Guid = $InheritedPolicy.Guid
            $InheritedPolicyData = @{
                        'Username' = $DisplayName;
                        'Mail' = $PrimarySmtp;
                        'Hold Placed By' = $Policy;
                        'Policy Guid' = $Guid;
                        'Case Name'    = "Not Applicable";
                        'Case Guid'    = "Not Applicable";
                        'Hold Type'    = $Type;
                        'Delete Type' = "Undetermined"
            }
            $InheritedPolicyRowData = [pscustomobject]$InheritedPolicyData
            $Data += $InheritedPolicyRowData
        }
    } # End If IncludeInheritedPolicies
    
    # If parameter -ExcludeLegacyExchangePolicies is not set, check the legacy
    # Exchange policies to see what policies with retention are applied to the
    # mailbox.
    If (!($ExcludeLegacyExchangePolicies))
    {
        If ($ExoRetentionPolicy)
        {
            $Type = "LegacyRetentionPolicy"
            $Policy = $ExoRetentionPolicy
            $PolicyGuid = ($LegacyRetentionPolicies | ? { $_.Name -eq $Policy }).Guid
            $ExoRetentionPolicyData = @{
                        'Username' = $DisplayName;
                        'Mail' = $PrimarySmtp;
                        'Hold Placed By' = $Policy;
                        'Policy Guid' = $PolicyGuid;
                        'Case Name' = "Not Applicable";
                        'Case Guid'    = "Not Applicable";
                        'Hold Type'    = $Type;
                        'Delete Type' = "Not Applicable"
            }
            $ExoRetentionPolicyRowData = [pscustomobject]$ExoRetentionPolicyData
            $Data += $ExoRetentionPolicyRowData
        }
    } # If !$ExcludeLegacyExchangePolicies
    
    # Finally, check for DelayHold
    If ($Identity.DelayHoldApplied -eq $True)
    {
        $Type = "Delayed Hold"
        $DelayHoldPolicyData = @{
            'Username'          = $DisplayName;
            'Mail'              = $PrimarySmtp;
            'Hold Placed By'  = "DelayHoldProcess";
            'Policy Guid'      = "Not Applicable";
            'Case Name'          = "Not Applicable";
            'Case Guid'          = "Not Applicable";
            'Hold Type'          = $Type;
            'Delete Type'      = "Not Applicable"
        }
        $DelayHoldRowData = [pscustomobject]$DelayHoldPolicyData
        $Data += $DelayedHoldRowData
    }
}
End
{
    If ($OutputFile)
    {
        $Data | Export-Csv $OutputFile -Force -Confirm:$False -NoTypeInformation
        if ($ErrorData) { $ErrorData | Export-Csv $OutputFile+"_Errors.txt" -Force -Confirm:$false -NoTypeInformation }
    }
    Else
    {
        Write-Output $Data
    }
}

