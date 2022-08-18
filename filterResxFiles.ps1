Push-Location C:\t\AIMS2\Rel\QA\18.1\Rosen

$resx = Get-ChildItem -Include *.resx -Recurse |where {$_.FullName -notlike "*.test*"}
$bulgar = $resx | where {$_.Name -like "*.bg.*"}
$russian = $resx | where {$_.Name -like "*.ru.*"}
$resxPure = $resx | where {$_.name -notlike "*.bg.*" -and $_.name -notlike "*.ru.*"}


$noTranslatedToBulgar = $resxPure | where {$bulgar.FullName -notcontains "$($_.DirectoryName)\$($_.Basename).bg$($_.extension)"}
$noTranslatedToRussian = $resxPure | where {$russian.FullName -notcontains "$($_.DirectoryName)\$($_.Basename).ru$($_.extension)"}

. C:\T\Users-Bog\CGLondono\LocalizationProt\VersioningSatllites\New-ResourceFile.ps1
# $noTranslatedToBulgar | New-ResourceFile -Language bg
$noTranslatedToRussian | New-ResourceFile -Language ru
