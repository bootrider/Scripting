[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
$DatabasePattern ="STD_TNPI_161_20160802_"
$ServerSource ="BOGDB02\BOGDB02"
$ServerDestination ="BOGDB12"
$ShareBackup = "\\bog0009\DeploymentDropLocation\Databases"

# $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerSource

Find-DbaDatabase -SqlInstance $ServerSource -pattern $DatabasePattern | ForEach-Object{ 
    Copy-DbaDatabase -source $ServerSource -Database $_.Name -Destination $ServerDestination -backuprestore -NetworkShare $ShareBackup -WithReplace -NoBackupCleanup -Verbose
}


# foreach ($db in $srv.databases)
# {    
#     [String] $dbName = $db.Name.ToString()
#     if ($dbName.StartsWith($DatabasePattern)){ 
#         Copy-dbaDatabase -Source $ServerSource -Destination $ServerDestination -Databases $dbName -BackupRestore -NetworkShare $ShareBackup -WithReplace -NoBackupCleanup
#     }
# }