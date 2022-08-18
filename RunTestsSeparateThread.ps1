# Script that run the ExecuteTest in a different thread 

[Diagnostics.Process]::Start("powershell",".\ExecuteTests.ps1")

Write-Verbose "Check the C:\TEMP folder for a detailed log about the test execution" -Verbose