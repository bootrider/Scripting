using namespace System.IO

# 0. Define local structure 
$workFolder = $env:SYSTEM_DEFAULTWORKINGDIRECTORY
$deploymentFolder = "$workFolder\DM-Build\NIMA_DM"

$workFolder = "C:\Temp"
$deploymentFolder = "c:\temp\NIMA_DM"
push-location $workfolder

$source = New-Item -Path "$workFolder\Source" -Force -ItemType Directory  
$temporal = New-Item -Path "$workFolder\Temporal" -Force -ItemType Directory

# 1. Unzip the addins
[FileInfo[]] $orig = Get-ChildItem -Path $deploymentFolder -Include "Rosen.*.esriAddinX" -Recurse

foreach ($file in $orig)
{
    Push-Location $temporal\
    Copy-Item -Path $file -Destination ($file.BaseName + '.zip')
    Expand-Archive -Path ".\$($file.BaseName + '.zip')" -DestinationPath (Join-Path .\ -ChildPath $file.BaseName) 

    # 2. extract the .dll 
    $installPath = Join-Path $file.BaseName -ChildPath "Install"

    $resourcesReq = Get-ChildItem -Path $installPath -include "Rosen.*.dll" -Recurse

    $resourcesReq | Copy-Item -Destination $source -Force
    
}



Pop-Location
# 3. Extract the json files


$jsonFilesNames = @( "CodedValueDomains.json")

[FileInfo[]] $jsonFiles = Get-ChildItem -Path $deploymentFolder -Include $jsonFilesNames -Recurse

$jsonFiles | Copy-Item -Destination $source -Force

[Directory]::Delete($temporal, $true)

