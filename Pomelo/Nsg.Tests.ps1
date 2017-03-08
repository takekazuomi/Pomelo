Import-Module "$PSScriptRoot/Pomelo" -Force


Describe "Import-PoAzNsgRuleCsv" {
    Context "simple csv" {
        $csv1=@"
name,protocol,sourceAddressPrefix,sourcePortRange,destinationAddressPrefix,destinationPortRange,access,priority,direction,enable,comment
rule1,tcp,*,*,*,8001,Allow,1000,Inbound,1,test comment
rule2,tcp,*,*,*,8002,allow,1100,Inbound,0,"test, comment"
rule3,tcp,*,*,*,8003,Allow,1200,Inbound,1,test comment
"@
        It "Should Return Rule[]" {
            $result = $csv1 | Import-PoAzNsgRuleCsv
            $result.Length | Should Be 2
            $result[0].name | Should Be "rule1"
            $result[1].name | Should Be "rule3"
            $result | ft | Out-Host
        }
    }
}

Describe "New-PoAzNgsTemplate" {
    Context "simple csv" {
        $csv1=@"
name,protocol,sourceAddressPrefix,sourcePortRange,destinationAddressPrefix,destinationPortRange,access,priority,direction,enable,comment
rule1,tcp,*,*,*,8001,Allow,1000,Inbound,1,test comment
rule2,tcp,*,*,*,8002,allow,1100,Inbound,0,"test, comment"
rule3,tcp,*,*,*,8003,Allow,1200,Inbound,1,test comment
"@
        It "Should Return Rule[]" {
            $rules = $csv1 | Import-PoAzNsgRuleCsv
            $result = New-PoAzNgsTemplate -Name "nsg1" -Rules $rules
            $result | ft | Out-Host
        }
    }
}


