Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.CoreHost.dll'
Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.Core.dll'
[ArcGIS.Core.Hosting.Host]::Initialize()
$path = [ArcGIS.Core.Data.FileGeodatabaseConnectionPath]::new("C:\Users\CGLondono\AppData\Local\Temp\ArcGISProTemp16764\e5a9b860-80a6-4182-a5a4-83041ecc9e50\Default.gdb")

$databaseConnectionFile = New-Object ArcGIS.Core.Data.DatabaseConnectionFile -ArgumentList "C:\Temp\Rosen.NIMA.Etl_QA.sde"

# $databaseConnectionFile = New-Object ArcGIS.Core.Data.DatabaseConnectionFile -ArgumentList "U:\Documents\ArcGIS\Projects\connections\SQLAdmin_DMScratch_LIN0228.sde"

$gdb = [ArcGIS.Core.Data.Geodatabase]::new($databaseConnectionFile)

$versionManager = $gdb.GetVersionManager()
#$dateInDB = [System.DateTime]::Parse("2019-12-16 11:59")
$dateInDB = [System.DateTime]::Parse("2019-12-16 11:59")
$dateLocaltime = $dateInDB.ToLocalTime()
$dateUTC = $date.ToUniversalTime()

#$gdbOnTime = $versionManager.ConnectToMoment($dateInDB) #0 results
$gdbOnTime = $versionManager.ConnectToMoment($dateLocaltime) #0 results
#$gdbOnTime = $versionManager.ConnectToMoment($dateUTC) # 0 results


$method = [ArcGIS.Core.Data.Geodatabase].GetMethod("OpenDataset")
$closedmethod = $method.MakeGenericMethod([ArcGIS.Core.Data.Table])
#$table = $closedmethod.Invoke($gdb, "Nigthly_DM.DATAOWNER.RAC_PROJECT")
#$table = $closedmethod.Invoke($gdbOnTime, "TestOwner.RDM_REFERENCE_PUB")
$table = $closedmethod.Invoke($gdb, "TestOwner.RDM_REFERENCE_PUB")

$queryfilter = [ArcGIS.Core.Data.QueryFilter]::new()
$queryfilter.WhereClause = "OBJECTID=299308"

$archTable = $table.GetArchiveTable()
$searchArchTable = $archTable.Search($queryfilter, $false)


while($searchArchTable.MoveNext())
{
    if($searchArchTable.Current["OBJECTID"] -eq '299308')
    {
    Write-Host $searchArchTable.Current["INSPECTION_ID"]
    }
    Write-Host $searchArchTable.Current["OBJECTID"]
}



$searchCursor = $table.Search($queryfilter, $false)

while($searchCursor.MoveNext())
{
    if($searchCursor.Current["OBJECTID"] -eq '299308')
    {
    Write-Host $searchCursor.Current["INSPECTION_ID"]
    }
    Write-Host $searchCursor.Current["OBJECTID"]
}







$rowBuffer = $table.CreateRowBuffer()
$rowBuffer["PROJECT_NAME"] = "hola"
$rowBuffer["DATASET_SUMMARY"] = "mundo"
$row = $table.CreateRow($rowBuffer)


$rowBuffer = New-MockObject -Type "ArcGIS.Core.Data.RowBuffer"


$numbers = @(4143
2165
2043
2041
4168
2136
2137
6881
4201
20135
20136
20137
20138
104909
4205
20538
20539
102022
102023
102024
102011
4206
102071
5825
)

foreach($number in $numbers)
{

 [ArcGIS.Core.Geometry.SpatialReference]$sr = [ArcGIS.Core.Geometry.SpatialReferenceBuilder]::CreateSpatialReference($number)
 $sr
}

[ArcGIS.Core.Geometry.GeometryEngine]::Instance.GetPredefinedGeographicTransformationList()
 [ArcGIS.Core.Geometry.GeometryEngine]::Instance.GetPredefinedCoordinateSystemList([ArcGIS.Core.Geometry.CoordinateSystemFilter]::GeographicCoordinateSystem)

 Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.desktop.framework.dll'
 Add-type -path "C:\Program Files\ArcGIS\Pro\bin\Extensions\Mapping\ArcGIS.Desktop.Mapping.dll"