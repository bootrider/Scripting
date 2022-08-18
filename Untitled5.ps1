push-location C:\t\Repos\INS\GeoProcessingServices

$pyfiles = Get-ChildItem -Recurse -Include *.py
$pythonpath = "c:\Program Files\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\"
$python = "$pythonpath\python.exe"

$script = ".\tools\i18n\pygettext.py"

Push-Location $pythonpath

foreach($py  in $pyfiles)
{
    $arguments = @("-a" 
                   "-d"
                   "$($py.Directory)\locale\$($py.BaseName)"
                   $py.FullName
                   ) 
    & $python $script $arguments
}

$pyfiles