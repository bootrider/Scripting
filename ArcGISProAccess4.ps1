Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.CoreHost.dll'
Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.Core.dll'
[ArcGIS.Core.Hosting.Host]::Initialize()

[ArcGIS.Core.Data.DatabaseConnectionProperties]$connectionProperties = [ArcGIS.Core.Data.DatabaseConnectionProperties]::new([ArcGIS.Core.Data.EnterpriseDatabaseType]::SQLServer)

$connectionProperties.AuthenticationMode = [ArcGIS.Core.Data.AuthenticationMode]::DBMS
$connectionProperties.Instance = ""
$connectionProperties.Database = ""
$connectionProperties.User = ""
$connectionProperties.Password = ""

$gdb =  [ArcGIS.Core.Data.Geodatabase]::new($connectionProperties); 

$method = [ArcGIS.Core.Data.Geodatabase].GetMethod("OpenDataset")
$closedmethod = $method.MakeGenericMethod([ArcGIS.Core.Data.Table])

$table = $closedmethod.Invoke($gdb, "updm.RAC_ADD_IN")


$queryfilter = [ArcGIS.Core.Data.QueryFilter]::new()


$table.GetCount($queryfilter)
