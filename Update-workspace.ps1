add-PSsnapin Microsoft.teamfoundation.powershell

$wslocalfolders = @("C:\T\AIMS2\Rel\QA\18.1\Rosen\", "C:\T\AIMS2\Rel\QA\18.1\Environment\", "C:\T\AIMS2\Rel\QA\18.1\Products\", "C:\T\AIMS2\Rel\QA\18.1\Thirdparty\")
$tfsCollectionPath = "http://tfs:8080/tfs/bogcollection"
$tfsserver = get-tfsserver $tfsCollectionPath
$ws = Get-TfsWorkspace -Computer $env:COMPUTERNAME -Server $tfsserver

foreach ($localfolder in $wslocalfolders)
{
    Push-Location $localfolder
	$itemsToRecover = Get-TfsChildItem $localfolder -Server $tfsserver 

	foreach($item in $itemsToRecover)
		{
			Update-TfsWorkspace -Item $item.ServerItem -Recurse -Force
		}
    
    Pop-Location
}
