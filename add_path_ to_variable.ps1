$oldPath=(Get-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINESystemCurrentControlSetControlSession ManagerEnvironment’ -Name PATH).Path
$newPath=$oldPath+’;C:\Temp\javafolder\apache-maven-3.3.9\bin’

Set-ItemProperty -Path ‘Registry::HKEY_LOCAL_MACHINESystemCurrentControlSetControlSession ManagerEnvironment’ -Name PATH –Value $newPath

[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Temp\javafolder\apache-maven-3.3.9\bin", [EnvironmentVariableTarget]::Machine)