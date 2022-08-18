$builds = @()
$builds += "38995"
$builds += "39388"
$builds += "39407"
$builds += "38450"
$builds += "38522"
$builds += "38953"
$builds += "39520"
$builds += "39069"
$builds += "39148"
$builds += "39097"
$builds += "39484"
$builds += "39518"
$builds += "39493"
$builds += "39396"
$builds += "39492"
$builds += "38954"
$builds += "39521"
$builds += "39755"
$builds += "39775"
$builds += "39825"
$builds += "39879"
$builds += "39952"
$builds += "39990"
$builds += "39995"
$builds += "40070"
$builds += "40090"
$builds += "40099"
$builds += "40100"
$builds += "40101"
$builds += "40119"
$builds += "40248"
$builds += "40263"
$builds += "40277"
$builds += "40369"
$builds += "40386"
$builds += "40387"
$builds += "40390"
$builds += "40437"
$builds += "40440"
$builds += "40448"
$builds += "40460"
$builds += "40495"
$builds += "40537"
$builds += "40556"
$builds += "40562"
$builds += "40604"
$builds += "40652"
$builds += "40679"
$builds += "40684"
$builds += "40710"


foreach ($build in $builds) {

    $uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/build/builds/$build/changes?api-version=2.0"

    $wc = New-Object System.Net.WebClient
    $wc.Headers["Content-Type"] = $ContentType
    $wc.UseDefaultCredentials = $true
    $changesets = $wc.DownloadString($uri) | ConvertFrom-Json 

    Write-Host $build $changesets.Count

}

$uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/build/builds/40652/changes?api-version=2.0"

$wc = New-Object System.Net.WebClient
$wc.Headers["Content-Type"] = $ContentType
$wc.UseDefaultCredentials = $true
$changesets = $wc.DownloadString($uri) | ConvertFrom-Json 


$uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/tfvc/changesets/25216?includeDetails=true&includeWorkItems=true&api-version=3.0"
$wc = New-Object System.Net.WebClient
$wc.Headers["Content-Type"] = $ContentType
$wc.UseDefaultCredentials = $true
$details = $wc.DownloadString($uri) | ConvertFrom-Json 

$exception = $null
try {
    $uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/releases/722?api-version=3.0-preview"
    Invoke-WebRequest -Uri $uri -Method Delete -UseDefaultCredentials | Tee-Object  -Variable "MyResult"
}
catch {
    Write-Host $_.Exception.Message
    if ( $_.Exception.Message -match "(400) Bad Request" ) {        
        $wc = New-Object System.Net.WebClient
        $wc.Headers["Content-Type"] = $ContentType
        $wc.UseDefaultCredentials = $true
        $rel = $wc.DownloadString($uri) | ConvertFrom-Json   

        $appr = $rel.environments.postDeployApprovals |where {$_.approver.uniqueName -match $env:USERNAME} |Select-Object -Property Id

        $uriApproval = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/approvals/$($appr.id)?api-version=3.0-preview"
        
        $myBody = @{
            status  = "rejected"    
            comment = "automatic rejection"
        } | ConvertTo-Json
        
        $headerJSON = @{ "content-type" = "application/json;odata=verbose"} 
        Invoke-RestMethod -Uri $uriApproval -Method Patch -UseDefaultCredentials -Body $myBody -Headers $headerJSON | Tee-Object  -Variable "MyResult" 
        Invoke-WebRequest -Uri $uri -Method Delete -UseDefaultCredentials | Tee-Object  -Variable "MyResult" 
    }   
}




$uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/releases/770/environments/2592?api-version=3.0-preview"
$wc = New-Object System.Net.WebClient
$wc.Headers["Content-Type"] = $ContentType
$wc.UseDefaultCredentials = $true

$myBody = @{
    status                  = "abandoned"
    scheduledDeploymentTime = $null
    comment                 = $null
} | ConvertTo-Json

$headerJSON = @{ "content-type" = "application/json;odata=verbose"} 
$resultsInvoke += Invoke-RestMethod -Uri $uri -Method Patch -UseDefaultCredentials -Body $myBody -Headers $headerJSON | Tee-Object  -Variable "MyResult"  
$details = $wc.DownloadString($uri) | ConvertFrom-Json 


$uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/approvals/1426?api-version=3.0-preview"
$wc = New-Object System.Net.WebClient
$wc.Headers["Content-Type"] = $ContentType
$wc.UseDefaultCredentials = $true
# $details = $wc.DownloadString($uri) | ConvertFrom-Json 
$myBody = @{
    status  = "rejected"    
    comment = "automatic rejection"
} | ConvertTo-Json

$headerJSON = @{ "content-type" = "application/json;odata=verbose"} 
$resultsInvoke += Invoke-RestMethod -Uri $uri -Method Patch -UseDefaultCredentials -Body $myBody -Headers $headerJSON | Tee-Object  -Variable "MyResult"  
