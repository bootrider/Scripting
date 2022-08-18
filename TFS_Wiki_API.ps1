$exception=$null
try {
    $tfsWiki ="https://tfs.roseninspection.net/tfs/bogcollection/aims2/_apis/wiki"
    $wikis = "$tfsWiki/wikis?api-version=4.1"
    $pages ="$tfsWiki/wikis/AIMS2.wiki/pages?api-version=4.1"
    $page191 ="$tfsWiki/wikis/AIMS2.wiki/pages?path=%2FROAIMS2%2FVersion%20History%2F19.1&includeContent=true&api-version=4.1"          
    
    $uri = "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/releases/722?api-version=3.0-preview"
    Invoke-WebRequest -Uri $page191 -Method Delete -UseDefaultCredentials | Tee-Object  -Variable "MyResult"
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
        Invoke-RestMethod -Uri $page191 -Method Patch -UseDefaultCredentials -Body $myBody -Headers $headerJSON | Tee-Object  -Variable "MyResult" 
        Invoke-WebRequest -Uri $uri -Method Delete -UseDefaultCredentials | Tee-Object  -Variable "MyResult" 
    }   
}


#Invoke-RestMethod -Uri $page191 -Method get -UseDefaultCredentials  | Tee-Object  -Variable "MyResult" 

$tfsWiki ="https://tfs.roseninspection.net/tfs/bogcollection/aims2/_apis/wiki"
    $wikis = "$tfsWiki/wikis?api-version=4.1"
    $pages ="$tfsWiki/wikis/AIMS2.wiki/pages?api-version=4.1"
    $page191 ="$tfsWiki/wikis/AIMS2.wiki/pages?path=%2FROAIMS2%2FVersion%20History%2F20.1&includeContent=true&api-version=4.1" 
    try{

Invoke-WebRequest -Uri $page191 -Method get -UseDefaultCredentials | Tee-Object  -Variable "MyResult"
}
catch [System.Net.WebException]
{
Write-Host "hola mundo"
}
catch [Microsoft.TeamFoundation.Wiki.Server.WikiPageNotFoundException]
{
Write-Host "hola mundo0000000000000000"
}








$calledresult = $MyResult.Content | ConvertFrom-Json


$newdata = Get-Content -Path "C:\T\AIMS2\Rel\QA\19.1\Environment\ReleaseScripts\bugsSolved.md" -raw
$myBody=@{            
            content= $newdata + $calledresult.content
        } | ConvertTo-Json
$headerJSON = @{ 
                "content-type" = "application/json;odata=verbose"
                "If-Match" = $MyResult.Headers["Etag"].Replace('"',"")
                } 
$page191Edit ="$tfsWiki/wikis/AIMS2.wiki/pages?path=/ROAIMS2/Version%20History/19.1&api-version=4.1"

Invoke-RestMethod -Uri $page191Edit -Method put -Body $myBody -Headers $headerJSON -UseDefaultCredentials  | Tee-Object  -Variable "MyResult" 

$foo = New-Object psobject -Property @{
    path=  "/ROAIMS2/Version History/18.1"
    order=  0
    gitItemPath=  "/ROAIMS2/Version-History/18.1.md"
    subPages=@()
    url=  "https://tfs.roseninspection.net/tfs/BOGCollection/0a4fa1eb-b731-4e32-9cb9-37861080ffa7/_apis/wiki/wikis/9b9aef7e-6c2a-478f-a69c-6bd1d1e1e1f8/pages/ROAIMS2%2FVersion%20History%2F18.1"
    remoteUrl=  "https://tfs.roseninspection.net/tfs/BOGCollection/0a4fa1eb-b731-4e32-9cb9-37861080ffa7/_wiki/wikis/9b9aef7e-6c2a-478f-a69c-6bd1d1e1e1f8?pagePath=%2FROAIMS2%2FVersion%20History%2F18.1"
    content=  
@'
\u003ch1\u003eRelease 18.1.0.55079 \u003c/h1\u003e\n\u003cb\u003eRelease Number\u003c/b\u003e  : QA-19.1-8  \u003cbr\u003e  \n\u003cb\u003eRelease completed\u003c/b\u003e 07/03/19 07:39:21 \u003cbr\u003e\n\u003cul\u003e\n\u003cli\u003e\n  \u
003cb\u003e\n    Bug \u003ca href=\"https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_workitems?id=63767\u0026_a=edit\"\u003e63767\u003c/a\u003e\n  \u003c/b\u003e ETL.Verification to PODS.NDT_CLOCK POSITION \u0026 DIG_EXCAVATION DATE. copy and pasted 
values cannot be uploaded\n\u003c/li\u003e\n\u003cli\u003e\n  \u003cb\u003e\n    Bug \u003ca href=\"https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_workitems?id=64128\u0026_a=edit\"\u003e64128\u003c/a\u003e\n  \u003c/b\u003e RA.Risk Management.Expor
t Parameters Template.Excel file has overlapped segments\n\u003c/li\u003e\n\u003c/ul\u003e\n\r\n\u003ch1\u003eRelease 18.1.0.55079 \u003c/h1\u003e\n\u003cb\u003eRelease Number\u003c/b\u003e  : QA-19.1-8  \u003cbr\u003e  \n\u003cb\u003eRelease completed\u003c
/b\u003e 07/03/19 07:39:21 \u003cbr\u003e\n\u003cul\u003e\n\u003cli\u003e\n  \u003cb\u003e\n    Bug \u003ca href=\"https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_workitems?id=63767\u0026_a=edit\"\u003e63767\u003c/a\u003e\n  \u003c/b\u003e ETL.Verif
ication to PODS.NDT_CLOCK POSITION \u0026 DIG_EXCAVATION DATE. copy and pasted values cannot be uploaded\n\u003c/li\u003e\n\u003cli\u003e\n  \u003cb\u003e\n    Bug \u003ca href=\"https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_workitems?id=64128\u00
26_a=edit\"\u003e64128\u003c/a\u003e\n  \u003c/b\u003e RA.Risk Management.Export Parameters Template.Excel file has overlapped segments\n\u003c/li\u003e\n\u003c/ul\u003e\n\r\n\u003ch1\u003eRelease 18.1.0.55079 \u003c/h1\u003e\n\u003cb\u003eRelease Number\u00
3c/b\u003e  : QA-19.1-8  \u003cbr\u003e  \n\u003cb\u003eRelease completed\u003c/b\u003e 07/03/19 07:39:21 \u003cbr\u003e\n\u003cul\u003e\n\u003cli\u003e\n  \u003cb\u003e\n    Bug \u003ca href=\"https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_workite
ms?id=63767\u0026_a=edit\"\u003e63767\u003c/a\u003e\n  \u003c/b\u003e ETL.Verification to PODS.NDT_CLOCK POSITION \u0026 DIG_EXCAVATION DATE. copy and pasted values cannot be uploaded\n\u003c/li\u003e\n\u003cli\u003e\n  \u003cb\u003e\n    Bug \u003ca href=\"
https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_workitems?id=64128\u0026_a=edit\"\u003e64128\u003c/a\u003e\n  \u003c/b\u003e RA.Risk Management.Export Parameters Template.Excel file has overlapped segments\n\u003c/li\u003e\n\u003c/ul\u003e\n\r\n
'@

}
