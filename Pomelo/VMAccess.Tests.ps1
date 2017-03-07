Write-Host (Get-Location)

Import-Module "$PSScriptRoot/Pomelo" -Force

Set-StrictMode -Version Latest

Describe "vmaccess" {
    Context "Set-AzVMResetPassword" {
        # TODO mock here
        # Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $deployFile -Verbose:$verbose
        # New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $deployFile -Verbose:$verbose

        $password =  -join (@(33)+(35..37)+(40..59)+@(61)+(63..91)+(93..122)+@(124)+@(126) | Get-Random -Count 50 | %{[char]$_})
        It "Change Password Validation Only" {
            $result = Set-PoAzVMUserCredentials -ValidationOnly -ResourceGroupName kinmugiubt02 -VMName kinmugiubt02 -User "takekazu.omi" -Password $password -Verbose
            $result
        }

        It "Change Password" {
            $result = Set-PoAzVMUserCredentials -ResourceGroupName kinmugiubt02 -VMName kinmugiubt02 -User "takekazu.omi" -Password $password -Verbose
            $result
        }

        It "new user and key auth" {
            $pubid = Get-Content (join-path (split-path (Get-SshPath) -parent) "id_rsa.pub")
            $result = Set-PoAzVMUserCredentials -ResourceGroupName kinmugiubt02 -VMName kinmugiubt02 -User "takekazu.omi" -SshKey "$pubid" -Verbose
            $result
        }
    }
}

