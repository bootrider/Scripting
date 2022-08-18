# Development environment values

$env:USERDBADMIN = "SQLAdmin"
$env:USERDO = "DataOwner"
$env:SMTPPORT = "25"
$env:SMTPSERVER = "lin-smtp"
$env:SQLINSTANCE = "lin0228"

$env:EMAILFROM = "nima_dm@rosen-group.com"
$env:FMENETWORKRESOURCE = "\\LIN0259\FME_NIMATemp"
$env:FMESERVER = "http://lin0259:8081"
$env:FMEUSER = "admin"
$env:AGSADMIN = "siteadmin"
$env:AGSCONNECTION = "C:\ContinuousIntegration\ConnectionFiles\lin0259.ags"
$env:AGSURL = "https://lin0259.roseninspection.net/arcgis"


# folder with the installation package
$env:SYSTEM_DEFAULTWORKINGDIRECTORY = "C:\T\Repos\INS\Installation"

$env:culture = "de"

$env:DATABASE = "DM_DE"

################
$PasswordDO = "beY-hUfReFeyE5Es"
$PasswordSDE = "beY-hUfReFeyE5Es"
$PasswordDBAdmin = "qkOH1itvwJhXzV1Qs2LP"

Push-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY



$configFile = get-item "setup.json"
$json = Get-Content -Raw -Path $configFile.FullName | ConvertFrom-Json

$json.Database = "$($env:DATABASE)_UPDM2018"
$json.Culture = ""
$json.UPDMVersion = "2018"
$json.LocationReferenceSystem = "ALRS"

$json | ConvertTo-Json | Set-Content -Path $configFile.FullName

Invoke-DbaQuery -Query "ALTER SERVER ROLE [sysadmin] DROP MEMBER [sde]" -SqlInstance $env:SQLInstance

$argum = @("UPDM2018.xml",  "$($env:DATABASE)_UPDM2018")

. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateUPDMGeoDatabase.py -arguments $argum
. .\invoke-python.ps1 -PRO -script .\Arcpy\InstallDataModel.py





$configFile = get-item "setup.json"
$json = Get-Content -Raw -Path $configFile.FullName | ConvertFrom-Json

$json.Database = "$($env:DATABASE)_IPL"
$json.Culture = ""
$json.UPDMVersion = "2018"
$json.LocationReferenceSystem = "ALRS2"

$json | ConvertTo-Json | Set-Content -Path $configFile.FullName

Invoke-DbaQuery -Query "ALTER SERVER ROLE [sysadmin] DROP MEMBER [sde]" -SqlInstance $env:SQLInstance

$argum = @("IPL_UPDM2018.xml",  "$($env:DATABASE)_IPL", "--ipl", "True")

. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateUPDMGeoDatabase.py -arguments $argum

. .\invoke-python.ps1 -PRO -script .\Arcpy\InstallDataModel.py






$configFile = get-item "setup.json"
$json = Get-Content -Raw -Path $configFile.FullName | ConvertFrom-Json

$json.Database = "$($env:DATABASE)_DM"
$json.Culture = ""
$json.UPDMVersion = "2016"
$json.LocationReferenceSystem = "ALRS"

$json | ConvertTo-Json | Set-Content -Path $configFile.FullName

Invoke-DbaQuery -Query "ALTER SERVER ROLE [sysadmin] DROP MEMBER [sde]" -SqlInstance $env:SQLInstance

. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateGeoDatabase.py

. .\invoke-python.ps1 -PRO -script .\Arcpy\InstallDataModel.py