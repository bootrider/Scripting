# note from the course powershell for developers
Add-Type -AssemblyName System.Drawing
Add-Type -Path ./customrypes.dll
Import-Module ./customtypes.dll # is used for assemblies tahta contains powershell features such as cmdlets or providers
[Reflection.Assembly]:: Load(...) # special circunstances


# make a  for in power shell 

1...100 | foreach{ New-Object customTypes.user -Property @{Name = "User$_"}} | Export-Csv ./mycsvFile.csv


# how to put a cmd in the middlke of a pipeline

