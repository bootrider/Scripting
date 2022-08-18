Import-module dbatools
[System.IO.FileInfo]$dacDll = $null

function Verify-DACSupport
{
    $dacDllsPaths = @("C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\140\Microsoft.SqlServer.Dac.dll",
        "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\Microsoft.SqlServer.Dac.dll",
        "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\130\Microsoft.SqlServer.Dac.dll",
        "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\Extensions\Microsoft\SQLDB\DAC\120\Microsoft.SqlServer.Dac.dll",
		"C:\Program Files (x86)\Microsoft SQL Server\110\DAC\bin\Microsoft.SqlServer.Dac.dll")
	
	foreach ($path in $dacDllsPaths) {
		if ((Test-Path $path)) {
			$global:dacDll = New-Object System.IO.FileInfo($path)
			return $true
		}		
	}

	$dacDlls = Get-ChildItem -Path $env:ProgramFiles , ${env:ProgramFiles(x86)} -Include *.dac.dll -Recurse -ErrorAction SilentlyContinue | Sort-Object -Property $_.VersionInfo.FileVersion -Descending 
	if($dacDlls.Length -gt 0)
	{
		$dacDlls | ForEach-Object{ Write-Host $_.FullName $_.VersionInfo.FileVersion}
		$global:dacDll = $dacDlls | Select-Object -First 1
		return $true
	}
	
	return $false	
}

Verify-DACSupport

if ($dacDll) 
		{
            add-type -path $dacDll.FullName
        }

$servers= @(
	"BOG0004"	
	"BOGDB12"
	"BOGDB13"
	"BOGDB20"
	"BOGDB15"	
	"BOGDB02\BOGDB02"
	"BOGDB14"
	"BOGDB19"
)
	




foreach($srv in $servers)
{

$dbinstance= $srv

$sqlquery = "SELECT [instance_name]
	 	,[type_name]
	 	,[type_version]
	 	FROM [dbo].[sysdac_instances_internal]"
	
$invokeArgs = @{
		Query=$sqlQuery;
		ServerInstance=$dbInstance;
		Database="msdb";	
	}
	
$queryResult = Invoke-Sqlcmd @invokeArgs

$dbserver = Connect-DbaInstance -SqlInstance $dbinstance
$dbconnectionObject = $dbserver.ConnectionContext.SqlConnectionObject
$serverconnection = New-Object Microsoft.SqlServer.Management.Common.ServerConnection($dbconnectionObject)  
$serverconnection.Connect()  
$dacstore = New-Object Microsoft.SqlServer.Dac.DacServices($serverconnection)  


foreach($result in $queryResult)
{
    try
    {
        $dacstore.Unregister($result.instance_name)
    }
    catch [Microsoft.SqlServer.Dac.DacServicesException]
    {
        Write-Host "is not registered"
    }
}


}