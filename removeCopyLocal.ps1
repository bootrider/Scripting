clear
$projects =  Get-ChildItem -Include "*.csproj" -Path C:\BOG\aims\Dev -Recurse 


#copiar los archivos con otro nombre
foreach($project in $projects)
{
    # $tf = &"C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\tf.exe" checkout $project
    #$tf | Out-null

    $project.Attributes = 'Normal'     
    $xml = [xml](Get-Content $project)
    $xmlns = "http://schemas.microsoft.com/developer/msbuild/2003"
    # $xml.Data.Course.Subject

    $references = $xml.Project.ItemGroup.Reference | where{($_.Private -eq "True" -or ($_.HintPath -ne "" -and -not $_.Private ))}
    
    
    if ($references -ne $null)
    {
    Write-Output $project.FullName | Format-Table -AutoSize
    
        foreach($reference in $references)
        {
            Write-Output $reference | Format-Table 
            if($reference -ne $null -and -not $reference.Private)
            {
                $privateProp = $xml.CreateElement('Private',$xmlns)
                $privateProp.InnerXML = "False"
                $reference.AppendChild($privateProp)
            }
            elseif ($reference -ne $null -and $reference.Private -ne $null)
            {
                $reference.Private = "False"
            }
        }        
    }

     $projectreferences = $xml.Project.ItemGroup.ProjectReference | where{($_.Private -eq "True" -or ( -not $_.Private ))}
    
    
    if ($projectreferences -ne $null)
    {
    Write-Output $project.FullName | Format-Table -AutoSize
    
        foreach($reference in $projectreferences)
        {
            Write-Output $reference | Format-Table 
            if($reference -ne $null -and -not $reference.Private)
            {
                $privateProp = $xml.CreateElement('Private',$xmlns)
                $privateProp.InnerXML = "False"
                $reference.AppendChild($privateProp)
            }
            elseif ($reference -ne $null -and $reference.Private -ne $null)
            {
                $reference.Private = "False"
            }
        }        
    }

    $xml.Save($project)

    #$node = $xml.Project.ItemGroup.None |  Where {($_.Include -eq "Properties\PublishProfiles\Development.pubxml") }
    # $parent=$node.ParentNode
    # $newfile = $xml.CreateElement('None',$xmlns)
    # $newfile.SetAttribute('Include',"Properties\PublishProfiles\DevelopmentLin.pubxml")
    # $parent.AppendChild($newfile)
    # 
    # $newnode = $xml.CreateElement('None',$xmlns)
    # $newnode.SetAttribute('Include',"Web.DevelopmentLin.config")
    # 
    # $newchildnode = $xml.CreateElement('DependentUpon',$xmlns)
    # $newchildnode.InnerXML = "Web.config"
    # $newnode.AppendChild($newchildnode)
    # 
    # $newnode | fc
    # 
    # $parent.AppendChild($newnode)
    # $parent |fc    
}