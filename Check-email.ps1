Clear-Host
$Folder = "InBox"
Add-Type -AssemblyName "Microsoft.Office.Interop.Outlook"
$Outlook = New-Object -ComObject Outlook.Application
$Namespace = $Outlook.GetNameSpace("MAPI")

# $NameSpace.Folders.Item(1).Folders | Format-Table FolderPath
# $NameSpace.Folders.Item(1)
$inbox= $Namespace.GetDefaultFolder(6)
$tempEmails=@()
for($i=$inbox.Items.Count ; $i -gt $inbox.Items.Count - 50; $i--){$tempEmails+= $inbox.Items.Item($i)}  

$Emails = $tempEmails| where {(($_.SenderName -match "Moritz") -and ($_.Body -match "\\bogexp1") )}#  -and ($_.UnRead -eq $true) $NameSpace.Folders.Item(4).Folders.Item("Inbox").Items | select -Last 10  #| where {($_.SenderEmailAddress -match "edificio")} #| select -First 10  # -and ($_.Body -notmatch "\\bogexp1") ##|Sort-Object ReceivedTime -Descending

#$deplos = $Emails | New-Object PSObject -Property @{Label="Path"; Expression={[Regex]::matches($_.Body, "\\\\(BOG|bog)([\w\.]*\\)*(\w*)")[0].Value }} # }

$deplos= @()
foreach($email in $Emails)
{
    $properties = @{'Date'=$email.ReceivedTime; 'Path'=[Regex]::matches($email.Body, "\\\\(BOG|bog)([\w\.]*\\)*(\w*)")[0].Value}
    $deplo = New-Object PSObject -Property $properties
    $deplos+= $deplo
}

$deplos
$deploymentsPath = "\\bog0009\DeploymentDropLocation\LatestDeployments\Products\Cinnamon\"
foreach($deployment in $deplos)
{
    if(-Not (Test-Path $deployment.Path))
    {
        continue
    }
    
    $deploDate = $deployment.Date.ToString("yyyyMMdd")
    $branch = if ($deployment.Path -match "Dev_15") 
                 {
                    "1Dev"
                 } 
              else 
                {
                    if ($deployment.Path -match "Staging_15") 
                        {
                            "3Staging"
                        }
                    else
                        {
                            if ($deployment.Path -match "Rel_15") 
                                {
                                    "Rel"
                                }
                            else
                                {
                                    "2QA"
                                }
                        }
                }


    $deploFolder = if(Test-Path $deploymentsPath$deploDate) { Get-ChildItem -Path $deploymentsPath$deploDate  -include $branch -Recurse -Directory | select -First 1} else {$null}

    if($deploFolder -eq $null)
    {
        $deploFolder = New-Item $deploymentsPath$deploDate\$branch -ItemType Directory
    }

    foreach($artifact in 'Databases', 'DeployPackage', 'Installer') 
    {
        $originPath =  $deployment.Path+$artifact  
        Copy-Item -Path $originPath -Destination "$deploFolder\\$artifact" -Force -Recurse 
    }
}