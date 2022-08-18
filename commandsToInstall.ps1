# Extract version
# Define installation Variables
$AGSConnection = "C:\ContinuousIntegration\ConnectionFiles\lin0259.ags"
$AGSUrl = "https://lin0259.roseninspection.net/arcgis"
$AGSAdmin = "siteadmin"
$SMTPServer = "lin-smtp"
$SMTPPort = 25
$EmailFrom = "nima_dm@rosen-group.com"
$FMEServer = "http://lin0259:8081"
$FMEUser = "admin"
$ClientNetworkResource = "\\LIN0259\FME_NIMATemp"
$SQLInstance = "LIN0228"
$Database = "DM"
$UserDO = "DataOwner"
$UserDBAdmin = "SQLAdmin"

$AGSPassword = "siteadmin123"
$FMEPassword = "admin"
$PasswordDO = "beY-hUfReFeyE5Es"
$PasswordDBAdmin = "qkOH1itvwJhXzV1Qs2LP"
$

$version = get-content .\version.txt -totalcount 1
write-output "Version to be installed: $version"
Write-Output ("##vso[task.setvariable variable=ReleaseVersion;]$version")

# ArcGIS server configuration
. .\invoke-python.ps1 -script .\Arcpy\PublishGPService.py -arguments $AGSConnection, $AGSUrl/admin, $AGSAdmin, $SMTPServer, $SMTPPort, $EmailFrom, "--passwordAdmin", $AGSPassword

# FME configuration
. .\Set-FMEConfiguration.ps1 -Server $FMEServer -AdminUsername $FMEUser -AdminPassword (ConvertTo-SecureString -String $FMEPassword -AsPlainText -Force) -NetworkResource $ClientNetworkResource

# Update Database
$argum =@("--passwordDO",
"$PasswordDO",
"--passwordAdmin", 
"$PasswordDBAdmin",
"$pwd\Data",
"$SQLInstance",
"$Database",
"$UserDO",
"$UserDBAdmin"
)
. .\invoke-python.ps1 -PRO -script .\Arcpy\CreateGeoDatabaseIncrement.py -arguments $argum

# Change environment configuration on JSON files
$json = Get-Content -Raw -Path .\data\RAC_ADD_IN.json | ConvertFrom-Json

$json.Data.FME_SERVER = $FMEServer
$json.Data.ARCGIS_SERVER = "$AGSUrl/rest/services"
$json.Data.VERSION = $version.ToString()

$json |ConvertTo-Json | Set-Content -Path .\data\RAC_ADD_IN.json


# Load Seed data on Geodatabase
. .\Push-Dataseed.ps1 -SQLInstance $SQLInstance -SQLAdmin $UserDBAdmin -GeodatabaseName $Database -Password $PasswordDBAdmin -Owner $UserDO

# One time Migration script
. .\invoke-python.ps1 -PRO -script .\Arcpy\MoveInputDatasets.py -arguments $SQLInstance, $Database, $UserDO, $FMEUser, "--passwordDO", $PasswordDO, "--passwordFME", $FMEPassword





#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# FME configuration for several clients
$clients = @("Cyberdyne", "Soylent", "Umbrella", "Weyland")
foreach($client in $clients)
{
    $clientArg = @{
        Server = $FMEServer
        AdminUsername = $FMEUser
        AdminPassword = (ConvertTo-SecureString -String $FMEPassword -AsPlainText -Force)
        NetworkResource = "\\Lin0259\FME_Temp\$client"
        ClientName = $client
    }
    . .\Set-FMEConfiguration.ps1 @clientArg 
}



$client = "Umbrella"

$json = Get-Content -Raw -Path .\data\RAC_FME_WORKSPACE.json | ConvertFrom-Json

foreach($dat in $json.Data)
{
    $dat.REPOSITORY = $dat.REPOSITORY.Replace("NIMA", $client)
    if($dat.RESOURCE_FOLDER)
    {
        $dat.RESOURCE_FOLDER = $dat.RESOURCE_FOLDER.Replace("NIMA", $client)
    }
    if($dat.FAILURE_TOPIC)
    {
        $dat.FAILURE_TOPIC = $dat.FAILURE_TOPIC.Replace("NIMA", $client)
    }
    if($dat.SUCCESS_TOPIC)
    {
        $dat.SUCCESS_TOPIC = $dat.SUCCESS_TOPIC.Replace("NIMA", $client)
    }
}

$json |ConvertTo-Json | Set-Content -Path .\data\RAC_FME_WORKSPACE.json

. .\Push-Dataseed.ps1 -SQLInstance $SQLInstance -SQLAdmin $UserDBAdmin -GeodatabaseName DM_Scratch -Password $PasswordDBAdmin -Owner $UserDO


Invoke-DbaQuery -Query "ALTER SERVER ROLE [sysadmin] DROP MEMBER [sde]" -SqlInstance $SQLInstance

.\Set-DMEnvironment.ps1




