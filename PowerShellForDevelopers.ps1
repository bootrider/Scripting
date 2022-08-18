if (0)
{
    '0 is true'
}
else
{
    'it is false'
}

foreach($a in 1,2,3)
{
    $a *500
}

while($a -gt 0)
{
    --$a;
    $a + 500;
}

get-service -Include rosen*

-whatIf is my friend

Get-Member me muestra lo que el esta manejando

| Where-Object {} se usa cuando el comando no tiene un include pero arroja una lista de objetos que quiero filtrar

Out-File genera un archivo
