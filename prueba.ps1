$exception=$null
try {
    $uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/releases/722?api-version=3.0-preview"
    Invoke-WebRequest -Uri $uri -Method Delete -UseDefaultCredentials | Tee-Object  -Variable "MyResult"
}
catch {
    $myEx = $_.Exception.Message
    Write-Host $myEx
    if ( $myEx -match "Bad Request" ) {        
        $wc = New-Object System.Net.WebClient
        $wc.Headers["Content-Type"] = $ContentType
        $wc.UseDefaultCredentials = $true
        $rel = $wc.DownloadString($uri) | ConvertFrom-Json   

        $appr = $rel.environments.postDeployApprovals |where {$_.approver.uniqueName -match $env:USERNAME} |Select-Object -Property Id

        $uriApproval = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/approvals/$($appr.id)?api-version=3.0-preview"
        
        $myBody=@{
            status = "rejected"    
            comment= "automatic rejection"
        } | ConvertTo-Json
        
        $headerJSON = @{ "content-type" = "application/json;odata=verbose"} 
        Invoke-RestMethod -Uri $uriApproval -Method Patch -UseDefaultCredentials -Body $myBody -Headers $headerJSON | Tee-Object  -Variable "MyResult" 
        Invoke-WebRequest -Uri $uri -Method Delete -UseDefaultCredentials | Tee-Object  -Variable "MyResult" 
    }   
}