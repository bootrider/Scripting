using namespace System.IO

# 0. Define local structure 
$workFolder = $env:SYSTEM_DEFAULTWORKINGDIRECTORY
$deploymentFolder = "$workFolder\DM-Build\NIMA_DM"
$satellitePath = "\\linfile1\Share\Lingen\cglondono\tanslation"

$workFolder = "C:\Temp"
$deploymentFolder = "c:\temp\Rebuild\NIMA_DM"
push-location $workfolder

$translated = New-Item -Path "$workFolder\Translated" -Force -ItemType Directory  
$temporal = New-Item -Path "$workFolder\Temporal" -Force -ItemType Directory

Copy-Item -Path $deploymentFolder -Destination $translated -Recurse -Container


# 1. Unzip the addins
$cultures = Get-ChildItem -Path $satellitePath -Directory

[FileInfo[]] $orig = Get-ChildItem -Path $translated -Include "Rosen.*.esriAddinX" -Recurse


foreach ($file in $orig)
{
    Push-Location $temporal\
    Copy-Item -Path $file -Destination ($file.BaseName + '.zip')
    Expand-Archive -Path ".\$($file.BaseName + '.zip')" -DestinationPath (Join-Path .\ -ChildPath $file.BaseName) 

    # 2. extract the name of the dll's
    $installPath = Join-Path $file.BaseName -ChildPath "Install"
    $resourcesReq = Get-ChildItem -Path $installPath -include "Rosen.*.dll" -Recurse

    # 3. Create the culture folder in the add-in
    foreach($culture in $cultures)
    {
        New-Item "$installPath\$($culture.Name)" -ItemType Directory -Force

        $resourcesReq | foreach { Copy-Item -Path (Join-Path $satellitePath\$culture -ChildPath ($_.BaseName + ".resources.dll")) -Destination "$installPath\$culture" -Force -Container }
    }

    $zipDest = ".\$($file.BaseName + '.zip')"
    $addinDest = $file.Name
    
    Compress-Archive -Path ".\$($file.BaseName)\*" -DestinationPath $zipDest -Update
    
    Rename-Item -Path $zipDest -NewName $addinDest   
    
    copy-item -Path $addinDest -Destination $file -Force 
}



Pop-Location
# 3. Extract the json files


$jsonFilesNames = @( "CodedValueDomains.json")

[FileInfo[]] $jsonFilesTranslated = Get-ChildItem -Path $satellitePath -Include $jsonFilesNames -Recurse
[FileInfo[]] $jsonFilesOriginal = Get-ChildItem -Path $translated -Include $jsonFilesNames -Recurse

$foldersToAddTranslation = $jsonFilesOriginal.Directory.Parent | Select-Object -Unique 

foreach($f in $foldersToAddTranslation)
{
    $cultures | %{New-Item -Path $f.FullName -Name $_ -ItemType Directory -Force}
}

foreach($json in $jsonFilesNames)
{
    $origin = $jsonFilesTranslated | Where-Object {$_.Name -eq $json}
    $dest = $jsonFilesOriginal | Where-Object { $_.Name -eq $json}
    foreach($o in $origin)
    {
        copy-item -Path $o -Destination "$($dest.Directory.Parent.FullName)\$($o.Directory.Name)"
    }
}






 





[Directory]::Delete($temporal, $true)

