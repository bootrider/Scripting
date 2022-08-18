
param(
    # TFS server    
    [string]
    $tfsServer,
    # Project
    [string]
    $project, 
    # release name    
    [string]
    $releaseName
)

function Invoke-GetCommand {
    param
    (
        $uri,
        $usedefaultcreds
    )

    $webclient = new-object System.Net.WebClient
    $webclient.Encoding = [System.Text.Encoding]::UTF8
	
    if ([System.Convert]::ToBoolean($usedefaultcreds) -eq $true) {
        Write-Verbose "Using default credentials"
        $webclient.UseDefaultCredentials = $true
    }
    else {
        Write-Verbose "Using SystemVssConnection personal access token"
        $vssEndPoint = Get-ServiceEndPoint -Name "SystemVssConnection" -Context $distributedTaskContext
        $personalAccessToken = $vssEndpoint.Authorization.Parameters.AccessToken
        $webclient.Headers.Add("Authorization" , "Bearer $personalAccessToken")
    }
    
    #write-verbose "REST Call [$uri]"
    try {
        write-Host $uri
        $webclient.DownloadString($uri)
    }
    catch [System.Net.WebException] {
        write-host $_.Exception.Message
    }
}

function Get-ReleaseDefinition {
    param
    (
        $tfsUri,
        $teamproject,
        $releaseName,
        $usedefaultcreds
    )

    Write-Verbose "Getting release definitions from server [$tfsUri/$teamproject]"

    # at present Jun 2016 this API is in preview and in different places in VSTS hence this fix up   
    $rmtfsUri = $tfsUri -replace ".visualstudio.com", ".vsrm.visualstudio.com/defaultcollection"
    $uri = "$($rmtfsUri)/$($teamproject)/_apis/release/definitions?api-version=3.0-preview"

    $jsondata = Invoke-GetCommand -uri $uri -usedefaultcreds $usedefaultcreds | ConvertFrom-Json
    $relDefinition = $jsondata.Value | Where-Object {$_.name -match $releaseName } | Select-Object -Property Id -First 1
    return $relDefinition  
}

function Get-Release {

    param
    (
        $tfsUri,
        $teamproject,
        $releaseid,
        $usedefaultcreds
    )

    Write-Verbose "Getting details of release [$releaseid] from server [$tfsUri/$teamproject]"

    # at present Jun 2016 this API is in preview and in different places in VSTS hence this fix up   
    $rmtfsUri = $tfsUri -replace ".visualstudio.com", ".vsrm.visualstudio.com/defaultcollection"
    $myDate = [datetime]::Today - [timespan]::new(5, 0, 0, 0) # minus 5 days

    $uri = "$($rmtfsUri)/$($teamproject)/_apis/release/releases?definitionId=$($releaseid)&expand=environments&maxCreatedTime=$($myDate.ToString("yyyy-MM-dd"))&api-version=3.0-preview"

    $jsondata = Invoke-GetCommand -uri $uri -usedefaultcreds $usedefaultcreds | ConvertFrom-Json
    $jsondata
}

$idTodelete = Get-ReleaseDefinition -tfsUri "https://tfs.roseninspection.net/tfs/bogcollection" -teamproject "aims2" -releaseName "Dev - FT2" -usedefaultcreds $true
$releasesCandidates = Get-Release -tfsUri  "https://tfs.roseninspection.net/tfs/bogcollection" -teamproject "aims2" -usedefaultcreds $true -releaseid $idTodelete.id

$releasesNonTouched = $releasesCandidates.Value| where {$_.createdOn -eq $_.modifiedOn}

foreach ($rel in $releasesNonTouched) {
    Write-Host "Deleting $($rel.name)"  
    
    try {
        $uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/releases/$($rel.Id)?api-version=3.0-preview"
        Invoke-WebRequest -Uri $uri -Method Delete -UseDefaultCredentials | Tee-Object  -Variable "MyResult"
        Write-Host $MyResult.StatusCode
    }  
    catch {
        $myEx = $_.Exception.Message
        Write-Host $myEx
        if ( $myEx -match "Bad Request" ) {                 
            $rel = Invoke-GetCommand -uri $uri -usedefaultcreds $true | ConvertFrom-Json
    
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
}

#$releasesToDelete.Value