Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.CoreHost.dll'
Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.Core.dll'
[ArcGIS.Core.Hosting.Host]::Initialize()

[ArcGIS.Core.Data.DatabaseConnectionProperties]$connectionProperties = [ArcGIS.Core.Data.DatabaseConnectionProperties]::new([ArcGIS.Core.Data.EnterpriseDatabaseType]::SQLServer)

$connectionProperties.AuthenticationMode = [ArcGIS.Core.Data.AuthenticationMode]::DBMS
$connectionProperties.Instance = "LIN0228"
$connectionProperties.Database = "UPDM2018"
$connectionProperties.User = "DataOwner"
$connectionProperties.Password = "beY-hUfReFeyE5Es"
#$connectionProperties.Version = "sde.DEFAULT"

$gdb =  [ArcGIS.Core.Data.Geodatabase]::new($connectionProperties); 

$versionManager = $gdb.GetVersionManager()