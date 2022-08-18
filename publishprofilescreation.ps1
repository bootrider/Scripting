
clear
# extraer los archivos
$folders =  Get-ChildItem -Include PublishProfiles -Path C:\BOG\Aims\Dev\Services -Recurse -Attributes D| Where-Object {($_.FullName -NotMatch ".Test") -and ($_.FullName -NotMatch "Computational") -and ($_.FullName -NotMatch "Services.Publish") -and ($_.FullName -NotMatch "Console") -and ($_.FullName -NotMatch "Integration")}
$filetoCopy = ".\Development.pubxml"

#copiar los archivos con otro nombre
foreach($folder in $folders)
{
    echo $folder.FullName.ToString().TrimEnd()
    cd $folder
    Copy-Item $filetoCopy -Destination '.\DevelopmentLin.pubxml'
    $tf = &"C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\tf.exe" add '.\DevelopmentLin.pubxml' /noprompt
    $tf | Out-null
}