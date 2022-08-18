$ordinalsCount = @(0,3,3,5,4,4,3,5,5,4)
$tenFamily = @(3,6,5,8,8,7,7,9 ,8,8)
$decenasCount = @(0,0,6,6,5,5,5,7,6,6)
$hundredsCount=7
$thousandCount=8

$limit=1000

$numberLengh=0

foreach($n in 1..$limit)
{
    $rem = 0
    $centenas = 0
    $decenas = 0
    $units = 0
    $unitTh = [Math]::DivRem($n, 1000, [ref]$rem)
    $centenas =  [Math]::DivRem($rem, 100, [ref]$rem)
    $decenas = [Math]::DivRem($rem, 10, [ref]$rem)
    $units = $rem

    #thousands
    $numberLengh += if ($unitTh -gt 0 ) {$ordinalsCount[$unitTh] + $thousandCount} else {0}
    #hundreds
    $numberLengh += if ($centenas -gt 0) {$ordinalsCount[$centenas] + $hundredsCount + 3} else {0}
    #decenas
    if($decenas -eq 1)
        {
            $numberLengh += $tenFamily[$units]
        }
    else
        {
            $numberLengh += $decenasCount[$decenas]
            $numberLengh += $ordinalsCount[$units]
        }
    
    Write-Output "Salida : $n $unitTh $centenas $decenas $units"
}
Write-Output $numberLengh