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
$env:SYSTEM_DEFAULTWORKINGDIRECTORY = "C:\Repos\INS\Installation"

$env:culture = "de"

$env:DATABASE = "DM_DE"

################
$PasswordDO = "beY-hUfReFeyE5Es"
$PasswordSDE = "beY-hUfReFeyE5Es"
$PasswordDBAdmin = "qkOH1itvwJhXzV1Qs2LP"

Push-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY


Invoke-DbaQuery -Query "ALTER SERVER ROLE [sysadmin] DROP MEMBER [sde]" -SqlInstance $env:SQLInstance


. C:\Repos\INS\Installation\New-Database.ps1 -OnlyDataModel


. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateUPDMGeoDatabase.py -arguments "UPDM2018.xml", "UPDM2018_con_null"

. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateUPDMGeoDatabase.py -arguments "IPL_UPDM2018.xml", "CGL_IPL",  "--ipl", "True"

. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateUPDMGeoDatabase.py -arguments "UPDM_2018_WGS84_20220622.xml", "UPDM_WGS84"

. .\New-Database.ps1 -OnlyDataModel

. .\Push-DataSeed.ps1

pop-location