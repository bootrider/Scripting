#
# Script.ps1
#
clear
$rosenFolder = 'C:\IPDW\Dev\FT1'
$date = Get-Date -format "dd-MMM-yyyy-HH-mm"
$platform="AnyCPU"
$conf="Debug"
$target="Build"

Push-Location $rosenFolder

Write-Progress -Activity 'SonarQube Alaysis' -Status 'Deleting files' -PercentComplete 1 -CurrentOperation 'delete .sonarqube folder'

# delete .sonarqube folder
if (Test-Path .sonaqube)
{
    [System.IO.Directory]::Delete('.\.sonarqube', $true)
}

"Deleted .sonarQube" |  Out-File -FilePath C:\Temp\analysisSonar-log_$date.txt 

Write-Progress -Activity 'SonarQube Alaysis' -Status 'Deleting files' -PercentComplete 10 -CurrentOperation 'delete droplocation to force a clean build'
# delete droplocation to force a clean build
$dropLocationFolder = Join-Path $rosenFolder -ChildPath 'Droplocation'
if(Test-Path $dropLocationFolder)
{
    [System.IO.Directory]::Delete($dropLocationFolder, $true)
    if(Test-Path "$rosenFolder\TestResults\"){[System.IO.Directory]::Delete("$rosenFolder\TestResults\", $true)}   
}

Start-Sleep 5

"deleted droplocation" |  Out-File -FilePath C:\Temp\analysisSonar-log_$date.txt -Append
# get-latest version 
#Write-Progress -Activity 'SonarQube Alaysis' -Status 'Getting new source code files' -PercentComplete 15 -CurrentOperation 'get-latest version'
add-PSsnapin Microsoft.teamfoundation.powershell
Update-TfsWorkspace -Item $rosenFolder -Recurse  

#"updated workspace" |  Out-File -FilePath C:\Temp\analysisSonar-log_$date.txt -Append

#remove bin/obj folders to force a clean build
#Write-Progress -Activity 'SonarQube Alaysis' -Status 'Deleting files' -PercentComplete 25 -CurrentOperation 'remove bin/obj folders to force a clean build'
Get-ChildItem -Path $rosenFolder -Include bin, obj -Directory -Recurse | foreach{[System.IO.Directory]::Delete($_, $true)}
"deleted bin/obj" |  Out-File -FilePath C:\Temp\analysisSonar-log_$date.txt -Append


$currDir = Get-Location


# Start sonnarqube runner interceptor
Write-Progress -Activity 'SonarQube Alaysis' -Status 'Starting analysis' -PercentComplete 30 -CurrentOperation 'Start sonnarqube runner interceptor'
# $exclusions = "file:$currDir\Databases\**\*.*, file:$currDir\Biz\Printing\**\*.cs, file:$currDir\Catalogs\**\*.cs, file:$currDir\Pims\Fw\Rosen.Pims.Fw.Alignnment.Ui.*\**\*.cs, file:$currDir\Pims\Fw\Rosen.Pims.Fw.Apdm.*\**\*.cs, file:$currDir\Pims\Fw\Rosen.Pims.Fw.Db.Apdm.Model\**\*.cs, file:$currDir\Pims\Fw\Rosen.Pims.Fw.Etl.*\**\*.cs, file:$currDir\Pipe\Fw\Dbf\**\*.cs, file:$currDir\Pipe\Fw\Segmentation\**\*.cs, file:$currDir\Pipe\Fw\Sims\**\*.cs, file:$currDir\Tech\Activation\**\*.cs, file:$currDir\Tech\Aspects\**\*.cs, file:$currDir\Tech\printing\**\*.cs, file:$currDir\Tech\ResourceLocking\**\*.cs, file:$currDir\Tech\Resources\**\*.cs, file:$currDir\Tims\**\*.cs"
# $tfsProperties = "/d:sonar.tfvc.collectionuri=http://tfs:8080/tfs/bogcollection /d:sonar.tfvc.password.secured={aes}SpM/hhufWMH3kDkd9ACxNA== /d:sonar.tfvc.username=TFS_Bog_Build_Servic /d:sonar.scm.provider=tfvc"
          
#$runner = 'C:\Sonar\SonarRuner\MSBuild.SonarQube.Runner.exe' 
#$argsRunner =@("begin", '/k:IPDW /n:IPDW /v:1.0 /d:sonar.host.url="http://bogdev23:9009/"') # 

C:\Sonar\SonarRuner\MSBuild.SonarQube.Runner.exe begin /k:IPDW /n:IPDW /v:1.0 /d:sonar.verbose=true /d:sonar.cs.vscoveragexml.reportsPaths="$dropLocationFolder\CoverageReport.coveragexml" /d:sonar.cs.vstest.reportsPaths="$rosenFolder\TestResults\*.trx"  /d:sonar.host.url="http://bogdev23:9009/" 

#**********************************************************************************************
#       Execute Build
#**********************************************************************************************
# star the Build process
Write-Progress -Activity 'SonarQube Alaysis' -Status 'Analyze this' -PercentComplete 40 -CurrentOperation 'Build process'
$msbuild = "C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
$args = @("/p:ExecuteTests=true;FullBuild=true", "Rosen\build.proj", "/p:PreBuildEvent=;LocalBuild=True;PostBuildEvent=;Platform=$platform;Configuration=$conf;OutDir=$currDir\Droplocation\Build\$platform\$conf\;ContinueOnError=false;CustomAfterMicrosoftCommonTargets=`"$currDir\..\Environment\MSBuild\Build.targets`"", "/t:$target")

& $msbuild $args | Out-File -FilePath C:\Temp\buildSonar-log.txt


#**********************************************************************************************
#       Execute Test + Coverage
#**********************************************************************************************
$stringResult = @()
$testFiles = Get-ChildItem -Path $dropLocationFolder -Include Rosen.*test.dll -Recurse |select FullName | foreach {
$stringResult+= $_.FullName
}

$stringResult += "/Settings:.\Environment\Test.runsettings"
$stringResult += "/EnableCodeCoverage"
$stringResult += "/logger:trx"

&"C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe" $stringResult


[System.IO.FileInfo]$coverageFile = Get-ChildItem -Path $rosenFolder\TestResults -Include *.coverage -Recurse | Sort CreationTime -Descending | Select -First 1
$coverageArgs = @("analyze", "/output:$dropLocationFolder\CoverageReport.coveragexml", $coverageFile)

& "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Team Tools\Dynamic Code Coverage Tools\CodeCoverage.exe" $coverageArgs


#**********************************************************************************************
#       Extract Metrics
#**********************************************************************************************

. "C:\Temp\MetricsTool\Out-ROAIMSMetrics.ps1"
$metricsPath = Join-Path -Path $rosenFolder -ChildPath "Metrics"

Out-Metrics -Project IPDW -Branch FT1 -OutPath $metricsPath



#**********************************************************************************************
#       End Sonar
#**********************************************************************************************
Write-Progress -Activity 'SonarQube Alaysis' -Status 'Analyzed' -PercentComplete 90 -CurrentOperation 'End sonnarqube runner interceptor'
# End sonnarqube runner interceptor
C:\Sonar\SonarRuner\MSBuild.SonarQube.Runner.exe end | Out-File -FilePath C:\Temp\analysisSonar-log_$date.txt -Append
