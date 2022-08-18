$argum =@("--passwordDO",
"$(PasswordDO)",
"--passwordAdmin", 
"$(PasswordDBAdmin)",
"$(System.DefaultWorkingDirectory)\DM-Build\NIMA_DM\Installation\Data",
"$(SQLInstance)",
"$(Database)_Scratch",
"$(UserDO)",
"$(UserDBAdmin)"
)



$SQLInstance = "LIN0228"
$database = "DM"
$userDBAdmin = "SQLAdmin"
$userDO = "DataOwner"
$PasswordDBAdmin = "qkOH1itvwJhXzV1Qs2LP"
$PasswordDO ="beY-hUfReFeyE5Es"

Push-Location C:\T\Repos\INS\Installation

Copy-Item -Path C:\t\repos\INS\GeoProcessingServices -Destination .\ -Force -Recurse

$args = @{
    SQLInstance = $($SQLInstance)
    Database = "$($Database)"
    UserDBAdmin = $($UserDBAdmin)
    PasswordDBAdmin = "$($PasswordDBAdmin)"
    UserDO = $($UserDO)
    PasswordDO = "$($PasswordDO)"
}

. .\set-DatabaseUpdate.ps1 @args

Pop-Location