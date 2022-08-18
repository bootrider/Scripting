$json = Get-Content -Raw -Path C:\T\Repos\INS\Installation\DataModel\DataModel_2018.json | ConvertFrom-Json

foreach ($tb in $json.updm_extention[3].content) {
    "Table $($tb.name)" 
    # foreach ($f in $tb.fields) {
    #    $f | Export-Csv -Path "C:\temp\UPDM2019\$($tb.name).csv" -Append -Force
    # }   
    
    if($tb.name -eq "StructureLine")
    {
        foreach ($sb in $tb.subtypes) {
            $sb 
            foreach ($d in $sb.domains) {
                New-Object psobject -Property @{code = $sb.code; description = $sb.description; domain = $d.domain; field = $d.field} | Export-Csv -Path "C:\temp\UPDM2019\$($tb.name)_subtypes.csv" -Append -Force 
            }
        }
    }
}

