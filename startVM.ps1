Import-Module VMware.VimAutomation.Core
Connect-VIServer -Server Bogvc1

$vms = @(
        #"BOGTE_DEMOW81",
        "BOGDB11"
        # "BOGTE_DEV01"
        #"BOGTE_SERVICES"
        # "BOGTE_MONGDB2",
        # "BOGTE_MONGDB3",
        # "BOGTE_MONGDB1",
        # "BOGTE_PDWDB2",
        # "BOGTE_PDWDB1",
        # "BOGTE_IPDWDB8",
        # "BOGTE_IPDWDB6"
        # 

        )

 $vms = get-vm * | where {$_.PowerState -ne "PoweredOff"} -and $_.Name -match "DMZBOGONR"}
 foreach($vm in $vms)
 {
     Start-VM $vm
     #get-VM 
     #get-vm $vms | Select-Object -Property Name,PowerState 
 }
# 
# get-vm | Select-Object -property Name,Notes |Export-Csv  C:\Temp\vms.csv

$vm = get-vm -Name "BOGBuild1"
$snapshot =  Get-Snapshot -vm $vm |Sort-Object -Property Created -Descending |Select-Object -First 1

Set-VM -VM $vm -Snapshot $snapshot -Confirm:$false
Start-VM -VM $vm -Confirm:$false


Stop-VM -VM $vm -Confirm:$false

$newSnapshot = New-Snapshot -VM $vm -Name "InitialState_20180601" -Description "Prerequisites of ROAIMS, TFS Agent, Windows updates" -Confirm:$false
Remove-Snapshot -Snapshot $snapshot[1] -Confirm:$false
Get-Snapshot -vm $vm

Open-VMConsoleWindow -VM bogbuildagent


Disconnect-VIServer -Server Bogvc1 -Confirm:$false

$vms = Get-VM -Name BOGTE_*
$vms | foreach { Get-VMGuest -VM $_ | Format-Table VmName, OSFullName }