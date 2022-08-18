clear
$projects = Get-ChildItem -Include "*.test.csproj" -Path C:\T\AIMS2\Dev\FT2\Rosen -Recurse # | Where-Object {($_.FullName -NotMatch "Categorization") -and ($_.FullName -NotMatch "Infrastructure") -and ($_.FullName -NotMatch "Centerline") -and ($_.FullName -NotMatch ".Test") -and ($_.FullName -NotMatch "ComputationalCore")-and ($_.FullName -NotMatch "Publish")  }


#copiar los archivos con otro nombre
foreach ($project in $projects) {
    $tf = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\TF.exe" 
    # $tf | Out-null

    $project.Attributes = 'Normal' 
    
    $xml = [xml](Get-Content $project)
    $xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"
    
    $node = $xml.Project.ItemGroup.Reference |  Where {($_.Include -like "Rhino.Mocks, Version=*") }
    $parentProject = $($project.BaseName).Replace(".Test", [string]::Empty) 
    $node2 = $xml.Project.ItemGroup.Reference |  Where {($_.Include -like "$parentProject, Version*") }

    if ($node) {
        $node.SetAttribute('Include', "Rhino.Mocks")

        if (-not $node.SpecificVersion ) {
            $newchildnode = $xml.CreateElement('SpecificVersion', $xmlns)
            $newchildnode.InnerXML = "False"
            $node.AppendChild($newchildnode) 
        
        }

        if (-not $node.Private) {
            $newchildnode = $xml.CreateElement('Private', $xmlns)
            $newchildnode.InnerXML = "False"
            $node.AppendChild($newchildnode)        
        }
    
        if ($node.HintPath) {
            $child = $node.GetElementsByTagName("HintPath")[0]
            $node.RemoveChild($child)
        }
     
        #$node | fc
    }

    
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
    if($node ) {
        Write-Host $project.FullName -ForegroundColor Green
        & $tf vc checkout $project    
        $xml.Save($project)
    }
    # 
}