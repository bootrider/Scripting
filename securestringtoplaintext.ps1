$passworwd = Read-Host -AsSecureString

Write-Host $passworwd

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passworwd)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Write-Host $Unsecurepassworwd