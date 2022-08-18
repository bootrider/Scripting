$Sourcepassword = ConvertTo-SecureString 'qkOH1itvwJhXzV1Qs2LP' -AsPlainText -Force
$SourceCredential = New-Object System.Management.Automation.PSCredential ('SQLAdmin', $Sourcepassword)

$destPassword = ConvertTo-SecureString 'beY-hUfReFeyE5Es' -AsPlainText -Force
$destCredential= New-Object System.Management.Automation.PSCredential ('sde', $destPassword)

Copy-DbaDatabase -Source Lin0242 -Database RosenDM_QA -SourceSqlCredential $SourceCredential -Destination LIN0228 -DestinationSqlCredential $destCredential -SharedPath \\lin0228\nima -BackupRestore -Force


Get-DbaDbUser -SqlInstance LIN0228 -Database Rosen_DM -SqlCredential $destCredential | %{New-DbaDbUser -SqlInstance LIN0228 -Database RosenDM_QA -SqlCredential $destCredential -Login $_.Login -Username $_.Name -Force}


#Get-DbaDbUser -SqlInstance LIN0228 -Database RosenDM_QA -SqlCredential $destCredential | %{Invoke-DbaQuery -Query "ALTER ROLE [NIMA_EDITOR] ADD MEMBER [$($_.Name)]" -SqlInstance LIN0228 -Database RosenDM_QA -SqlCredential $destCredential}


$userpermissions = Get-DbaUserPermission -SqlInstance LIN0228 -Database RosenDM_QA -SqlCredential $destCredential

$options = New-DbaScriptingOption
$options.ScriptDrops = $true
$options.WithDependencies = $true
$options.IncludeDatabaseRoleMemberships = $true
$options.Permissions = $true
$options.ScriptForAlter = $true

Export-DbaUser -SqlInstance Lin0242 -Database RosenDM_QA -SqlCredential $SourceCredential -Path C:\temp\users -ScriptingOptionsObject $options -DestinationVersion SQLServer2016

Invoke-DbaQuery -SqlInstance LIN0228 -Database RosenDM_QA -SqlCredential $destCredential -File C:\temp\users.sql 

Get-DbaDb -SqlInstance LIN0228 -Database RosenDM_QA -SqlCredential $destCredential


Invoke-DbaQuery -SqlInstance LIN0228 -Database RosenDM_QA -SqlCredential $destCredential -Query "ALTER USER cglondono WITH LOGIN = cglondono;"


The new way (SQL 2008 onwards) is to use ALTER USER

ALTER USER cglondono WITH LOGIN = cglondono;