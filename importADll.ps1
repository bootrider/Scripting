[reflection.assembly]::loadwithpartialname("Microsoft.TeamFoundation.Build.Client.dll") | Out-Null
 $openFile = New-Object System.Windows.Forms.OpenFileDialog
 $openFile.Filter = "txt files (*.txt)|*.txt|All files (*.*)|*.*" 
 If($openFile.ShowDialog() -eq "OK")
 {get-content $openFile.FileName} 