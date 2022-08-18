$deploymentSource = '\\bog0009\DeploymentDropLocation\LatestDeployments\Products\Roaims\YPF\15.1\ROAIMS\AimsStandard_15.0.0_20150416.2_x86_Protected'
$appDir = 'C:\Program Files (x86)\WiX Toolset v3.9\bin\'
$wixFolderProject = 'C:\Users\CGLondono\documents\visual studio 2013\Projects\testWixSetup\testWixSetup'
$projectDefinition = Get-Content $wixFolderProject"\variables.wxi" 
$variableName = 'SourceDir = ' + '"'+$deploymentSource+'"'

$projectDefinition | ForEach-Object { $_ -replace 'SourceDir = ""', $variableName} | Set-Content $wixFolderProject"\variables.wxi"


& $appDir'heat.exe' dir $deploymentSource -srd -cg PipelineCenter -gg -sfrag -scom -sreg -svb6 -var var.SourceDir -dr INSTALLFOLDER -out C:\Temp\PipelineCenter_guid_2.wxs
  
& $appDir'candle.exe' $wixFolderProject"\Product.wxs" "C:\Temp\PipelineCenter_guid_2.wxs" -dSourceDir='\\BOGEXP1\dl\Applications\IntegrityManagement_Build\IntegrityManagement_Build_20150120_14.1.0.7\AnyCPU\Release' -out c:\temp\
  
& $appDir'light.exe' "C:\temp\Product.wixobj" "C:\temp\pipelinecenter_Guid_2.wixobj" -out c:\temp\CinInstaller.msi

& $appDir'heat.exe' file C:\BOG\AIMS2\Rel\QA\14.5\Products\..\DropLocation\Deploy\AimsStandard\14.5\AimsStandard_14.5_20150420_0149_Release\.\Rosen.Pims.Ga.Esri.dll -cg BundleFiles -dr INSTALLDIR -srd -var var.BundleDir -gg -out c:\temp\_BundleFiles_ESRI.wxs