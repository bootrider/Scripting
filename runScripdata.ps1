Function Run-Query
{
    Param ($query)
    Invoke-Sqlcmd -ServerInstance "localhost\sqldev2012" -Database "QA_ROAIMS" -ErrorAction Stop -QueryTimeout 1800 -Query "$query" 
}

$reader = [System.IO.File]::OpenText("C:\Users\CGLondono\Desktop\QATestData_ServicesDB.sql")
try {
    for(;;) {
        $line = $reader.ReadLine()
        if ($line -eq $null) { break }
        # process the line
        Run-Query $line
    }
}
finally {
    $reader.Close()
}






