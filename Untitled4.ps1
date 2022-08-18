
# Development environment values

$USERDBADMIN = "SQLAdmin"
$USERDO = "DataOwner"
$SMTPPORT = "25"
$SMTPSERVER = "lin-smtp"
$SQLINSTANCE = "lin0228"

$EMAILFROM = "nima_dm@rosen-group.com"
$FMENETWORKRESOURCE = "\\LIN0259\FME_NIMATemp"
$FMESERVER = "http://lin0259:8081"
$FMEUSER = "admin"
$AGSADMIN = "siteadmin"
$AGSCONNECTION = "C:\Temp2\lin0259.ags"
$AGSURL = "https://lin0259.roseninspection.net/arcgis"


# folder with the installation package
$env:SYSTEM_DEFAULTWORKINGDIRECTORY = "C:\T\Repos\INS\droplocation\Installation"



################
$PasswordDO = "beY-hUfReFeyE5Es"
$PasswordSDE = "beY-hUfReFeyE5Es"
$PasswordDBAdmin = "qkOH1itvwJhXzV1Qs2LP"
$AGSPassword = "siteadmin123"

Push-Location $env:SYSTEM_DEFAULTWORKINGDIRECTORY


$hey = @($AGSConnection, "$AGSUrl/admin", $AGSAdmin, $SMTPServer, $SMTPPort, $EmailFrom, "--passwordAdmin", $AGSPassword, "en")
. .\invoke-python.ps1 -script .\Arcpy\PublishGPService.py -PRO -arguments "C:\Temp\MyConnection.ags", "https://MyServer.roseninspection.net/arcgis/admin", "siteadmin", "--passwordAdmin", "supersecretpwd"


# ArcGIS server configuration
. .\invoke-python.ps1 -script .\Arcpy\PublishGPService.py -PRO -arguments $AGSConnection, $AGSUrl/admin, $AGSAdmin, "--passwordAdmin", $AGSPassword, "--language", "de" 
