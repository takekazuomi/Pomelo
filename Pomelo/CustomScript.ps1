using namespace System.Collections.Generic;

function deployResourceGroupDeployment {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
#        [Parameter(Mandatory=$true)]
#        [string]$VMName,
        [Parameter(Mandatory=$true)]
        [string]$Template,
        [switch]$ValidationOnly=$false
    )

    $verbose = ?? $PSBoundParameters.Verbose $false

    $deployFile = New-TemporaryFile 
    try{
        Set-Content -Path $deployFile -Value $Template -Encoding Ascii
        if($ValidationOnly){
            Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $deployFile -Verbose:$verbose
        }
        else {
            New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $deployFile -Verbose:$verbose
        }
        $result
    }
    finally{
        Remove-Item $deployFile -Force
    }
}

function Set-PoAzFileToBlob
{
    [CmdletBinding()]
    Param(
        [string]$StorageAccountName,
        [string]$ContainerName,
        [string]$SourceFile
    )

    $startTime=(Get-Date).AddMinutes(-15)
    $expiryTime=(Get-Date).AddDays(10)
    $permission="r"
    
    $source = Get-Item $SourceFile
    $storageContext = (Get-AzureRmStorageAccount | ?{$_.StorageAccountName -eq $StorageAccountName}).Context

    New-AzureStorageContainer -Name $ContainerName -Context $StorageContext -Permission Blob -ErrorAction SilentlyContinue > $null

    $result = Set-AzureStorageBlobContent -File $($source.FullName) -Blob $($source.Name) -Container $ContainerName -Context $storageContext -Force -ErrorAction Stop

    $signiture = New-AzureStorageContainerSASToken -Name $ContainerName -Context $StorageContext -Permission $permission -StartTime $startTime -ExpiryTime $expiryTime

    #"{0}{1}" -f $result.ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri, $signiture
    # debug
    $result.ICloudBlob.StorageUri.PrimaryUri.AbsoluteUri
}

function Set-PoAzVMCustomScript {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string]$VMName,
        [Parameter(ParameterSetName="Uri",Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]$FileUris,
        [Parameter(ParameterSetName="File", Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]$Files,
        [Parameter(ParameterSetName="File", Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$StorageAccountName,
        [Parameter(ParameterSetName="File", Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ContainerName,
        [string]$CommandToExecute,
        [int]$Timestamp=0,
        [switch]$ValidationOnly=$false
    )
    $verbose = ?? $PSBoundParameters.Verbose $false

    switch ($PsCmdlet.ParameterSetName) 
    { 
        "File" {
            $FileUris = $Files | %{
                Set-PoAzFileToBlob $StorageAccountName $ContainerName $_
            }
            break
        } 
    } 

    $config = @{
        TimeStamp=$Timestamp
        VMName = $VMName
        FileUris = $FileUris
        CommandToExecute = $CommandToExecute
    }
    $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st/customscript.stg -TemplateName customscript -config $config -Verbose:$verbose 
    Write-Verbose $result -Verbose:$verbose

    deployResourceGroupDeployment $ResourceGroupName $result -ValidationOnly:$ValidationOnly -Verbose:$verbose
}

function Get-PoAzKeylist {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
        [Parameter(Mandatory=$true)]
        [string]$StorageAccountName,
        [Parameter(Mandatory=$true)]
        [switch]$ValidationOnly=$false
    )
    $verbose = ?? $PSBoundParameters.Verbose $false

    $config = @{
        StorageAccount=$StorageAccountName
    }
    $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st/keylist.stg -TemplateName keylist -config $config -Verbose:$verbose 
    Write-Verbose $result -Verbose:$verbose

    deployResourceGroupDeployment $ResourceGroupName $result -ValidationOnly:$ValidationOnly -Verbose:$verbose
}

# https://docs.microsoft.com/ja-jp/azure/virtual-machines/virtual-machines-linux-extensions-customscript
# https://github.com/Azure/custom-script-extension-linux