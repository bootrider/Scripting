function Slow-Memory() {

    While ($True) {

        $Date = Get-Date
        $Minutes = Get-Random -Minimum 10 -Maximum 15
        $Duration = $Date.AddMinutes($Minutes)
        $Utilisation = Get-Random -Minimum 20 -Maximum 60
        $ComputerSystem = Get-WmiObject Win32_ComputerSystem 
        $operatingSystem = Get-WmiObject -Class WIN32_OperatingSystem 
        $Memory = [math]::truncate($ComputerSystem.TotalPhysicalMemory / 100 * $Utilisation)
        $PercentageMemoryUsed = ($operatingSystem.TotalVisibleMemorySize - $operatingSystem.FreePhysicalMemory ) * 100 / $operatingSystem.TotalVisibleMemorySize
        Write-Progress -Activity "Memory" -Status "Memory used: $PercentageMemoryUsed %" -PercentComplete $PercentageMemoryUsed
        $Memory = $Memory / 1Mb
        Write-Host "Memory to utilize = $Memory -> $Utilisation % for $Minutes minutes"
        Write-Host "Memory to utilize expected = $Utilisation % + $PercentageMemoryUsed % = $($Utilisation + $PercentageMemoryUsed)% for $Minutes minutes"

        Start-Process -FilePath testlimit64.exe -ArgumentList "-d -c $Memory" -workingdirectory "C:\Users\CGLondono\Downloads\Testlimit"
        
        Do { 
            Start-Sleep -Seconds 1
            $operatingSystem = Get-WmiObject -Class WIN32_OperatingSystem
            $PercentageMemoryUsed = ($operatingSystem.TotalVisibleMemorySize - $operatingSystem.FreePhysicalMemory ) * 100 / $operatingSystem.TotalVisibleMemorySize
            Write-Progress -Activity "Memory" -Status"Memory used: $PercentageMemoryUsed %" -PercentComplete $PercentageMemoryUsed
        }
        Until ((Get-Date) -ge $Duration)
        Get-Process | Where-Object { $_.Name -eq "testlimit64" } | Stop-Process        
    }

}


Slow-Memory