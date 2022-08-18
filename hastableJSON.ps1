$json = '{"foo":"hola","bar":"mundo", "baz":"Xtian"}'

$pairs = $json | ConvertFrom-Json

$pairs | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        write-host $key $pair."$key"
    }