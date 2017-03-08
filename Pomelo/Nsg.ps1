#Require -Version 5.0
using namespace System.Collections.Generic

function toCamelCase{
    Param([string]$name)
    $c=$name.ToLower().ToCharArray()
    if($c.Length -gt 0){
        $c[0]=[Char]::ToUpper($c[0])
    }
    -join $c
}

class Nsg {
    [string]$Name
    [List[Rule]]$SecurityRules

    Nsg([string]$Name,[List[Rule]]$SecurityRules){
        $this.Name= $Name
        $this.SecurityRules=$SecurityRules
    }
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

function Import-PoAzNsgRuleCsv
{
    [OutputType([Rule[]])]
    Param(
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        [PSObject[]]$InputObject
    )
    [Rule[]]($InputObject | ConvertFrom-Csv | Select $filter|?{$_.Enable})
}

function New-PoAzNgsTemplate
{
    [OutputType([string])]
    Param(
        [string] $Name,
        [Rule[]] $Rules
    )
    $verbose = ?? $PSBoundParameters.Verbose $false

    $nsg = [Nsg]::new($Name, $Rules)

    $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st/nsg.stg -TemplateName template -config $nsg -Verbose:$verbose 
    $result
}

# [Rule[]]($csv | ConvertFrom-Csv | Select @{Name="enable";Expression={$_.enable -ne 0}},name)

