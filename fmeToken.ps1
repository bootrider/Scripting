$fmeServer = "http://lin0259:8081"

$fmeTokenUrl ="$fmeServer/fmetoken/service/generate"
$user = 'cglondono'
$password = '4RKjWtdF'

$expiration = 1
#build post body for rest call
$cred_body = @{
    user = $user
    password = $password
    expiration = $expiration
    timeunit = 'day'
    update = 'false'
    }

$tokenResponse = Invoke-RestMethod -Method Post -Uri $fmeTokenUrl -Body $cred_body  #-ContentType "application/x-www-form-urlencoded"

$token = "302737f4a4e5ea29c87bfd98c9d700182d3853b5"



$infoUrl = "$fmeServer/fmerest/v3/info"

$header = @{
    Accept = "application/json"
    ContentType = "application/json"
    authorization = "fmetoken token=$token"
    }

#----------------------------------------------------------------------------------------------------

Invoke-RestMethod -Method Get -Uri $infoUrl -Headers $header
Invoke-WebRequest -Method Get -Uri $infoUrl -Headers $header 
[System.Net.WebException

$healthcheckURI = $fmeServer+'/fmerest/v3/healthcheck'
#$healthcheckURI
$authorizationHeader = @{
authorization = "fmetoken token="+$token
}
#build query
$healthcheck = Invoke-RestMethod -Method Get -Uri $healthcheckURI -Header $authorizationHeader
#configure string for result
$status='FME Server: "'+$hostname+'" status is '+$healthcheck.status
#display status
$status

$uri = $fmeServer+'/fmerest/v3/transformations/jobroutes/tags/ShortRunning'
$foo = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
try
{
#Invoke-WebRequest -Method Get -Uri $uri -Headers $header -
Invoke-RestMethod -Method Post -Uri $request.Uri -Headers $header
}
catch [System.Net.WebException]
{
    $ex = $_.Exception
}

$uri = $fmeServer+'/fmerest/v3/transformations/jobroutes/tags/'
$body = @{
    description = 'Queue for short running jobs'
    name ='ShortRunning'
    
    }


$Parameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
$parameters['description'] = 'Queue for short running jobs'
$parameters['name'] = 'ShortRunning'

$Request = [System.UriBuilder]$uri
$Request.Query = $Parameters.ToString()


$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $header -Body $body

$uri = $fmeServer+'/fmerest/v3/projects/projects/FME_PROJECT_TEST'

$response = Invoke-RestMethod -Method Post -Uri $uri -Headers $header 


$header = @{
    Accept = "application/json"
    ContentType = "application/json"
    
    authorization = "fmetoken token="
    }

$uri = $fmeServer+'/fmerest/v3/transformations/submit/ROSEN%20Integrity%20Management/AnalyzeInputDataset.fmw'
$foo = Invoke-RestMethod -Method Get -Uri $uri -Headers $header

#-------------------------------

function Failure {
$global:helpme = $body
$global:helpmoref = $moref
$global:result = $_.Exception.Response.GetResponseStream()
$global:reader = New-Object System.IO.StreamReader($global:result)
$global:responseBody = $global:reader.ReadToEnd();
Write-Host -BackgroundColor:Black -ForegroundColor:Red "Status: A system exception was caught."
Write-Host -BackgroundColor:Black -ForegroundColor:Red $global:responsebody
Write-Host -BackgroundColor:Black -ForegroundColor:Red "The request body has been saved to `$global:helpme"
break
}

 $uri = $fmeServer+'/v3/repositories/ROSEN%20Integrity%20Management2'

 $foo = Invoke-RestMethod -Method Get -Uri $uri -Headers $header
 
 $foo = Invoke-WebRequest -Method Get -Uri $uri -Headers $header


 $foo = Invoke-RestMethod -Method Get -Uri $uri -Headers $header


 $Error[0].Exception.Response.StatusCode.value__



 #*********************************


 $fmeServer = "http://lin0259:8081"

$fmeTokenUrl ="$fmeServer/fmetoken/service/generate"
$user = 'admin'
$password = 'admin'

$expiration = 1
#build post body for rest call
$cred_body = @{
    user = $user
    password = $password
    expiration = $expiration
    timeunit = 'day'
    update = 'false'
    }

$tokenResponse = Invoke-RestMethod -Method Post -Uri $fmeTokenUrl -Body $cred_body  #-ContentType "application/x-www-form-urlencoded"

$token = '6e197160678dd50420c09191b43aa9dadcc6b30c'


$header = @{
    Accept = "application/json"
    ContentType = "application/json"
    authorization = "fmetoken token=$token"
    }


    $uri = $fmeServer+'/fmerest/v3/transformations/submit/ROSEN%20Integrity%20Management/ILI_Upload.fmw'
    $uri = $fmeServer+'/fmerest/v3/repositories/ROSEN%20Integrity%20Management/items/ILI_Upload.fmw/properties/categories/fmejobsubmitter_FMEUSERPROPDATA'
    $body = '{
  "FAILURE_TOPICS" :"JOBSUBMITTER_ASYNC_JOB_FAILURE",
  "SUCCESS_TOPICS": "JOBSUBMITTER_ASYNC_JOB_SUCCESS"
}'
$foo = Invoke-RestMethod -Method POST -Uri $uri -Headers $header -Body $body

#-----------------------------------------------------------------------

$fmeServer = "http://lin0228:8080"

$fmeTokenUrl ="$fmeServer/fmetoken/service/generate"
$user = 'admin'
$password = 'hLj2U2crTCvndaQK'

$expiration = 1
#build post body for rest call
$cred_body = @{
    user = $user
    password = $password
    expiration = $expiration
    timeunit = 'day'
    update = 'false'
    }

$tokenResponse = Invoke-RestMethod -Method Post -Uri $fmeTokenUrl -Body $cred_body  #-ContentType "application/x-www-form-urlencoded"

$token = '1a938edd9e5dda65f41861be131fa5661266113b'


$header = @{       
    Accept = "application/json"    
    ContentType = "application/json"
    authorization = "fmetoken token=$token"
    }

$uri = $fmeServer+'/fmerest/v3/projects/projects/DM/deleteall'
$foo = Invoke-RestMethod -Method POST -Uri $uri -Headers $header -Body $null -ContentType "application/json"
#-----------------------------------------------------------------------------------------------------------------------------------   


$fmeServer = "http://lin0259:8081"

$fmeTokenUrl ="$fmeServer/fmetoken/service/generate"
$user = 'cglondono'
$password = '4RKjWtdF'

$expiration = 1
#build post body for rest call
$cred_body = @{
    user = $user
    password = $password
    expiration = $expiration
    timeunit = 'day'
    update = 'false'
    }

$token = Invoke-RestMethod -Method Post -Uri $fmeTokenUrl -Body $cred_body  #-ContentType "application/x-www-form-urlencoded"

$url = "$fmeServer/fmerest/v3/resources/connections/NIMATemp/filesys?createDirectories=false&overwrite=true"

$header = @{
    Accept = "application/json"
    authorization = "fmetoken token=$token"
    "Content-Disposition" = 'attachment; filename = "ReverseIT.xlsx"'
    }


$invokeArgs = @{
        Uri     = $url
        Headers = $header
        Method  = "Get"
    }

$File = "C:\Temp\Inspection Files\ReverseIT.xlsx"
$invokeArgs['Method'] = "Post"
$invokeArgs.Add("Body", $Body)
$invokeArgs.Add("InFile", $File)        
$invokeArgs['ContentType'] = "application/octet-stream"

$foo = Invoke-WebRequest @invokeArgs 