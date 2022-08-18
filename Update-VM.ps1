Import-Module VMware.VimAutomation.Core
Connect-VIServer -Server Bogvc1



$vm = get-vm -Name "BOGTE_Demo"
$snapshot = Get-Snapshot -vm $vm |Sort-Object -Property Created -Descending |Select-Object -First 1

Set-VM -VM $vm -Snapshot $snapshot -Confirm:$false
Start-VM -VM $vm -Confirm:$false

# log into the machine and apply the updates

Stop-VM -VM $vm -Confirm:$false

$newSnapshot = New-Snapshot -VM $vm -Name "InitialState_20190201" -Description "Prerequisites of ROAIMS, TFS Agent, Windows updates, , TestExecute 12" -Confirm:$false
$snapshot = Get-Snapshot -vm $vm |Sort-Object -Property Created -Descending
Remove-Snapshot -Snapshot $snapshot[1] -Confirm:$false

Get-Snapshot -vm $vm

Open-VMConsoleWindow -VM $vm