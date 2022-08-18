Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.CoreHost.dll'
Add-Type -Path 'C:\Program Files\ArcGIS\Pro\bin\ArcGIS.Core.dll'
[ArcGIS.Core.Hosting.Host]::Initialize()

$databaseConnectionFile = New-Object ArcGIS.Core.Data.DatabaseConnectionFile -ArgumentList "C:\Temp\sqladmin_qa_lin0228.sde"

$gdb = [ArcGIS.Core.Data.Geodatabase]::new($databaseConnectionFile)

$versionManager = $gdb.GetVersionManager()


$dateInDB = [System.DateTime]::Parse("2020-02-12 08:00:15") #original
#$gdbOnTime = $versionManager.ConnectToMoment($dateInDB) #0 results

#$dateInDB = [System.DateTime]::Parse("2020-02-12 09:05")
$dateLocaltime = $dateInDB.AddSeconds(60).ToLocalTime()# 9:04
$gdbOnTime = $versionManager.ConnectToMoment($dateLocaltime) #0 results


$dateUTC = $dateInDB.ToUniversalTime() # 7:04
#$gdbOnTime = $versionManager.ConnectToMoment($dateUTC) # 0 results




$method = [ArcGIS.Core.Data.Geodatabase].GetMethod("OpenDataset")
$closedmethod = $method.MakeGenericMethod([ArcGIS.Core.Data.Table])
#$table = $closedmethod.Invoke($gdb, "Nigthly_DM.DATAOWNER.RAC_PROJECT")
$table = $closedmethod.Invoke($gdbOnTime, "TestOwner.RDM_REFERENCE_PUB")
#$table = $closedmethod.Invoke($gdb, "TestOwner.RDM_REFERENCE_PUB")

$queryfilter = [ArcGIS.Core.Data.QueryFilter]::new()
$guid = [guid]::new("0fb4cabf-99af-4e25-9b34-b3bec35f3096")
$queryfilter.WhereClause = "INSPECTION_ID='$guid'"


$table.GetCount($queryfilter)

$searchCursor = $table.Search($queryfilter, $false)

$i = 0
while($searchCursor.MoveNext())
{
    #if($searchCursor.Current["OBJECTID"] -eq '299308')
    #{
    #Write-Host $searchCursor.Current["INSPECTION_ID"]
    #}
    #Write-Host $searchCursor.Current["INSPECTION_ID"]
   $i++
}

Write-Host "My real counter is $i"