﻿Write-Host (Get-Location)
Import-Module $PSScriptRoot/../PomeloSt/bin/Debug/PomeloSt -Force -Verbose
Set-StrictMode -Version Latest

Describe -Tag "sshconfig" "ssh config generator" {
    $config = @{
        Host = "192.168.11.31"
        Properties = @{
            HostName = "mylinux"
            User="vagrant"
            Port=22
            UserKnownHostsFile="/dev/null"
            StrictHostKeyChecking = "no"
            PasswordAuthentication= "no"
            IdentityFile = "~/.sshd/id_rsa"
            IdentitiesOnly = "yes"
            LogLevel = "FATAL"
        }
    }

    $result = $config | Invoke-PoTemplate -GroupPath $PSScriptRoot/st/sshconfig.stg -TemplateName host -Verbose
    Write-Host "result:" $result
}

Describe -Tag "mygroup" "mygroup" {
    $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st/mygroup.stg -TemplateName sometmp -arg1 "Value1" -Verbose
    Write-Host "result:" $result
}
