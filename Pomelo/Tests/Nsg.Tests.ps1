Import-Module "$PSScriptRoot/armnsg"


$csv1=@"
name,protocol,sourceAddressPrefix,sourcePortRange,destinationAddressPrefix,destinationPortRange,access,priority,direction,enable,comment
rule1,tcp,*,*,*,8001,Allow,1000,Inbound,1,test comment
rule2,tcp,*,*,*,8002,allow,1100,Inbound,0,"test, comment"
"@

Describe "Get-Function" {
	Context "Function Exists" {
		It "Should Return" {
		
		}
	}
}