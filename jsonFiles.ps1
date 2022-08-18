import-module importexcel

$Sheets = Get-ExcelSheetInfo -Path C:\T\INS_2019\Installation\Data\AddInConfiguration.xlsx 

foreach($sheet in $Sheets)
{
    $res = import-excel -Path C:\T\INS_2019\Installation\Data\AddInConfiguration.xlsx -WorksheetName $sheet.Name
    $res | ConvertTo-Json | Tee-Object -FilePath "C:\T\INS_2019\Installation\Data\$($sheet.Name).json"
    ConvertFrom-ExcelToSQLInsert -Path C:\T\INS_2019\Installation\Data\AddInConfiguration.xlsx -WorksheetName $sheet.Name -TableName hello -StartRow 2  
}



$foo = Get-Content -Raw -Path "C:\T\INS_2019\Installation\Data\RAC_ADD_IN.json" | ConvertFrom-Json

$foo = Get-Content -Raw -Path "C:\T\INS_2019\Installation\Data\RAC_CONNECTIONS.json" | ConvertFrom-Json 

$foo | get-member -MemberType NoteProperty 
$foo.GetType() -eq [Object[]]
$foo -is [object[]]
