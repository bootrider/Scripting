function Get-ResponsibleMail
{
    $uri= "http://tfs.roseninspection.net:8080/tfs/BOGCollection//AIMS2/_apis/release/releases?releaseId=$env:RELEASE_RELEASEID&$Expand=environments&queryOrder=descending&api-version=3.0-preview"
    $wc = New-Object System.Net.WebClient
    $wc.Headers["Content-Type"] = $ContentType
    $wc.UseDefaultCredentials = $true
    $jsondata = $wc.DownloadString($uri) | ConvertFrom-Json 
    $enviro = $jsondata.environments |where {$_.name -eq $env:RELEASE_ENVIRONMENTNAME}
    $approvers = $enviro.preDeployApprovals | where {$_.status -eq "approved"}
    $thelastapprover=$approvers | Sort-Object -Descending trialnumber |  Select-Object -First 1 | Select-Object -ExpandProperty approver


    $responsible = $wc.DownloadString($thelastapprover.url) | ConvertFrom-Json 
    return $responsible.Properties.Mail
}

$env:RELEASE_RELEASEID=2403
$env:RELEASE_ENVIRONMENTNAME="Stakeholders"

Get-ResponsibleMail
