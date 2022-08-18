

$dbInstance="BOGDB14"
$ROdbName="ATM_171_20170105_ROTASK"

$sqlquery = "SELECT [instance_name]
	 	,[type_name]
	 	,[type_version]
	 	FROM [dbo].[sysdac_instances_internal] where [instance_name] like '$ROdbName'"

	$invokeArgs = @{
		Query=$sqlQuery;
		SqlInstance=$dbInstance;
		Database="msdb";				
	}

#	if ($Restore) {
#		$restoreUser = "bogreplicationuser"
#		$restorePwd = Read-Password
#		$restoreCredential=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $restoreUser, $restorePwd
#		
#		$invokeArgs += @{
#			SqlCredential = $restoreCredential; 					
#		}
#	}
#

$table =Invoke-DbaSqlQuery @invokeArgs -as DataTable

# $versionDb = $table | Where-Object {$_.instance_name -like "*$ROdbName*"} | Select-Object -First 1 | %{$_.type_version}
$versionDb = $table | Select-Object -First 1 | %{$_.type_version}

$versionDb