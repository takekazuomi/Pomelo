Write-Host (Get-Location)

Import-Module "$PSScriptRoot/Pomelo" -Force

Set-StrictMode -Version Latest

# 
# using namespace System.Web;
#(0..100) | %{$s=-join (@(33)+(35..37)+(40..59)+@(61)+(63..91)+(93..122)+@(124)+@(126) | Get-Random -Count 50 | %{[char]$_});[HttpUtility]::JavaScriptStringEncode($s, $true)}

Describe "customscript" -Tag "customscript" {
    Context "Set-PoAzVMCustomScript" {
        It -Skip "Uris Validation Only" {
            $result = Set-PoAzVMCustomScript -ValidationOnly -ResourceGroupName kinmugicos02 -VMName kinmugicos02 -FileUris "http://foo","http://boo", "http://woo" -CommandToExecute "bash setup.sh" -Verbose
            $result
        }

        It "File Validation Only" {
            $param = @{
                ValidationOnly=$true
                ResourceGroupName="kinmugicos02"
                VMName="kinmugicos02"
                Files = @(".\azure-ssh.Tests.ps1")
                StorageAccountName = "kinmugifile02"
                ContainerName = "runtime"
                CommandToExecute = "bash setup.sh"
                Verbose=$true
            }
            $result = Set-PoAzVMCustomScript @param
            $result
        }
    }
}
