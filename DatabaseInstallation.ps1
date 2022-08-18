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
$env:SYSTEM_DEFAULTWORKINGDIRECTORY = "C:\Temp\NIMA_DM\Installation"

$env:culture = "de"

$env:DATABASE = "DM_CG_de"

################
$PasswordDO = "beY-hUfReFeyE5Es"
$PasswordSDE = "beY-hUfReFeyE5Es"
$PasswordDBAdmin = "qkOH1itvwJhXzV1Qs2LP"

Push-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY

#########################

Invoke-DbaQuery -Query "ALTER SERVER ROLE [sysadmin] DROP MEMBER [sde]" -SqlInstance $env:SQLInstance


#######################
$argum = @("$env:SYSTEM_DEFAULTWORKINGDIRECTORY\DataModel\DataModel.json", # first errror!!!!!! verify the datamodel folder
    "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\Data",
    "$env:SQLInstance",
    "Nightly_$env:Database",
    "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\authorization.ecp",
    "$env:UserDO",
    "$env:UserDBAdmin",
    "--passwordDO",
    "$PasswordDO",
    "--passwordSDE",
    "$PasswordSDE",
    "--passwordAdmin",
    "$PasswordDBAdmin"
    "--culture" #Add- the culture parameter
    "$env:culture"
)
. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateGeoDatabase.py -arguments $argum

#################################
if ($LASTEXITCODE -eq 0) {
    $json = Get-Content -Raw -Path .\data\RAC_ADD_IN.json | ConvertFrom-Json

    $json.Data.FME_SERVER = $env:FMEServer
    $json.Data.ARCGIS_SERVER = "$env:AGSUrl/rest/services"

    $json | ConvertTo-Json | Set-Content -Path .\data\RAC_ADD_IN.json

    #########################

    . "$env:SYSTEM_DEFAULTWORKINGDIRECTORY\Push-Dataseed.ps1" -SQLInstance $env:SQLInstance -SQLAdmin $env:UserDBAdmin -GeodatabaseName "Nightly_$env:Database" -Password $PasswordDBAdmin -Owner $env:UserDO
}

pop-location