function Get-WebClient
{
 param
    (
        [string]$username, 
        [string]$password,
        [string]$ContentType = "application/json"
    )

    $wc = New-Object System.Net.WebClient
    $wc.Headers["Content-Type"] = $ContentType
    
    if ([System.String]::IsNullOrEmpty($password))
    {
        $wc.UseDefaultCredentials = $true
    } else 
    {
       # This is the form for basic creds so either basic cred (in TFS/IIS) or alternate creds (in VSTS) are required"
       # or just pass a personal access token in place of a password
       $pair = "${username}:${password}"
       $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
       $base64 = [System.Convert]::ToBase64String($bytes)
       $wc.Headers.Add("Authorization","Basic $base64");
    }
 
    $wc
}



# $uri = 'https://tfs.roseninspection.net/tfs/bogcollection/AIMS2/_apis/Release/releases'
$uri= 'https://tfs.roseninspection.net/tfs/BOGCollection/_apis/Identities/dd9b098f-ee78-45fb-b456-1e36af1ddbbd'
$client = Get-WebClient
$jsondata = $client.DownloadString($uri) | ConvertFrom-Json 

    $uri= 'https://tfs.roseninspection.net/tfs/BOGCollection/_apis/Identities/dd9b098f-ee78-45fb-b456-1e36af1ddbbd'

$uri = 'https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_apis/Release/releases/75?api-version=3.0-preview'

 

Invoke-WebRequest -Uri $uri -Method Delete -UseDefaultCredentials 



Invoke-WebRequest -Uri $uri -Method Patch -UseDefaultCredentials

	$wc = New-Object System.Net.WebClient
    $wc.Headers["Content-Type"] = $ContentType
	$wc.UseDefaultCredentials = $true
	$responsible = $wc.DownloadString($uri) | ConvertFrom-Json 
	return $responsible.Properties.Mail