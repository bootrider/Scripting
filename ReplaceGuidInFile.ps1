$con = Get-Content "C:\Users\CGLondono\documents\visual studio 2013\Projects\testWixSetup\testWixSetup\PipelineCenter.wxs"

$con | ForEach-Object { $_ -replace "PUT-GUID-HERE", [guid]::NewGuid().ToString()} | Set-Content c:\temp\pipelinecenter_Guid.wxs