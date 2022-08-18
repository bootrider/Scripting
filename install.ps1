$TransliterationMap =  @(
                           [Tuple]::Create('a', 'ă'), [Tuple]::Create('b', 'ƀ'), [Tuple]::Create('c', 'ͼ'),
                           [Tuple]::Create('d', 'ď'), [Tuple]::Create('e', 'Ə'), [Tuple]::Create('f', 'ƒ'),
                           [Tuple]::Create('g', 'ĝ'), [Tuple]::Create('h', 'ĥ'), [Tuple]::Create('i', 'ȋ'),
                           [Tuple]::Create('j', 'ĵ'), [Tuple]::Create('k', 'к'), [Tuple]::Create('l', 'ɭ'),
                           [Tuple]::Create('m', 'м'), [Tuple]::Create('n', 'ŋ'), [Tuple]::Create('o', 'ŏ'),
                           [Tuple]::Create('p', 'ϼ'), [Tuple]::Create('q', 'ɋ'), [Tuple]::Create('r', 'ɾ'),
                           [Tuple]::Create('s', 'ѕ'), [Tuple]::Create('t', 'ŧ'), [Tuple]::Create('u', 'ʊ'),
                           [Tuple]::Create('v', 'ѵ'), [Tuple]::Create('w', 'ш'), [Tuple]::Create('x', 'ж'),
                           [Tuple]::Create('y', 'ў'), [Tuple]::Create('z', 'ż'), [Tuple]::Create('A', 'д'),
                           [Tuple]::Create('B', 'Ɓ'), [Tuple]::Create('C', 'Ͼ'), [Tuple]::Create('D', 'Ɖ'),
                           [Tuple]::Create('E', 'Ξ'), [Tuple]::Create('F', 'Ƒ'), [Tuple]::Create('G', 'б'),
                           [Tuple]::Create('H', 'Ԋ'), [Tuple]::Create('I', 'ᶅ'), [Tuple]::Create('J', 'ζ'),
                           [Tuple]::Create('K', 'к'), [Tuple]::Create('L', 'Г'), [Tuple]::Create('M', 'м'),
                           [Tuple]::Create('N', 'Ɲ'), [Tuple]::Create('O', 'о'), [Tuple]::Create('P', 'Ƿ'),
                           [Tuple]::Create('Q', 'Ǿ'), [Tuple]::Create('R', 'Я'), [Tuple]::Create('S', 'Ϩ'),
                           [Tuple]::Create('T', 'т'), [Tuple]::Create('U', 'ʊ'), [Tuple]::Create('V', 'Ѷ'),
                           [Tuple]::Create('W', 'щ'), [Tuple]::Create('X', 'ж'), [Tuple]::Create('Y', 'У'),
                           [Tuple]::Create('Z', 'Ԅ')
                       )

$file = Get-Content -Path "C:\T\Repos\INS\Installation\DataModel\en-US\CodedValueDomains.json"

$newFile = @()

foreach($line in $file)
{
    foreach($tuple in $TransliterationMap)
    {
        $line = $line.Replace($tuple.Item1, $tuple.Item2) 
        
    }
    $newFile+=$line
}

$newFile | Set-Content -Path "C:\T\Repos\INS\ScriptTests\Installation\DataModel\de\CodedValueDomains.json" -