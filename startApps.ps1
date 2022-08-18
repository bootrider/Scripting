. "C:\Program Files (x86)\Microsoft Office\Office16\OUTLOOK.EXE"
. "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe"
# . "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
. "C:\Program Files (x86)\Microsoft Office\Office16\ONENOTE.EXE"
. "C:\Program Files (x86)\Notepad++\notepad++.exe"
. "C:\Program Files (x86)\KeePass Password Safe 2\KeePass.exe"
. "C:\Program Files (x86)\Microsoft\Remote Desktop Connection Manager\RDCMan.exe"
[Diagnostics.Process]::Start("C:\Program Files\Microsoft VS Code\Code.exe")
Start-Process "https://tfs.roseninspection.net/tfs/BOGCollection/AIMS2/_build?path=%5C&_a=mine" -Wait:$false
Start-Process "https://time/" -Wait:$false
