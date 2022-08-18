[System.Diagnostics.Process]::Start("C:\Temp\CodedUIProject\CodedUIProject.aprx")

$env:USERNAME
$env:USERDOMAIN

$searcher = [adsisearcher]"(samaccountname=$env:USERNAME)"
$searcher.FindOne().Properties.mail
