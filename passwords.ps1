function my-function{

Param (  
    
    
    [Parameter(ParameterSetName = 'Plain')]
    [string]$Password
)

if ($Password) {
echo "foo"
    
} else {
    $PasswordAsked = AskSecureQ "Type the password you would like to set all the users to"
}

$real = ConvertTo-PlainText -secure $PasswordAsked


echo $real

}


function AskSecureQ ([String]$Question, [String]$Foreground="Yellow", [String]$Background="Blue") {
    Write-Host $Question -ForegroundColor $Foreground -BackgroundColor $Background -NoNewLine
    Return (Read-Host -AsSecureString)
}

function ConvertTo-PlainText( [security.securestring]$secure ) {
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    return $UnsecurePassword
}

