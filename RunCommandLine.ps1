##################################################################################
# Define input parameters.
param
(
  [string]$FilePath = $null,
  [string]$Arguments = $null,
  [string]$UserDomain = $null,
  [string]$UserName = $null,
  [string]$UserPassword = $null,  
  [string]$WorkingDirectory = $null
)

cls

##################################################################################
# Output the logo.
"Microsoft Release Management RunCommandLine PowerShell Script v12.0"
"Copyright (c) 2013 Microsoft. All rights reserved.`n"

##################################################################################
# Output execution parameters.
"Executing with the following parameters:"
"  FilePath: $FilePath"
"  Arguments: ($Arguments)"
"  User Name: $UserName"
"  User Password: (omitted)"
"  User Domain: $UserDomain"
if ($WorkingDirectory)
{
  "  Working Directory: $WorkingDirectory`n"
}
else
{
  "  Working Directory: (script path)`n"
}

##################################################################################
# Initialize the default script exit code.
$exitCode = 0

##################################################################################
# Format errors to be more verbose.
trap
{
  $e = $error[0].Exception
  $e.Message
  $e.StackTrace
  if ($exitCode -eq 0) { $exitCode = 1 }
}

##################################################################################  
# Get the name of the script executing.
$scriptName = $MyInvocation.MyCommand.Name

##################################################################################  
# Get the path from where the script is executing.
$scriptPath = Split-Path -Parent (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Path

##################################################################################  
# Change the working directory to that from where the script is executing.
Push-Location $scriptPath    

##################################################################################
# Provides help information about this script.
function Show-Help
{
  "USAGE:`n"
  "$scriptName [-FilePath] <filePath> [[-Arguments] args [-UserName] <username> [-UserPassword] <password>] [-UserDomain] <domain> [-WorkingDirectory] <dir>]`n"
  "WHERE:`n"
  "FilePath`t`t`tFully qualified path to the executable to run."
  "Arguments`t`tOptional. Executable arguments."
  "UserName`t`tOptional. Name of the identity under which to run."
  "UserPassword`t`tOptional. Mandatory if UserName is specified.`n`t`t`tPassword of the identity under which to run."
  "UserDomain`t`tOptional. Domain name of the identity under which to`n`t`t`trun."
  "WorkingDirectory`tOptional. Working directory of the executable to run.`n"
}

##################################################################################
# Sets this script's exit code.
function Set-ScriptExitCode
{
  param
  (
    [int]$code = $(throw "The Exit Code must be provided.")
  )

  # Set the exit code globally using Set-Variable so we can specify
  # the scope. Otherwise, the value will not be overwritten.
  Set-Variable -Name exitCode -Value $code -Scope "Script"
}

##################################################################################
# Starts an external process and returns its exit code.
function Start-Process
{
  param
  (
    [string]$fileName = $(throw "The FileName must be provided."),
    [string]$arguments = $null,
    [string]$userName = $null,
    [string]$uerPassword = $null,
    [string]$userDomain = $null,
    [string]$workingDirectory = $null
  )

  # Prepare specifics for starting the process that will install the component.
  $startInfo = New-Object System.Diagnostics.ProcessStartInfo
  $startInfo.CreateNoWindow = $true
  $startInfo.ErrorDialog = $false
  $startInfo.FileName = $fileName
  $startInfo.RedirectStandardError = $true
  $startInfo.RedirectStandardInput = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.UseShellExecute = $false
  $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
  $startInfo.WorkingDirectory = $workingDirectory

  # Set arguments for the call, but only if specified.
  if ($arguments)
  {
    $startInfo.Arguments = $arguments
  }

  # Run as a different user
  if ($userName)
  {
    $startInfo.UserName = $userName
    $startInfo.Password = ConvertTo-SecureString $userPassword -AsPlainText -Force
    $startInfo.Domain = $userDomain
  }

  # Initialize a new process.
  $process = New-Object System.Diagnostics.Process
  try
  {
    # Configure the process so we can capture all its output.
    $process.EnableRaisingEvents = $true
    # Hook into the standard output and error stream events
    $errEvent = Register-ObjectEvent -SourceIdentifier OnErrorDataReceived $process "ErrorDataReceived" `
      `
      {
        param
        (
          [System.Object] $sender,
          [System.Diagnostics.DataReceivedEventArgs] $e
        )
        foreach ($s in $e.Data) { if ($s) { Write-Host $s -ForegroundColor Red } }
      }
    $outEvent = Register-ObjectEvent -SourceIdentifier OnOutputDataReceived $process "OutputDataReceived" `
      `
      {
        param
        (
          [System.Object] $sender,
          [System.Diagnostics.DataReceivedEventArgs] $e
        )
        foreach ($s in $e.Data) { if ($s) { Write-Host $s } }
      }
    $process.StartInfo = $startInfo;
    "Executing $fileName"
    # Attempt to start the process.
    if ($process.Start())
    {
      # Read from all redirected streams before waiting to prevent deadlock.
      $process.BeginErrorReadLine()
      $process.BeginOutputReadLine()
      # Wait for the application to exit for no more than 5 minutes.
      $process.WaitForExit() | Out-Null
    }
    else
    {
      # Indicate an error occured during execution of process.
      Set-ScriptExitCode 9999
    }
    # Determine if process failed to execute.
    if ($process.ExitCode -ne 0)
    {
      # Update this script's exit code.
      Set-ScriptExitCode $process.ExitCode
      # Throwing an exception at this point will stop any subsequent
      # attempts for deployment.
      throw New-Object System.Exception($startInfo.FileName + ' exited with code: ' + $process.ExitCode)
    }
  }
  finally
  {
    # Free all resources associated to the process.
    $process.Close();
    # Remove any previous event handlers.
    Unregister-Event OnErrorDataReceived -Force | Out-Null
    Unregister-Event OnOutputDataReceived -Force | Out-Null

    # Output outcome of the call.
    if ($exitCode -eq 0)
    {
      "Done.`n"
    }
    else
    {
      Write-Host "Done with errors.`n" -ForegroundColor Red
    }
  }
}

##################################################################################
# Validate parameters.
if (-not $FilePath -or ($UserName -and -not $UserPassword))
{
  Show-Help
  
  if (-not $FilePath)
  {
    Write-Host "Command FilePath must be specified.`n" -ForegroundColor Red
  }
  
  if ($UserName -and -not $UserPassword)
  {
    Write-Host "UserPassword must be specified if UserName is specified.`n" -ForegroundColor Red
  }

  $exitCode = 1
}
if (-not $WorkingDirectory)
{
  $WorkingDirectory = $scriptPath
}

##################################################################################  
# Check for an exit code from the install command.
if ($exitCode -eq 0)
{
  try
  {
    # Execute the command.
    Start-Process -fileName $FilePath -arguments $Arguments -userName $UserName -uerPassword $UserPassword -userDomain $UserDomain -workingDirectory $WorkingDirectory
  }
  catch [System.Exception]
  {
    # Prevent further execution.
    if ($exitCode -eq 0) { $exitCode = 1 }
    #Write-Eventlog -logname 'Application' -source 'Application' -eventID 1000 -EntryType Error -message $_.Exception.Message
    Write-Host $_.Exception.Message "`n" -ForegroundColor Red
   }
}

##################################################################################
# Analyze the result of the execution.

# Determine if we have an error with the process.
if ($exitCode -eq 0)
{
  "The script completed successfully.`n"
}
else
{
  $err = "Exiting with error: " + $exitCode + "`n"
  Write-Host $err -ForegroundColor Red
}

##################################################################################
# Restore any location change.
Pop-Location

##################################################################################
# Complete the process raising the error, if any.
exit $exitCode

# SIG # Begin signature block
# MIIh/gYJKoZIhvcNAQcCoIIh7zCCIesCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDWZVRkBgPX55n/
# Ft6caacT2IvvlzxCbacXfTj0VC82aKCCC4MwggULMIID86ADAgECAhMzAAAAM1b2
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
# 0TCCFc0CAQEwgZUwfjELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEoMCYGA1UEAxMfTWljcm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMAITMwAA
# ADNW9pQdmoy95QAAAAAAMzANBglghkgBZQMEAgEFAKCBvDAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkq
# hkiG9w0BCQQxIgQgGCR1fQmJMjfWazPp2HIxzI3f8c+7Agmks6fN80+mCogwUAYK
# KwYBBAGCNwIBDDFCMECgJoAkAFIAdQBuAEMAbwBtAG0AYQBuAGQATABpAG4AZQAu
# AHAAcwAxoRaAFGh0dHA6Ly9taWNyb3NvZnQuY29tMA0GCSqGSIb3DQEBAQUABIIB
# AKYieAP1JB5WF6U5P8HTzsP6fshFHyGyUoKvesBgGBrW64bjraVqw9sYpZGyQeLK
# wniB8tmOt+IuuUUl7zQ9CMyc7JE5nj/FV5BAVPlt8F5jli4/3wJ/ACVezwX+n9Fq
# WHVVXNvILHJqDk952YSkqa48x7AsATQRPFjEbtcql92co363qkAAtnG6SOfUb9iS
# jacExXklW85mJCeDWmlwVlAFBOFg4lOTch81W+/MtD32Ij00Kjyb0IUKMJFVJ4OU
# OV3xLKBFoaeC6x8B2UiVOMn/+WNcOBVWRZn53jNycC7FshVYhmInAumxBPrEm3Gn
# AUK/F8nfsYdtDE8o9thGRdihghNNMIITSQYKKwYBBAGCNwMDATGCEzkwghM1Bgkq
# hkiG9w0BBwKgghMmMIITIgIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBPQYLKoZIhvcN
# AQkQAQSgggEsBIIBKDCCASQCAQEGCisGAQQBhFkKAwEwMTANBglghkgBZQMEAgEF
# AAQgf0Emkoow6e8PFF/MJrBqClwjsMXCKqo5t993N+oZut8CBlLemud8URgTMjAx
# NDAyMjAxNDI5MjMuODI4WjAHAgEBgAIB9KCBuaSBtjCBszELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMe
# bkNpcGhlciBEU0UgRVNOOjdEMkUtMzc4Mi1CMEY3MSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIO0DCCBnEwggRZoAMCAQICCmEJgSoAAAAA
# AAIwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNo
# aW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
# cG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1
# dGhvcml0eSAyMDEwMB4XDTEwMDcwMTIxMzY1NVoXDTI1MDcwMTIxNDY1NVowfDEL
# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v
# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWlj
# cm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQCpHQ28dxGKOiDs/BOX9fp/aZRrdFQQ1aUKAIKF++18aEssX8XD
# 5WHCdrc+Zitb8BVTJwQxH0EbGpUdzgkTjnxhMFmxMEQP8WCIhFRDDNdNuDgIs0Ld
# k6zWczBXJoKjRQ3Q6vVHgc2/JGAyWGBG8lhHhjKEHnRhZ5FfgVSxz5NMksHEpl3R
# YRNuKMYa+YaAu99h/EbBJx0kZxJyGiGKr0tkiVBisV39dx898Fd1rL2KQk1AUdEP
# nAY+Z3/1ZsADlkR+79BL/W7lmsqxqPJ6Kgox8NpOBpG2iAg16HgcsOmZzTznL0S6
# p/TcZL2kAcEgCZN4zfy8wMlEXV4WnAEFTyJNAgMBAAGjggHmMIIB4jAQBgkrBgEE
# AYI3FQEEAwIBADAdBgNVHQ4EFgQU1WM6XIoxkPNDe3xGG8UzaFqFbVUwGQYJKwYB
# BAGCNxQCBAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMB
# Af8wHwYDVR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBL
# oEmgR4ZFaHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMv
# TWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggr
# BgEFBQcwAoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNS
# b29DZXJBdXRfMjAxMC0wNi0yMy5jcnQwgaAGA1UdIAEB/wSBlTCBkjCBjwYJKwYB
# BAGCNy4DMIGBMD0GCCsGAQUFBwIBFjFodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v
# UEtJL2RvY3MvQ1BTL2RlZmF1bHQuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBn
# AGEAbABfAFAAbwBsAGkAYwB5AF8AUwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqG
# SIb3DQEBCwUAA4ICAQAH5ohRDeLG4Jg/gXEDPZ2joSFvs+umzPUxvs8F4qn++ldt
# GTCzwsVmyWrf9efweL3HqJ4l4/m87WtUVwgrUYJEEvu5U4zM9GASinbMQEBBm9xc
# F/9c+V4XNZgkVkt070IQyK+/f8Z/8jd9Wj8c8pl5SpFSAK84Dxf1L3mBZdmptWvk
# x872ynoAb0swRCQiPM/tA6WWj1kpvLb9BOFwnzJKJ/1Vry/+tuWOM7tiX5rbV0Dp
# 8c6ZZpCM/2pif93FSguRJuI57BlKcWOdeyFtw5yjojz6f32WapB4pm3S4Zz5Hfw4
# 2JT0xqUKloakvZ4argRCg7i1gJsiOCC1JeVk7Pf0v35jWSUPei45V3aicaoGig+J
# FrphpxHLmtgOR5qAxdDNp9DvfYPw4TtxCd9ddJgiCGHasFAeb73x4QDf5zEHpJM6
# 92VHeOj4qEir995yfmFrb3epgcunCaw5u+zGy9iCtHLNHfS4hQEegPsbiSpUObJb
# 2sgNVZl6h3M7COaYLeqN4DMuEin1wC9UJyH3yKxO2ii4sanblrKnQqLJzxlBTeCG
# +SqaoxFmMNO7dDJL32N79ZmKLxvHIa9Zta7cRDyXUHHXodLFVeNp3lfB0d4wwP3M
# 5k37Db9dT+mdHhk4L7zPWAUu7w2gUDXa7wknHNWzfjUeCLraNtvTX4/edIhJEjCC
# BNowggPCoAMCAQICEzMAAAAtJYEUX6LV8tMAAAAAAC0wDQYJKoZIhvcNAQELBQAw
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMTMwMzI3MjAxMzE1WhcN
# MTQwNjI3MjAxMzE1WjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNOOjdE
# MkUtMzc4Mi1CMEY3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2
# aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1pKuQV2ZMt/pnhIo
# hAvXbq2LIS6i+avhnbcn/0jm+XYjSkWWPUnBCtJlBUm6mcid8VA7Q0nYmKJCK3NB
# gm56BOWP07M0xB8G0wonOu51aso61dlKjpAm9W5fTfftvIOQYRwJVLQzag05J826
# rPazZVd/AFtN+FeuQVpLD6zuWeAvJ8iIVDLAigHNUMqaD1HJNL1KeKIrqd47/Hpf
# KK2hn1U3IK/1RS3hICMIt1pFKnC3iaB+MkxFx2y++bN5FvYBeJPFMy3qxYuaE40a
# UZPqzPWrBI6F7MBGu3p1OOyFqwX5ogctFnHsNWY4CTdRZbmff56WgtmCsecJpUcH
# EQFDIQIDAQABo4IBGzCCARcwHQYDVR0OBBYEFD/f4VXZ6F8EBdLeXV4scfhIlZDR
# MB8GA1UdIwQYMBaAFNVjOlyKMZDzQ3t8RhvFM2hahW1VMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljVGlt
# U3RhUENBXzIwMTAtMDctMDEuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYI
# KwYBBQUHAwgwDQYJKoZIhvcNAQELBQADggEBAD0ELwrTHFROtpy60To/R4E+VO45
# GHUA557eEYETxEcDpMX6/0i1qLirXjMop2I54Vo5gAT9x7iEZCkWDrp6yhFPpeTw
# fJVin3L47jDfTpGuzcqj5AcMRLJHHqnliurF/XXVwf+MCXEusVFC1OSCg/jRX3xQ
# RJfw94vhhZAdlJ+j+lBpEXUpYwa7WNOGq2LvmLqxOkYhcwgJfUIb/wAcF1Nl9X1e
# 4LvcJFSvGJBArOF7qszR4pv0uCNPRDHmSfVummTR77QY9nM6RhNpk5yX/qnTEZfC
# SwZb+vtRA0VgjJyyVDflGn85R0UaHx1+opIsUvcCM0/BP/5fubN5vVYMOAqhggN5
# MIICYQIBATCB46GBuaSBtjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OjdEMkUtMzc4Mi1CMEY3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloiUKAQEwCQYFKw4DAhoFAAMVAMcS9+H8xjNYA1YQxFyBgngalGQUoIHC
# MIG/pIG8MIG5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMQ0w
# CwYDVQQLEwRNT1BSMScwJQYDVQQLEx5uQ2lwaGVyIE5UUyBFU046QjAyNy1DNkY4
# LTFEODgxKzApBgNVBAMTIk1pY3Jvc29mdCBUaW1lIFNvdXJjZSBNYXN0ZXIgQ2xv
# Y2swDQYJKoZIhvcNAQEFBQACBQDWr8qdMCIYDzIwMTQwMjIwMDAyODEzWhgPMjAx
# NDAyMjEwMDI4MTNaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFANavyp0CAQAwCgIB
# AAICBNoCAf8wBwIBAAICGDUwCgIFANaxHB0CAQAwNgYKKwYBBAGEWQoEAjEoMCYw
# DAYKKwYBBAGEWQoDAaAKMAgCAQACAxbjYKEKMAgCAQACAwehIDANBgkqhkiG9w0B
# AQUFAAOCAQEAUN3b+IKpf1dK/5NrxJe5faENzYhxRLgHgJHajZ3fGGLXSpgJT4ky
# wx4EX7HKzJTDVbfT98KQY6XgFdF8mVy15Oc0DhgjT9QcaVn4l3mjU7iwcBtFh4ID
# YuRBYT/IWUw8Fwl6E58WvtImxJhlhqZKZpM/YUum6UzNqIwWusoCAfa93qhKiYVy
# X9KgFu49J0PIi38iqfkfBO31i5okLseOd/BXbCRml4oXbrqvDS1NhCk7i7b7Qw58
# b3e2ZUlIDXJ9gzBdsFT33EWywaqkGoYgi/OIlHvaBMBuwHFL8mA+wsyIm1DJqKjW
# U/5sgRPoOcp+K1+hnReJcvxOoYsvdOpQlDGCAvUwggLxAgEBMIGTMHwxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29m
# dCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAAALSWBFF+i1fLTAAAAAAAtMA0GCWCG
# SAFlAwQCAQUAoIIBMjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQAQQwLwYJKoZI
# hvcNAQkEMSIEIDynq3xmaxAvkKLIufrzJbRLRxRcu/jzJ0CBYr3ve7oSMIHiBgsq
# hkiG9w0BCRACDDGB0jCBzzCBzDCBsQQUxxL34fzGM1gDVhDEXIGCeBqUZBQwgZgw
# gYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAC0lgRRfotXy
# 0wAAAAAALTAWBBTyqgUAun6UUyz/hJykR8UYY5NjUzANBgkqhkiG9w0BAQsFAASC
# AQCAGZo12Tb+P+mdAWEfvGJimEqM+3OxX9l+1Xn7dzWH/YtW0Sjfn1snEecHK9Sp
# cFOF/su5RyWC+Sr8CiDNXToZkNLmb2GoQXFdLUinEpAWySbJJJiyGINXSShL+shr
# Cz+0iClWkb27J8PbTnB6H2aFeLZYDaRw1RQWlx7E3AnUs/wYCXA4D9qWqgrfdmMt
# ln87WI5mg0/p7Lpz8ombrkpwIPxBHFKD32jRmLpE49oQgI/THOBwNOTgcJUgzLVP
# ExcOcrAtDZKMA0EV0KsjI1/R92aY3B0ohvjWhf7gVA+6e0hPPMUaAXyq1tqmnfpl
# LpM4sJf0e7tU83PqETRYABnL
# SIG # End signature block
