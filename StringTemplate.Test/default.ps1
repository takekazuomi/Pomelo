$psake.use_exit_on_error = $true
properties {
    $currentDir = resolve-path .
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    $baseDir = $psake.build_script_dir
    $version = "0.1"
}

Task default -depends Build, Test

Task Build {
    Set-Location "$baseDir"
    Exec { & "msbuild.exe" /nologo /t:build /p:Configuration=Debug /ToolsVersion:14.0 /v:m }
    Set-Location $currentDir
}

Task Test {
    Set-Location "$baseDir"
    Exec {& "$Env:APPDATA/nuget/packages/xunit.runner.console.2.2.0/tools/xunit.console.exe"  .\bin\Debug\StringTemplate.Test.dll}
    Set-Location $currentDir
}
