$psake.use_exit_on_error = $true
properties {
    $currentDir = resolve-path .
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $baseDir = $psake.build_script_dir
    $version = "0.9"
    $nugetExe = "$baseDir\vendor\tools\nuget"
    $targetBase = "tools"
}

Task default -depends Clean, Build-Pomelo, Build-PomeloSt

Task Build-Pomelo {
    Set-Location "$baseDir"
    Copy-Item .\Pomelo\* .\build\Pomelo\ -Verbose -Recurse -Exclude "*tmp*", ".vs", "bin", "obj", "*.pssproj*", "*Tests*" -Force
    Set-Location $currentDir
}

Task SetEnvironment {
  Exec { & $env:VS140COMNTOOLS\vsvars32.bat }
}

Task Build-PomeloSt -depends SetEnvironment {
    Set-Location "$baseDir/PomeloSt"
    Exec { & "msbuild.exe" /nologo /t:Rebuild /p:Configuration=Release /ToolsVersion:14.0 }
    Set-Location $currentDir
}

Task Clean {
    Set-Location "$baseDir"
    rm -Force -Recurse .\build\Pomelo\* -Exclude ".gitignore" -Verbose
    rm -Force -Recurse .\build\PomeloSt\* -Exclude ".gitignore"  -Verbose
    Set-Location $currentDir
}