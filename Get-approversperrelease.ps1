$env:RELEASE_RELEASEID = "3081"
$releasesUri = "http://tfs.roseninspection.net:8080/tfs/BOGCollection//AIMS2/_apis/release/releases?"
$releases = ((Invoke-WebRequest -Uri $releasesUri -Method Get -UseDefaultCredentials).content | ConvertFrom-Json).value |Select-Object -First 1

Write-host "Release $($releases.Name)" -ForegroundColor Green

$uri = "http://tfs.roseninspection.net:8080/tfs/BOGCollection//AIMS2/_apis/release/releases?releaseId=$($releases.id)&$Expand=environments&queryOrder=descending&api-version=3.0-preview"
$wc = New-Object System.Net.WebClient
$ContentType = "application/json"
$wc.Headers["Content-Type"] = $ContentType
$wc.UseDefaultCredentials = $true
$jsondata = $wc.DownloadString($uri) | ConvertFrom-Json
$environmentsNames = $jsondata.environments.name | Where-Object {$_ -match "QA"} 
foreach($environment in $environmentsNames)
{
    $enviro = $jsondata.environments |where {$_.name -eq $environment}
    $approvers = $enviro.preDeployApprovals | where {$_.status -eq "approved" -and $_.approvalType -eq "preDeploy"}
    $lastApprover = $approvers | Sort-Object -Descending id |  Select-Object -First 1 |Select-Object -ExpandProperty approvedby 
    
    write-host $environment $lastApprover.displayName
}

