# if ($references -ne $null)
#     {
#     # Write-Output $project.FullName | Format-Table -AutoSize
#     
#         foreach($reference in $references)
#         {            
#             if($reference -ne $null -and $reference.HintPath -match "DropLocation")
#             {    
#                 $makeChekOut = $true             
#                 $reference.HintPath = $reference.HintPath -replace "DropLocation", "DropLocation\Build"
#                 Write-Output "Reference: " $reference.HintPath | Format-Table 
#             }            
#         }        
#     }
# 
#     if ($outputpaths -ne $null)
#     {
#         foreach($outputpath in $outputpaths)
#         {            
#             if($outputpath -ne $null -and $outputpath.OutputPath -match "DropLocation")
#             {    
#                 $makeChekOut = $true             
#                 $outputpath.OutputPath = $outputpath.OutputPath -replace "DropLocation", "DropLocation\Build"
#                 Write-Output "output path: " $outputpath.OutputPath | Format-Table 
#             }            
#         } 
#     }
# 
# enable the pssnapin for TFS
# Add-PSSnapin Microsoft.TeamFoundation.PowerShell 

function Re-OrderImports
{
    param([xml]$myProject)

    #$xml = [xml](Get-Content $myProject)
    #$xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"
    $xml = $myProject
    $imports = $xml.Project.Import | Where-Object {($_.Project -Match "Rosen.props" -or $_.Project -Match "Microsoft.CSharp.targets")}
    $webImports = $xml.Project.Import | Where-Object{($_.Project -Match "Microsoft.WebApplication.targets" )}
    if($imports -ne $null)
    {
        $newImports = $imports | Sort-Object Project -Descending 
        $imports | foreach {$xml.Project.RemoveChild($_)} | Out-Null
        $newImports | foreach{$xml.Project.InsertAfter($_, $xml.Project.LastChild)} |Out-Null
        
        if($webImports -ne $null)
        {
            $webImports | foreach {$xml.Project.RemoveChild($_)} | Out-Null
            $webImports | foreach{$xml.Project.InsertAfter($_, $xml.Project.LastChild)} |Out-Null
        }

        return $true
    }

    return $false
}

clear
$projects =  Get-ChildItem -Include "*.csproj" -Path C:\T\aims\1Dev\services -Recurse #| Where-Object {($_.FullName -Match "Rosen.Clients.Infrastructure.Base")}


#copiar los archivos con otro nombre
foreach($project in $projects)
{
    # $tf = &"C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\tf.exe" checkout $project
    # $tf | Out-null

    # $project.Attributes = 'Normal'     
    $xml = [xml](Get-Content $project)
    $xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"
    # $xml.Data.Course.Subject

    #$references = $xml.Project.ItemGroup.Reference | where{($_.HintPath -ne $null )}
    
    #$outputpaths = $xml.Project.PropertyGroup | where {($_.OutputPath -ne $null)}
    #Write-Output $outputpaths | Format-Table -AutoSize
    
    $makeChekOut = $false
    $makeChekOut = Re-OrderImports $xml
    
    if($makeChekOut -eq $true)
    {
        Add-TfsPendingChange -Edit -item $project.FullName -lock none | Out-Null

        $project.Attributes = 'Normal' 
        $xml.Save($project.FullName)  
        Write-Output $project.FullName   
    }
}