##################################################################################
# Define accepted parameters.
param([string]$MsiFileName = $(throw "The MSI file name must be provided"), [string]$PrevProductName, [string]$MsiCustomArgs)

# Output the logo.
"Microsoft Release Management MsiExec PowerShell Script v12.0"
"Copyright (c) 2013 Microsoft. All rights reserved.`n"

# Assume the process ran successfully.
$exitCode = 0

# Format errors to be more verbose.
trap
{
  $e = $error[0].Exception
  $e.Message
  $e.StackTrace
}

##################################################################################
#
# Fetches the given Property from an MSI file
#
function GetMsiProperty([string]$MsiFile, [string]$Property)
{
  # Create Installer instance
  $installer = New-Object -comObject WindowsInstaller.Installer
  # Call Installer.OpenDatabase(name, openMode)
  $database = $installer.GetType().InvokeMember("OpenDatabase", [System.Reflection.BindingFlags]::InvokeMethod, $null, $installer, ($MsiFile, 0))
  # Call Database.OpenView(sql)
  $view = $database.GetType().InvokeMember("OpenView", [System.Reflection.BindingFlags]::InvokeMethod, $null, $database, "SELECT `Value` FROM `Property` WHERE `Property`='$Property'")
  # Call View.Execute()
  $view.GetType().InvokeMember("Execute", [System.Reflection.BindingFlags]::InvokeMethod, $null, $view, $null)
  # Call View.Fetch()
  $record = $view.GetType().InvokeMember("Fetch", [System.Reflection.BindingFlags]::InvokeMethod, $null, $view, $null)
  # Get Record.StringData(field)
  return $record.GetType().InvokeMember("StringData", [System.Reflection.BindingFlags]::GetProperty, $null, $record, 1)
}

##################################################################################
# Define the MSI details.
$msiFile = Resolve-Path $MsiFileName
$msiexec = "msiexec.exe"
$msiexecUninstallArgs = '/x {0} /qn /L* "' + $msiFile + '.log"'
$msiexecInstallArgs = '/i "{0}" /qn ACCEPT=YES /L*+ "' + $msiFile + '.log"'
if (![string]::IsNullOrEmpty($MsiCustomArgs)) 
{
  $msiexecInstallArgs += ' ' + $MsiCustomArgs 
}

##################################################################################
# Identify the Product.
$productName = $PrevProductName
if ([string]::IsNullOrEmpty($productName))
{
  $productName = GetMsiProperty -MsiFile $msiFile -Property "ProductName"
}
"Product Name:" + $productName + "`n"

##################################################################################
# Determine the OS type.
if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -eq "64-bit")
{
  # The following is for 64 bit machines.
  "Running on a 64 bit OS.`n"
  $uninstallRegKey = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
}
else
{
  "Running on a 32 bit OS.`n"
  # The following is for 32 bit machines.
  $uninstallRegKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
}

##################################################################################
$uninstallDriveName = "Uninstall"
$uninstallDrive = $uninstallDriveName + ":"

# Attempt to get an existing  uninstall drive.
trap [System.IO.DriveNotFoundException]
{
  # Attempt to get the drive to use for uninstalling the application.
  $uninstallPSDrive = Get-PSDrive $uninstallDriveName
}
# Did we find a valid uninstall drive?
if (!$uninstallPSDrive)
{ 
  # The error 'Cannot find drive' above is normal, we will create the drive now as it does not exists already.
  New-PSDrive -Name $uninstallDriveName -PSProvider Registry -Root $uninstallRegKey | Out-Null
}

##################################################################################
# If the current script does not work, replace the line
$uninstallCmd = Get-ChildItem -Path $uninstallDrive | Where-Object { $productName -eq $_.GetValue("DisplayName") } | ForEach-Object -Process { $_.GetValue("UninstallString") }
# by this one:
#$uninstallCmd = (Get-ChildItem -Path $uninstallDrive | Where-Object { $productName -eq $_.GetValue("DisplayName") }).GetValue("UninstallString")

# Ensure we have a valid command.
if ($uninstallCmd -ne $null)
{
  "Uninstalling..."
  # Extract the Product Code from the command.
  $productCode = ([regex]'.*(?<ProductCode>\{[0-9A-Z-]*\}).*').Matches($uninstallCmd) | foreach {$_.Groups[1].Value}
  # Make sure we managed to get the required Product Code.
  if ($productCode -ne $null)
  {
    # Complete the arguments with the Product Code.
    $msiexecArgs = $msiexecUninstallArgs -f $productCode
    $msiexec + " " + $msiexecArgs
    # Execute the process.
    $process = [Diagnostics.Process]::Start($msiexec, $msiexecArgs)
    # Wait for the process to complete.
    $process.WaitForExit()
    # Track tke exit code.
    $exitCode = $process.ExitCode
    # Make sure the process is terminated.
    $process.Close()
  }
  "Done.`n"
}

# Check for an exit code from an potential uninstall command.
if ($exitCode -eq 0)
{
  "Installing..."
  # Complete the arguments with the MSI to install.
  $msiexecArgs = $msiexecInstallArgs -f $msiFile
  $msiexec + " " + 'msiexecArgs'
  # Execute the process.
  $process = [Diagnostics.Process]::Start($msiexec, $msiexecArgs)
  # Wait for the process to complete.
  $process.WaitForExit()
  # Track tke exit code.
  $exitCode = $process.ExitCode
  # Make sure the process is terminated.
  $process.Close()
  "Done.`n"
}

# Determine if we have an error with the process.
if ($exitCode -gt 0)
{
  "Exiting with error: " + $exitCode + "`n"
}
else
{
  "The script completed successfully.`n"
}

# Complete the process raising the error, if any.
exit $exitCode

# SIG # Begin signature block
# MIIh7QYJKoZIhvcNAQcCoIIh3jCCIdoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDUS+qkragVLpge
# 38CjD/M4bkSi4TP5sgYpjbwo0/uGmqCCC4MwggULMIID86ADAgECAhMzAAAAM1b2
# lB2ajL3lAAAAAAAzMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTAwHhcNMTMwOTI0MTczNTU1WhcNMTQxMjI0MTczNTU1WjCBgzEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9Q
# UjEeMBwGA1UEAxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAs9KaOIfw6Oly8PBcJp2mW2pAcbiYWLBfGneq+Oed
# i8Vc8IrjSTO4bEGak9UTxlyKNykoTjwpF275u22O3FPFEQPJU96Y8PFN7E2x8gh4
# 6ftxxmL9XCqnZGd4YJ+qhW3OPuJq9DLc14DJiKAxmHE69CH3N65QJId20RHix/47
# PaEYkBalXwSZ6JLjG9MJSFwmBVUb3WilzUsPv/XM3lWltHUqcbSZwjsM5NKR2HKK
# +eyHIqxqWb90NUky2K0jSbVnEJgQy9TIljp84OA+7ei+v2Lo4dJ7eAYGodazlE1W
# BQ2vCD7ItSKc/m0QL+tjGxW5kCeRZ/sSHyvcdveB1CphyQIDAQABo4IBejCCAXYw
# HwYDVR0lBBgwFgYIKwYBBQUHAwMGCisGAQQBgjc9BgEwHQYDVR0OBBYEFPBHESyD
# Hm5wg0qUmlqkIi/UPOxLMFEGA1UdEQRKMEikRjBEMQ0wCwYDVQQLEwRNT1BSMTMw
# MQYDVQQFEyozODA3NisxMzVlOTk3ZC0yZmUyLTQ3MWMtYjIxYy0wY2VmNjA1OGU5
# ZjYwHwYDVR0jBBgwFoAU5vxfe7siAFjkck619CF0IzLm76wwVgYDVR0fBE8wTTBL
# oEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljQ29kU2lnUENBXzIwMTAtMDctMDYuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
# BgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWND
# b2RTaWdQQ0FfMjAxMC0wNy0wNi5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0B
# AQsFAAOCAQEAUCzVYWVAmy0CuJ1srWZf0GzTE7bv6EBw3KVMIUi+aQDV1Cmyip6P
# 0aaVqwn2IU4fZCm9cISyrZvvZtsBgZo427YflDWZwXnJVdOhfnUfXD0Ql0G3/eXq
# nwZrQED6XhbKSWXC6g3R47bWLMO2FxrD+oC81yC5iYGvJFCy+iWW7T7Sp2MMr8nZ
# XUmh7VwqxLmESRL9SG0I1jBJeiw3np61RvhG9K7I3ADQAlAwgs07dOphCztGdya7
# LMU0aPEHo4nShwMWGGISjVayRZ3K3KlQQgWDzrgF4alEgf5eHQObN3ZA01YoN2Ir
# J5IcVCEDiAcMbEMVqFPt6srBJveymDXpPDCCBnAwggRYoAMCAQICCmEMUkwAAAAA
# AAMwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1
# dGhvcml0eSAyMDEwMB4XDTEwMDcwNjIwNDAxN1oXDTI1MDcwNjIwNTAxN1owfjEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWlj
# cm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMDCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAOkOZFB5Z7XE4/0JAEyelKz3VmjqRNjPxVhPqaV2fG1FutM5
# krSkHvn5ZYLkF9KP/UScCOhlk84sVYS/fQjjLiuoQSsYt6JLbklMaxUH3tHSwoke
# cZTNtX9LtK8I2MyI1msXlDqTziY/7Ob+NJhX1R1dSfayKi7VhbtZP/iQtCuDdMor
# sztG4/BGScEXZlTJHL0dxFViV3L4Z7klIDTeXaallV6rKIDN1bKe5QO1Y9OyFMjB
# yIomCll/B+z/Du2AEjVMEqa+Ulv1ptrgiwtId9aFR9UQucboqu6Lai0FXGDGtCpb
# nCMcX0XjGhQebzfLGTOAaolNo2pmY3iT1TDPlR8CAwEAAaOCAeMwggHfMBAGCSsG
# AQQBgjcVAQQDAgEAMB0GA1UdDgQWBBTm/F97uyIAWORyTrX0IXQjMubvrDAZBgkr
# BgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUw
# AwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBN
# MEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
# cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoG
# CCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDCBnQYDVR0gBIGVMIGSMIGPBgkrBgEE
# AYI3LgMwgYEwPQYIKwYBBQUHAgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9Q
# S0kvZG9jcy9DUFMvZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcA
# YQBsAF8AUABvAGwAaQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZI
# hvcNAQELBQADggIBABp071dPKXvEFoV4uFDTIvwJnayCl/g0/yosl5US5eS/z7+T
# yOM0qduBuNweAL7SNW+v5X95lXflAtTx69jNTh4bYaLCWiMa8IyoYlFFZwjjPzwe
# k/gwhRfIOUCm1w6zISnlpaFpjCKTzHSY56FHQ/JTrMAPMGl//tIlIG1vYdPfB9XZ
# cgAsaYZ2PVHbpjlIyTdhbQfdUxnLp9Zhwr/ig6sP4GubldZ9KFGwiUpRpJpsyLcf
# ShoOaanX3MF+0Ulwqratu3JHYxf6ptaipobsqBBEm2O2smmJBsdGhnoYP+jFHSHV
# e/kCIy3FQcu/HUzIFu+xnH/8IktJim4V46Z/dlvRU3mRhZ3V0ts9czXzPK5UslJH
# asCqE5XSjhHamWdeMoz7N4XR3HWFnIfGWleFwr/dDY+Mmy3rtO7PJ9O1Xmn6pBYE
# AackZ3PPTU+23gVWl3r36VJN9HcFT4XG2Avxju1CCdENduMjVngiJja+yrGMbqod
# 5IXaRzNij6TJkTNfcR5Ar5hlySLoQiElihwtYNk3iUGJKhYP12E8lGhgUu/WR5mg
# gEDuFYF3PpzgUxgaUB04lZseZjMTJzkXeIc2zk7DX7L1PUdTtuDl2wthPSrXkizO
# N1o+QEIxpB8QCMJWnL8kXVECnWp50hfT2sGUjgd7JXFEqwZq5tTG3yOalnXFMYIV
# wDCCFbwCAQEwgZUwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEoMCYGA1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMAITMwAA
# ADNW9pQdmoy95QAAAAAAMzANBglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkq
# hkiG9w0BCQQxIgQgkCwpi4cDTH76tuAV6AObnHtdPMf/FbZeEAV2Bghb37gwQgYK
# KwYBBAGCNwIBDDE0MDKgGIAWAG0AcwBpAGUAeABlAGMALgBwAHMAMaEWgBRodHRw
# Oi8vbWljcm9zb2Z0LmNvbTANBgkqhkiG9w0BAQEFAASCAQAsije9UqNe9QP86oY9
# MwJztkKcui3VuZAO+IUQPwjccpZqU1dJ3BmC7wDcbHrQWakWRu35umFFqy6d7BBf
# eJI2DbQN8igRWbaTdanlDXmzFhdg2Xjn0R8t5vmMJp7qHinqRntz3w+js6LHQU8P
# ZBm4iS4+517p+5971RgVPaZ3lTFaK1NshYm8iP6dxpeYUHD0m8BbzLG5bFAzWH93
# nB23EwJaTRwHqm5NUUzxuTAv2Uzf4/rZPkMgCifwkpXXTjMzY/pZ75nFx7Dy8jo4
# KiaFojVuVT7YyJeBDP+tedjazSOZk3lq0yE36zsxcUmDgAn7QzlR4qUhBfhvpB/s
# kJMdoYITSjCCE0YGCisGAQQBgjcDAwExghM2MIITMgYJKoZIhvcNAQcCoIITIzCC
# Ex8CAQMxDzANBglghkgBZQMEAgEFADCCAT0GCyqGSIb3DQEJEAEEoIIBLASCASgw
# ggEkAgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIMpklWXolL4X70Dt
# Uyz59TqgVPvboTjNsIQ54OhT6oC1AgZSaT1KxEEYEzIwMTMxMDI1MjEzODQxLjg4
# MVowBwIBAYACAfSggbmkgbYwgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xDTALBgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVT
# TjozMUM1LTMwQkEtN0M5MTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# U2VydmljZaCCDs0wggZxMIIEWaADAgECAgphCYEqAAAAAAACMA0GCSqGSIb3DQEB
# CwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYD
# VQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAe
# Fw0xMDA3MDEyMTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0
# YW1wIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqR0N
# vHcRijog7PwTl/X6f2mUa3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AVUycE
# MR9BGxqVHc4JE458YTBZsTBED/FgiIRUQwzXTbg4CLNC3ZOs1nMwVyaCo0UN0Or1
# R4HNvyRgMlhgRvJYR4YyhB50YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvfYfxG
# wScdJGcSchohiq9LZIlQYrFd/XcfPfBXday9ikJNQFHRD5wGPmd/9WbAA5ZEfu/Q
# S/1u5ZrKsajyeioKMfDaTgaRtogINeh4HLDpmc085y9Euqf03GS9pAHBIAmTeM38
# vMDJRF1eFpwBBU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGCNxUBBAMCAQAwHQYD
# VR0OBBYEFNVjOlyKMZDzQ3t8RhvFM2hahW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1
# AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaA
# FNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9j
# cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8y
# MDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6
# Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAt
# MDYtMjMuY3J0MIGgBgNVHSABAf8EgZUwgZIwgY8GCSsGAQQBgjcuAzCBgTA9Bggr
# BgEFBQcCARYxaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9k
# ZWZhdWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBQAG8AbABp
# AGMAeQBfAFMAdABhAHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEA
# B+aIUQ3ixuCYP4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkws8LFZslq3/Xn8Hi9
# x6ieJeP5vO1rVFcIK1GCRBL7uVOMzPRgEop2zEBAQZvcXBf/XPleFzWYJFZLdO9C
# EMivv3/Gf/I3fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6AG9LMEQkIjzP
# 7QOllo9ZKby2/QThcJ8ySif9Va8v/rbljjO7Yl+a21dA6fHOmWaQjP9qYn/dxUoL
# kSbiOewZSnFjnXshbcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2eGq4E
# QoO4tYCbIjggtSXlZOz39L9+Y1klD3ouOVd2onGqBooPiRa6YacRy5rYDkeagMXQ
# zafQ732D8OE7cQnfXXSYIghh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fecn5h
# a293qYHLpwmsObvsxsvYgrRyzR30uIUBHoD7G4kqVDmyW9rIDVWZeodzOwjmmC3q
# jeAzLhIp9cAvVCch98isTtoouLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99j
# e/WZii8bxyGvWbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9zOZN+w2/XU/pnR4ZOC+8
# z1gFLu8NoFA12u8JJxzVs341Hgi62jbb01+P3nSISRIwggTaMIIDwqADAgECAhMz
# AAAAK3KqLvZJu+zXAAAAAAArMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFBDQSAyMDEwMB4XDTEzMDMyNzIwMTMxNVoXDTE0MDYyNzIwMTMxNVow
# gbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsT
# BE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjozMUM1LTMwQkEtN0M5MTEl
# MCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAN2e7fz6fx0XHYjVwdFvEkm8OBoR7S1jbRn8
# 0K7Hwq+POtHGvap3FWQUJwIXkt0vZYundEd3lygk+EdDahjD8m187n9MAkQ+bUVB
# g21tce1ZZJm2Wq6xgq875FTqavpB9Riq3QvVycR+EOw+VH3jdeUNcggEhRYNtmsn
# Wqhsgj2kNx7T3Bb8NsYOUqqoigzu47WWUCyGKr6zDW/1UipUuSRIMg1SFT0n44Dd
# X4LOLn2FEcNigXqFel8Efnppr5NNo9+w1rK2XW5mQe8TuZrZbcUmcISiBxVca7fj
# NDknc8qoR/MxaQVx7XwLQ9bYmRMFCIdD2A+rcHEcmkeD0jkMaPMCAwEAAaOCARsw
# ggEXMB0GA1UdDgQWBBQAiGCC8vVg5QaXoz/L8OMlyxXgFTAfBgNVHSMEGDAWgBTV
# YzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNUaW1TdGFQQ0FfMjAx
# MC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0YVBDQV8yMDEwLTA3
# LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqG
# SIb3DQEBCwUAA4IBAQAGFlfneYxLGzjxjsyeztR1b538YJbmZ1WRhlthrCsxSfAU
# jGVJ73rQV5o5n38Wp64xV8CS66n3uSr4ye2PYCaaDttihNrE9mIgyP8hGFzJ7ppy
# i6/Lk8xEP2kq9V2CxlmrTpJRbuQpETj9dHbiAQvAdPtWJ9xHibjZpRx3AzVxWCbG
# tCveB6NIKNPmQBP022sZVCuu8c6pry2zwdW21NU5MgSe6ncOV+JFTA2XRbwXq7Vj
# ZJOjoGnm1aobZkFP2EIVvEom8mj/PTz2YuwT0dwv61Ix18M4L6qGIoUOGL4o9Dhc
# 5+hPwfD2CHLJytdsk0DEBBXeiVMygnq0J6IINaO8oYIDdjCCAl4CAQEwgeOhgbmk
# gbYwgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNV
# BAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjozMUM1LTMwQkEtN0M5
# MTElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEBMAkG
# BSsOAwIaBQADFQAXSgPawQ6j+TZ4Geb4RTYGWAMmvKCBwjCBv6SBvDCBuTELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEn
# MCUGA1UECxMebkNpcGhlciBOVFMgRVNOOkIwMjctQzZGOC0xRDg4MSswKQYDVQQD
# EyJNaWNyb3NvZnQgVGltZSBTb3VyY2UgTWFzdGVyIENsb2NrMA0GCSqGSIb3DQEB
# BQUAAgUA1hThnTAiGA8yMDEzMTAyNTEyMjUwMVoYDzIwMTMxMDI2MTIyNTAxWjB0
# MDoGCisGAQQBhFkKBAExLDAqMAoCBQDWFOGdAgEAMAcCAQACAgsMMAcCAQACAhiw
# MAoCBQDWFjMdAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwGgCjAI
# AgEAAgMW42ChCjAIAgEAAgMHoSAwDQYJKoZIhvcNAQEFBQADggEBACZOSJiHy/mM
# xzGH+7HxVK7mfRxKNN7j5sUAx/1QsQQh7E/ihjgUhdqVfh+iKXdT8qiaf7SFZ71H
# hMnAmw0Ox2QDCUtn/aZ25IZFsDIMAorIOEqgGjtVzr0sSxvqUnEu1Xv3tA28WLay
# DM/XebXD9a8HL0wb2grQXyHPUSgrdcfAzcJguiyebyCOcM6bQVtJ0SmDxOC2E0yq
# DJp6i92qlU5BauZBAS5UU8Kf0sypi2o6RNzjsv0iOAva1t2yD8v/8PGSX1OBwaox
# mqFscyG8CKZHt9bGnQBEpEeV0Ig3YpkuyLZjFReIJ4iB5PH7lL0IRtUXvjmYOWAx
# +I9Dzzheo5cxggL1MIIC8QIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMAITMwAAACtyqi72Sbvs1wAAAAAAKzANBglghkgBZQMEAgEFAKCCATIwGgYJ
# KoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCCrUCmRyU+w
# SranqpxFmIL1idjqNqdF0TPLdpcvJsYKNDCB4gYLKoZIhvcNAQkQAgwxgdIwgc8w
# gcwwgbEEFBdKA9rBDqP5NngZ5vhFNgZYAya8MIGYMIGApH4wfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTACEzMAAAArcqou9km77NcAAAAAACswFgQUWGH11IIG
# KzxCNqLSWiEnY1iKfZwwDQYJKoZIhvcNAQELBQAEggEAbEFELog92FCg5g4qa7gH
# NhslK8ignrscBOSygni4hrgf+b2oph1TapB/ChnaLjX3V2pjPzUrhpkYZDevYScF
# iUm0D1XryPMUSb9l8uZKoCxoIOOw9ZW0Qwug6lWgx0Z2C6Q/6m03P6MCNRRzk5ju
# eGUtAY6sE2ehOp23uKXhP3GmFrKfGyc3LEsj0GBTmb1X4Yh0tHKek0Zx/HfBuXGX
# UMK8pKkPSDUXW1uYgOO6qNJJYV6qB2RPyHKHvzxespG32KYAi6oQjgBXEjOuAsrQ
# 9Mxfou++ZcvwQpYL4e3CFkisbU6qrfeiCp30htRXrrP5iJRZkDTzDGS1z9dsCktp
# 5A==
# SIG # End signature block
