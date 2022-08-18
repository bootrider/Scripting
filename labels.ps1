push-location C:\t\ws2\DevOps
add-PSsnapin Microsoft.teamfoundation.powershell
$currentItem = Get-TfsChildItem $/UnityPlot/Rosen | Select-Object -First 1 | select-object -ExpandProperty ServerItem
write-host "this is the item $currentItem"
$tfTool = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\TF.exe"
	[string[]]$tfArgs=@() 
	$tfArgs += "vc"
	$tfArgs += "label"
	$tfArgs += "MyLabel6@$/UnityPlot"
	$tfArgs += "$currentItem"
	$tfArgs += "/recursive"
. $tfTool $tfArgs

pop-location