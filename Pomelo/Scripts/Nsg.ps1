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

function toDirection{
    Param([string]$data)
    switch ($data) {
        "受信" {
            "Inbound"
        }
        "送信" {
            "Outbound"
        }
        default {
            $data
        }
    }
}

function toAsterisk{
    Param([string]$data)
    switch ($data) {
        "Any" {
            "*"
        }
        default {
            $data
        }
    }
}

Class Rule {
    [string]$name
    [string]$protocol
    [string]$sourcePortRange
    [string]$destinationPortRange
    [string]$sourceAddressPrefix
    [string]$destinationAddressPrefix
    [string]$access
    [int]$priority
    [string]$direction
    [bool]$enable
    [string]$comment
}

Class Nsg {
    [string]$templateFileName
    [string]$name
    [string]$subnet
    [List[Rule]]$securityRules
}

function resolvePath
{
    [OutputType([PathInfo])]
    Param([PathInfo]$Path)
    if(-not (Test-Path $Path)){
        return Resolve-Path (Join-Path $pwd $Path) -ErrorAction SilentlyContinue
    }
    return $Path
}

function Import-NsgRuleCsv {
    [OutputType([Rule[]])]
    Param(
        [string]$Path
    )
    $ErrorActionPreference = "Stop"

    $rules = Get-Content -Encoding UTF8 -Raw (resolvePath $Path) | ConvertFrom-Csv | %{
        if($_.enable -eq 1) {
            $rule = New-Object Rule
            $rule.name = $_.name
            $rule.direction = toDirection $_.direction
            $rule.priority = $_.priority
            $rule.sourceAddressPrefix = toAsterisk $_.sourceAddressPrefix
            $rule.sourcePortRange = toAsterisk $_.sourcePortRange
            $rule.destinationAddressPrefix = toAsterisk $_.destinationAddressPrefix
            $rule.destinationPortRange = toAsterisk $_.destinationPortRange
            $rule.protocol = toAsterisk (toCamelCase $_.protocol)
            $rule.access = $_.access
            $rule.enable = $_.enable
            $rule.comment1 = $_.comment
            $rule
        }
    }
    $rules
}

function test
{
    Param(
        [string]$Path
    )
    # get nsg data objects
    $config = Import-NsgRuleCsv $args

    # group by TemplateFileName and create template
    Remove-Item -verbose -force "tmp/*-template.json"
    $config | group-object  -Property name | % {
        $ofile = ("tmp/$($_.name)" -replace ".json", "")+"-template.json"
        Convert-StTemplate -GroupPath .\armnsg.stg -TemplateName template -configs $_.Group | Out-File -Encoding ascii -FilePath $ofile
    }
}




