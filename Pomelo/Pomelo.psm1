Get-ChildItem "$PSScriptRoot/Scripts/*.ps1" |
    ? { $_.Name -notlike "*.Tests.*" } |
    % { . $_.PSPath }

Import-Module PomeloSt -Force

Export-ModuleMember `
    -Function @(
        'Copy-PoSshId'
        'Decrypt-PoCmsContent'
        'Encrypt-PoCmsContent',
        'Get-PoAzKeylist',
        'Get-PoAzSshConfig'
        'Get-PoAzSshJumpboxConfig'
        'Get-PoAzSshRemoteDesktopFile'
        'Remove-PoAzVMUser'
        'Set-PoAzFileToBlob'
        'Set-PoAzVMCustomScript'
        'Set-PoAzVMUserCredentials'
        'Import-NsgRuleCsv'
    )

