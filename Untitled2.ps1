$json = @"
            {
                "role": "NIMA_EDITOR",
                "security": [                                
                            ]
            } 
"@

$foo = $json | ConvertFrom-Json

$body = '_program=%2FWeb%2Fstorm&_debug=0&_service=default&SASControlTable=%5B%7B%22colName%22%3A%22ACTION%22%2C%22colType%22%3A%22string%22%2C%22colLength%22%3A14%7D%5D&SASControlTable=%5B%7B%22ACTION%22%3A%22INITIALISATION%22%7D%5D'

$body = @"
_program='/Web/storm'
SASControlTable='[{"Name":"COL1","Type":"str"},{"Name":"COL2","Type":"str"}]'
SASControlTable='[{"COL1":"VAL1","COL2","VAL2"}]'
"@

$json = @"
            {
                "role": "NIMA_EDITOR",
                "security": [
                {
                            "permissions": [
                                              "ACCESS_JOBS",
                                              "MyOtherPermission"
                                           ],
                            "category": "Jobs"
                            }]
            } 
"@

$foo = $json | ConvertFrom-Json
#$body = $foo.security
$parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    foreach($permission in $foo.security.permissions)
    {
        $parameters["permissions"] = $permission
    }

$body = "permissions=MyOtherPermission&permissions=MyOtherPermission2&"
(Invoke-WebRequest https://httpbin.org/post -Method Post -Body $body).content


$projectFile = "DM.fsproject"

    $header = @{
        Accept        = "application/json"        
        authorization = "fmetoken token=$global:token"
        #"Content-Disposition" = 'attachment; filename = "'+$projectFile+'"'
        "Content-Disposition" = 'attachment'
        filename = $projectFile
    }

    $body = Get-Content -Raw -Path "C:\T\INS_2019\Installation\FME_Server\$projectFile"
       
    $url = "https://httpbin.org/post"

    $response = Invoke-RestMethod -Method Post -Uri $url -body $body -ContentType "application/octet-stream" -Headers $header