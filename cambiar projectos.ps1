clear
$projects =  Get-ChildItem -Include "*.csproj" -Path C:\BOG\Aims\Dev\Services -Recurse | Where-Object {($_.FullName -NotMatch "Categorization") -and ($_.FullName -NotMatch "Infrastructure") -and ($_.FullName -NotMatch "Centerline") -and ($_.FullName -NotMatch ".Test") -and ($_.FullName -NotMatch "ComputationalCore")-and ($_.FullName -NotMatch "Publish")  }


#copiar los archivos con otro nombre
foreach($project in $projects)
{
    $tf = &"C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\tf.exe" checkout $project
    $tf | Out-null

    $project.Attributes = 'Normal' 
    echo $project.FullName
    $xml = [xml](Get-Content $project)
    $xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"
    $xml.Data.Course.Subject
    $node = $xml.Project.ItemGroup.None |  Where {($_.Include -eq "Properties\PublishProfiles\Development.pubxml") }
    $parent=$node.ParentNode
    $newfile = $xml.CreateElement('None',$xmlns)
    $newfile.SetAttribute('Include',"Properties\PublishProfiles\DevelopmentLin.pubxml")
    $parent.AppendChild($newfile)

    $newnode = $xml.CreateElement('None',$xmlns)
    $newnode.SetAttribute('Include',"Web.DevelopmentLin.config")
   
    $newchildnode = $xml.CreateElement('DependentUpon',$xmlns)
    $newchildnode.InnerXML = "Web.config"
    $newnode.AppendChild($newchildnode)
    
    
    $newnode | fc
    
    $parent.AppendChild($newnode)
    $parent |fc
    $xml.Save($project)
}