# Discard changesets
# 
param(
    #[ValidateSet("FT1", "FT2", "15.2", "Main", "16.1")]
	[string]$source = "FT_17.1",
    #[ValidateSet("FT1", "FT2", "15.2", "Main", "16.1")]
	[string]$destination = "17.1",
    $changeset    
)

$m = Get-PSSnapin -Registered | Where-Object {$_.Name -match "Microsoft.TeamFoundation.PowerShell"} | measure
if ($m.Count -eq 0)
{
	throw "Install the TFS PowerTools for VS including powershell extension"
}
else 
{
	if ( (Get-PSSnapin -Name Microsoft.TeamFoundation.PowerShell -ErrorAction SilentlyContinue) -eq $null )
	{
	    Add-PSSnapin Microsoft.TeamFoundation.PowerShell
	}
}


$tfsCollectionPath = "http://tfs:8080/tfs/bogcollection"
$tfsserver = get-tfsserver $tfsCollectionPath
$ws = Get-TfsWorkspace -Computer $env:COMPUTERNAME -Server $tfsserver | where {$_.Name -notmatch "Resources"}
$folderSource = $ws.Folders | where {($_.ServerItem -match "AIMS2") -and ($_.LocalItem -match "\\$source") -and ($_.LocalItem -ne $null)} | Select-Object -ExpandProperty "ServerItem"
$folderDestination = $ws.Folders | where {($_.ServerItem -match "AIMS2") -and ($_.LocalItem -match "\\$destination") -and ($_.LocalItem -ne $null)} | Select-Object -ExpandProperty "ServerItem"
$folder = $ws.Folders | where {($_.ServerItem -match "AIMS2") -and ($_.LocalItem -match "\\$destination") -and ($_.LocalItem -ne $null)} | Select-Object -ExpandProperty "LocalItem"

# Push-Location $folder

$tfExec = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\TF.exe" 
# $tfArgs = @("merge", "/discard", "/version:$changeset", $folderSource, $folderDestination, "/recursive" )
$tfArgs = @("merge", "/candidate", $folderSource, $folderDestination, "/recursive" )


# $tfArgs = @("merge", "/version:$changeset", $folderSource, $folderDestination, "/recursive" )
#& $tfExec $tfArgs 
#$tfArgs = @("resolve", "$folderDestination\ThirdParty", "/recursive", "/noprompt", "/auto:acceptTheirs" )
& $tfExec $tfArgs 


#$tfArgs = @("checkin", "$folderDestination\ThirdParty", "/recursive", "/noprompt", '/comment:"Merge from FT2"')
#& $tfExec $tfArgs  
# Pop-Location