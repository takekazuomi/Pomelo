#Require -Version 5.0

function toCamelCase{
    Param([string]$name)
    $c=$name.ToLower().ToCharArray()
    if($c.Length -gt 0){
        $c[0]=[Char]::ToUpper($c[0])
    }
    -join $c
}

class Rule {
    [string]$Name
    [ValidateSet("Tcp", "Udp","*")]
    [string]$Protocol
    [string]$SourcePortRange
    [string]$DestinationPortRange
    [string]$SourceAddressPrefix
    [string]$DestinationAddressPrefix
    [ValidateSet("Allow", "Deny")]
    [string]$Access
    [int]$Priority
    [ValidateSet("Inbound", "Outbound","*")]
    [string]$Direction
    [bool]$Enable
    [string]$Comment
}

$filter = [Rule]::new() | Get-Member -MemberType Properties | %{
    $name = $_.Name
    # Write-Host $name -ForegroundColor Cyan
    switch ($name){
        "Protocol" {@{Name="Protocol";Expression={toCamelCase $_.Protocol}}}
        "Enable" {@{Name="enable";Expression={$_.enable -ne 0}}}
        default {&{$name}.GetNewClosure()}
    }
}

function Import-NsgRuleCsv
{
    [OutputType([Rule[]])]
    Param(
        [PSObject[]]$InputObject
    )
    [Rule[]]($InputObject | ConvertFrom-Csv | Select $filter|?{$_.Enable})
}

# [Rule[]]($csv | ConvertFrom-Csv | Select @{Name="enable";Expression={$_.enable -ne 0}},name)

