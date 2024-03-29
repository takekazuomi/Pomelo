﻿# http://donovanbrown.com/post/i-get-an-error-trying-to-run-my-pester-test-with-powershell-tools-for-visual-studio-2015

Write-Host (Get-Location)
Import-Module $PSScriptRoot/../PomeloSt/bin/Debug/PomeloSt -Force -Verbose

Set-StrictMode -Version Latest

Describe -Tag "simple-parameter" "simple parameter test" {
    Context "Context template helloworld.st" {
        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld -name "Posh"

        It "Hello Posh" {
            (-join $result) | Should Be "Hello Posh"
        }

        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld -name @("foo","bar")

        It "Hello foo, bar" {
            (-join $result) | Should Be "Hello foo, bar"
        }

        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld -name @(0..6) 

        It "Hello 0, 1, 2, 3, 4, 5, 6" {
            (-join $result) | Should Be "Hello 0, 1, 2, 3, 4, 5, 6"
        }
    }
}

Describe -Tag "simple-json" "simple json option test" {
    Context "Context json quote helloworld.st" {
        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld -name "Posh" -Json

        It -Skip "Hello Posh" {
            (-join $result) | Should Be "Hello `"Posh`""
        }
    }
}

Describe -Tag "simple-pipe" "simple pipe test" {
    Context "Context template helloworld.st" {
        $result = "Posh" | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld
        It "Hello Posh" {
            (-join $result) | Should Be "Hello Posh"
        }

        $result =  @{name=@("foo","bar")} | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld -Verbose
        It "Hello foo, bar" {
            # It is an unexpected result, but SHOGANAI
            (-join $result) | Should Be "Hello System.Collections.Hashtable"
        }

        $result = @{name=@(0..6)} | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld -Verbose
        It "Hello 0, 1, 2, 3, 4, 5, 6" {
            # It is an unexpected result, but SHOGANAI
            (-join $result) | Should Be "Hello System.Collections.Hashtable"
        }
    }
}

Describe -Tag "simple-pipe2" "simple pipe test" {
    Context "Context template helloworld.st" {
        $result = @(0..6) | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName helloworld -Verbose
        It -Skip "Hello foo, bar" {
            (-join $result) | Should Be "Hello 0, 1, 2, 3, 4, 5, 6"
        }
    }
    Context "Context template string" {
        $result = @(0..6) | Invoke-PoTemplate -TemplateString "<name;separator=`",`">" -Properties "name" -Verbose
        It "0,1,2,3,4,5,6" {
            (-join $result) | Should Be "0,1,2,3,4,5,6"
        }
    }
}


Describe -Tag "multi-attr-param" "multiple top level attributes with parameter test" {
    Context "Context template message.st" {
        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName message -name "Posh" -message "Hello"

        It "with parameter -name Posh -message Hello" {
            (-join $result) | Should Be "Hello Posh"
        }

        $result = "Hello" | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName message -name "Posh"

        It "parameter and pipe Hello | -name Posh " {
            (-join $result) | Should Be "Hello Posh"
        }

        $result = "Hello" | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName message

        It "pipe Hello | " {
            (-join $result) | Should Be "Hello Hello"
        }
    }
}

Describe -Tag "nest-hash" "Nested Object Hash Test" {
    Context "Context hash template message.st" {
        $ha = @(
            @{FullName="Yamada Taro";Name="Taro"}
            @{FullName="Sato Hanako";Name="Hanako"}
            @{FullName="Suzuki Kenji";Name="Kenji"}
        )

        $result = $ha | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName namelist
        Write-Host "result:" $result

        It "by pipe" {
            (-join $result) | Should BeLike "*Yamada Taro*"
        }

        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName namelist  -name ($ha)
        Write-Host "result:" $result

        It "by parameter" {
            (-join $result) | Should BeLike "*Yamada Taro*"
        }
    }
}

Describe -Tag "nest-psc" "Nested Object PSCustomObject Test" {
    Context "Context PSCustomObject template message.st" {
        $ha = @(
            [PSCustomObject]@{FullName="Yamada Taro";Name="Taro"}
            [PSCustomObject]@{FullName="Sato Hanako";Name="Hanako"}
            [PSCustomObject]@{FullName="Suzuki Kenji";Name="Kenji"}
        )

        $result = $ha | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName namelist
        Write-Host "result:" $result

        It "by pipe" {
            (-join $result) | Should BeLike "*Yamada Taro*"
        }

        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName namelist  -name ($ha)
        Write-Host "result:" $result

        It "by parameter" {
            (-join $result) | Should BeLike "*Yamada Taro*"
        }
    }
}

Describe -Tag "nest-nest-psc" "Deep Nested Object PSCustomObject Test" {
    Context "Context PSCustomObject template message.st" {
        $ha = [PSCustomObject]@{FullName="Yamada Taro";Name="Taro"; Address=[PSCustomObject]@{Postal="100-0001";City="Wako"}}

        $result = $ha | Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName addresslist 
        Write-Host "result:" $result

        It "by pipe" {
            (-join $result) | Should BeLike "*Address: 100-0001, Wako*"
        }

        $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName addresslist  -name ($ha)
        Write-Host "result:" $result

        It "by parameter" {
            (-join $result) | Should BeLike "*Address: 100-0001, Wako*"
        }
    }
}


Describe -Tag "debug" "Nested Object PSCustomObject Test" {
    $ha = [PSCustomObject]@(
        [PSCustomObject]@{FullName="Yamada Taro";Name="Taro"}
        [PSCustomObject]@{FullName="Sato Hanako";Name="Hanako"}
        [PSCustomObject]@{FullName="Suzuki Kenji";Name="Kenji"}
    )

    $result = Invoke-PoTemplate -GroupPath $PSScriptRoot/st -TemplateName namelist  -name ($ha)
    Write-Host "result:" $result

    It "debug" -Skip {
        (-join $result) | Should BeLike "*Yamada Taro*"
    }
}



