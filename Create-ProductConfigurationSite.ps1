Import-Module WebAdministration

$iisAppPoolName = "ProductConfiguration"
$iisAppPoolDotNetVersion = "v4.0"
$iisAppName = "ProductConfiguration"
$directoryPath = "C:\inetpub\sites\ProductConfiguration"

if(-not (Test-Path $directoryPath))
{
    new-item $directoryPath -ItemType Directory -Force 
}

$appPool = New-WebAppPool -Name $iisAppPoolName
Push-Location IIS:\AppPools\

if (Test-Path $iisAppPoolName -pathType container)
{    
    $appPool.managedRuntimeVersion = $iisAppPoolDotNetVersion    
    $appPool.managedPipelineMode = "Classic"
    $appPool |Set-Item
}


New-Website -Name $iisAppName -Port 1000 -ApplicationPool $appPool.name -PhysicalPath $directoryPath -Force
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'ProductConfiguration' -filter "system.webServer/security/authentication/anonymousAuthentication" -name "enabled" -value "False"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST' -location 'ProductConfiguration' -filter "system.webServer/security/authentication/windowsAuthentication" -name "enabled" -value "True"

Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/ProductConfiguration'  -filter "system.webServer/aspNetCore" -name "processPath" -value ".\Rosen.ProductConfiguration.Web.exe"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/ProductConfiguration'  -filter "system.webServer/aspNetCore" -name "stdoutLogEnabled" -value "True"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/ProductConfiguration'  -filter "system.webServer/aspNetCore" -name "forwardWindowsAuthToken" -value "True"
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/ProductConfiguration'  -filter "system.webServer/aspNetCore" -name "Arguments" -value ""
Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/ProductConfiguration'  -filter "system.webServer/aspNetCore" -name "stdoutLogFile" -value ".\logs\stdout"


Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/ProductConfiguration'  -filter "system.webServer/handlers" -name "." -value @{name='aspNetCore';path='*';verb='*';modules='AspNetCoreModule';allowPathInfo='False'}
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST/ProductConfiguration'  -filter "system.webServer/aspNetCore/environmentVariables" -name "." -value @{name='ASPNETCORE_ENVIRONMENT';value='Production'}
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/aspNetCore/environmentVariables" -name "." -value @{name='ASPNETCORE_ENVIRONMENT';value='Production'}



#Create Firewall rule
$firewallRule = Get-NetFirewallRule -Name "AIMS_Product_Configuration" -ErrorAction SilentlyContinue
if(-not $firewallRule)
{
    New-NetFirewallRule -DisplayName "AIMS Product Configuration" -Name "AIMS_Product_Configuration" -Action Allow -Direction Inbound -Group "AIMS" -LocalPort "1000" -Enabled True -Protocol "TCP"
}

Stop-Website $iisAppName
Start-Website $iisAppName

Pop-Location