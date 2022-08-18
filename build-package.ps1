$version = Get-Content "$PSScriptRoot\version.txt"
$build = if ($Env:BUILD_BUILDNUMBER) { $Env:BUILD_BUILDNUMBER } else { "000" }
$fullversion = $version + "." + $build

$nameRegex = New-Object System.Text.RegularExpressions.Regex("name\s*=\s*['`"]([A-Za-z0-9_-]+)['`"]")
$versionRegex = New-Object System.Text.RegularExpressions.Regex("version\s*=\s*['`"]([0-9.]+)['`"]")
$recipeRegex = New-Object System.Text.RegularExpressions.Regex("version\s*:\s+['`"]([0-9.]+)['`"]")

Get-ChildItem -Directory "$PSScriptRoot\..\Rosen" | foreach {
    if (Test-Path "$($_.FullName)\setup.py") {
        # Iterate over projects that have a setup.py
        $projectFullPath = $_.FullName

        $setupPyPath = "$projectFullPath\setup.py"
        $setupPyContent = [System.IO.File]::ReadAllText($setupPyPath)
        $nameMatch = $nameRegex.Match($setupPyContent)
        if ($nameMatch.Success -and $versionRegex.IsMatch($setupPyContent)) {
            # The package name was found.
            $packageName = $nameMatch.Groups[1].Value

            # Change the version.
            "INFO: Versioning $setupPyPath to $fullversion"
            $setupPyContent = $versionRegex.Replace($setupPyContent, "version='$version'")
            $setupPyVersioned = $versionRegex.Replace($setupPyContent, "version='$fullversion'")
            [System.IO.File]::WriteAllText($setupPyPath, $setupPyVersioned)
            
            $recipes = @()
            Get-ChildItem -Recurse -Filter meta.yaml "$projectFullPath" | foreach {
                $recipePath = $_.FullName
                "INFO: Versioning $recipePath to $fullversion"
                $recipeContent = [System.IO.File]::ReadAllText($recipePath)
                $recipeContent = $recipeRegex.Replace($recipeContent, "version: `"$version`"")
                $recipeVersioned = $recipeRegex.Replace($recipeContent, "version: `"$fullversion`"")
                [System.IO.File]::WriteAllText($recipePath, $recipeVersioned)
                $recipes += , @($recipePath, $recipeContent)
            }

            Push-Location $projectFullPath
            try {
                "INFO: Bulding package $packageName"
                &cmd /c "conda build . --no-include-recipe --output-folder $PSScriptRoot\..\DropLocation\Deploy 2>&1"
                if (-not $?) {
                    Write-Error "ERROR: Calling conda build failed."
                    continue
                }

                "INFO: Converting the package $packageName to other platforms."
                &cmd /c "conda convert --platform all $PSScriptRoot\..\DropLocation\Deploy\win-64\$packageName-$fullversion-py36_0.tar.bz2 -o $PSScriptRoot\..\DropLocation\Deploy\ 2>&1"
                if (-not $?) {
                    Write-Error "ERROR: Calling conda convert failed."
                    continue
                }
            } finally {
                [System.IO.File]::WriteAllText($setupPyPath, $setupPyContent)
                $recipes | foreach {
                    [System.IO.File]::WriteAllText($_[0], $_[1])
                }

				# copy the .py files to the Third-party folder, I know this is an Incolmas' law implementation
				
				$thirdPartyPath = Convert-Path "$($(Get-Location).Path)\..\..\ThirdParty\Lib\site-packages" 
				$source = Join-path  $projectFullPath $packageName
				$destination = Join-Path $thirdPartyPath $packageName
				
				Copy-Item -Path $source -Destination $destination -Filter *.py  -Force -Recurse
				
                Pop-Location			
            }
        } else {
            Write-Error "The setup.py for project $projectFullPath is invalid. Check the name and version arguments."
        }

    }
}

&cmd /c "conda build purge 2>&1"


