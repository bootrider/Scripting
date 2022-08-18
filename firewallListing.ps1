﻿
$FWprofileTypes= @{1GB=”All”;1=”Domain”; 2=”Private” ; 4=”Public”}
$FwAction      =@{1=”Allow”; 0=”Block”}
$FwProtocols   =@{1=”ICMPv4”;2=”IGMP”;6=”TCP”;17=”UDP”;41=”IPv6”;43=”IPv6Route”; 44=”IPv6Frag”;
                  47=”GRE”; 58=”ICMPv6”;59=”IPv6NoNxt”;60=”IPv6Opts”;112=”VRRP”; 113=”PGM”;115=”L2TP”;
                  ”ICMPv4”=1;”IGMP”=2;”TCP”=6;”UDP”=17;”IPv6”=41;”IPv6Route”=43;”IPv6Frag”=44;”GRE”=47;
                  ”ICMPv6”=48;”IPv6NoNxt”=59;”IPv6Opts”=60;”VRRP”=112; ”PGM”=113;”L2TP”=115}
$FWDirection   =@{1=”Inbound”; 2=”outbound”; ”Inbound”=1;”outbound”=2} 


Function Get-FireWallRule
{Param ($Name, $Direction, $Enabled, $Protocol, $profile, $action, $grouping)
$Rules=(New-object –comObject HNetCfg.FwPolicy2).rules
If ($name)      {$rules= $rules | where-object {$_.name     –like $name}}
If ($direction) {$rules= $rules | where-object {$_.direction  –eq $direction}}
If ($Enabled)   {$rules= $rules | where-object {$_.Enabled    –eq $Enabled}}
If ($protocol)  {$rules= $rules | where-object {$_.protocol  -eq  $protocol}}
If ($profile)   {$rules= $rules | where-object {$_.Profiles -bAND $profile}}
If ($Action)    {$rules= $rules | where-object {$_.Action     -eq $Action}}
If ($Grouping)  {$rules= $rules | where-object {$_.Grouping -Like $Grouping}}
$rules}
 
Get-firewallRule -enabled $true | sort direction,applicationName,name |
format-table -wrap -autosize -property Name, @{Label=”Action”; expression={$FwAction[$_.action]}},
@{label="Direction";expression={ $FWDirection[$_.direction]}},
@{Label=”Protocol”; expression={$FwProtocols[$_.protocol]}} , localPorts,applicationname
 

