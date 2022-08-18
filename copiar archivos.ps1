clear
# extraer los archivos
$filetoCopy = ".\Web.Config"
$folders =  Get-ChildItem -Include Rosen.Services.* -Path C:\BOG\Aims\Dev\Services -Recurse -Attributes D| Where-Object {($_.FullName -NotMatch ".Test") -and ($_.FullName -NotMatch "Computational") -and ($_.FullName -NotMatch "Publish") -and ($_.FullName -NotMatch "Console") -and ($_.FullName -NotMatch "Integration")}


#copiar los archivos con otro nombre
foreach($folder in $folders)
{
    echo $folder.FullName.ToString().TrimEnd()
    cd $folder.FullName
    Copy-Item '.\Web.Config' -Destination '.\Web.DevelopmentLin.config'
    Copy-Item '.\Web.Development.Config' -Destination '.\Web.DevelopmentLin.config'
    $tf = &"C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\tf.exe" add '.\Web.DevelopmentLin.config' /noprompt
    $tf | Out-null
}


