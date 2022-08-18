clear
$projects = Get-ChildItem -Include "*.csproj" -Path C:\T\AIMS2\Dev\FT2\Rosen -Recurse # | Where-Object {($_.FullName -NotMatch "Categorization") -and ($_.FullName -NotMatch "Infrastructure") -and ($_.FullName -NotMatch "Centerline") -and ($_.FullName -NotMatch ".Test") -and ($_.FullName -NotMatch "ComputationalCore")-and ($_.FullName -NotMatch "Publish")  }


    #copiar los archivos con otro nombre
    foreach ($project in $projects) {
        $tf = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe" 
        # $tf | Out-null

        $project.Attributes = 'Normal' 

    
    
        $file = New-Object System.IO.StreamReader -ArgumentList $project    
        $xml = [xml]($file.ReadToEnd())
        $file.Close()
                
        $xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"    
                
        $node = $xml.Project.PropertyGroup |Where-Object {$_.TargetFrameworkVersion} 
        $child = $node.GetElementsByTagName("TargetFrameworkVersion")[0]
        $child.InnerText = "v4.7.2"
     
        #$node | fc
    

    
        # if ($node2) {
        #     if (-not $node2.SpecificVersion ) {
        #         $newchildnode = $xml.CreateElement('SpecificVersion', $xmlns)
        #         $newchildnode.InnerXML = "False"
        #         $node.AppendChild($newchildnode) 
        
        #     }

        #     if (-not $node2.Private) {
        #         $newchildnode = $xml.CreateElement('Private', $xmlns)
        #         $newchildnode.InnerXML = "False"
        #         $node.AppendChild($newchildnode)        
        #     }

        #     $node2.SetAttribute('Include', "$parentProject")
        #     if ($node2.HintPath) {
        #         $child2 = $node2.GetElementsByTagName("HintPath")[0]
        #         $node2.RemoveChild($child2)
        #     }

        #     $node2 | fc
        # }
        if ($node ) {            
            & $tf vc checkout $project    
            $xml.Save($project)
            Write-Host $project.FullName -ForegroundColor Green
        }
        # 
    }
