$script ="PromoteItems.py"
$python = "c:\anaconda3\python.exe"
$client = "Sales-CA"

$env:DEVPORTAL = "https://bogarcgisportal.roseninspection.net/portal"
$env:DEVPORTALADMIN = "admin"
$env:DEVPORTALADMINPWD = "79axFtmsOSo3pIijAPjz"

$env:QAPORTAL = "https://bogarcgisportqa.roseninspection.net/portal"
$env:QAPORTALADMIN = "admin"
$env:QAPORTALADMINPWD = "79axFtmsOSo3pIijAPjz"

$env:STAGINGAGOL="https://rtrcbogqa.maps.arcgis.com"
$env:STAGINGAGOLADMIN="developer_RTRCBogQA"
$env:STAGINGAGOLADMINPWD="BsXacKc8MAQAS9vWdbTV"

$env:PRODUCTIONAGOL="https://rosen-cas.maps.arcgis.com"
$env:PRODUCTIONAGOLADMIN="CASAdminBOG"
$env:PRODUCTIONAGOLADMINPWD="7gvyZn4fulTAzC2PxQr9"


#& $python $script "QA" $client false
#& $python $script "Staging" $client true
& $python $script "Production" $client true