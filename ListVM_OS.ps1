if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
  '.C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'
 }

Connect-VIServer -Server Bog0025 -Credential 

$vms = Get-VM -Name BOGTE_*
$vms | foreach { Get-VMGuest -VM $_ | Format-Table VmName, OSFullName }
