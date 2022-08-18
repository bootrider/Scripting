Get-ChildItem -Path C:\Temp\bulgar\bg\bg -Directory | ? {$_.GetFiles().Count -eq 0} | Remove-Item



$files = Get-ChildItem -Path C:\Temp\bulgar\bg\bg\ -Include *.resx -Recurse 
foreach($file in $files)
{
    $folders = $file.BaseName.Split(".")
    if($folders.Length -gt 1)
    {
    Rename-Item -Path $file -NewName $file.Name.replace("$($folders[0]).", [String]::Empty)
    }
}

Push-Location C:\t\AIMS2\Dev\FT2\Rosen

$files = Get-ChildItem -Path C:\Temp\bulgar\bg\bg -Include *.resx -Recurse
$folders = Get-ChildItem -Path C:\Temp\bulgar\bg\bg -Directory
$projectfiles = $folders | %{"$($_.Name).csproj"}
$tfExec = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\TF.exe"  
$table = @{}
foreach($folder in $folders.Name)
{
    $project = Get-ChildItem -Include "$folder.csproj" -Recurse 
    $innerfiles = $files | ? {$_.DirectoryName -match $folder} 
    $filesToReplace = Get-ChildItem -Path $project.DirectoryName -Include $innerfiles.Name -Recurse  
    
    foreach ($innerfile in $innerfiles) {
        $dest = $filesToReplace | ?{$_.Name -eq $innerfile.Name} |select -First 1
        $table.Add($innerfile, "$($dest.DirectoryName)\$($dest.BaseName).bg$($dest.Extension)")         
    }    
    
}

foreach ($item in $table.Keys) {
    if (Test-Path $table[$item]) {
        $tfArgs = @("checkout", $table[$item])				
    & $tfExec $tfArgs    
    
    Copy-Item -Path $item -Destination $table[$item]        
    }
    
}

Pop-Location