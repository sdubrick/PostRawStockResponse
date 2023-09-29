#Description: This script will create a new stock response in iService by posting the raw html to the api, rather than using the iService editor. This is useful if you want to create a stock response that contains html that is not supported by the editor.
#Editable parameters
$tenant = "https://mytenant.iservicecrm.com"
$login = "user@example.com"
$segmentid = 2
$name = "Stock Response Name"
$description = "Stock Response Description"
$stockResponseBodyFilename = "stockresponse.html"
#Do not edit below this line

try {
    # Attempt to read the stock response content
    $stockresponse = Get-Content $stockResponseBodyFilename -Raw -ErrorAction Stop
}
catch {
    # Handle errors and bail out gracefully without closing the console window
    Write-Host "An error occurred while reading the file: $_"   
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

#replace the stock responses double quotes with escaped double quotes
$stockresponse = $stockresponse.Replace('"', '\"')

#securely read the password from the console
$passwordsecure = Read-Host "Enter password for $login at $tenant" -AsSecureString

#set up the parameters for the login
$LoginParameters = @{
    Uri             = "$tenant/f/webapp-api-login?api=login"
    SessionVariable = "Session"
    Method          = "POST"
    Body            = @{
        emailAddress = "$login"
        Password     = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordsecure))
    }
}

try {
    # Attempt to log in to the api and store the session
    $LoginResponse = Invoke-WebRequest @LoginParameters -ErrorAction Stop
    $parsedResponse = $LoginResponse.Content | ConvertFrom-Json
    if (!$parsedResponse.loggedIn.isLoggedIn) {
        throw "Login failed: $($parsedResponse.errors[0])"
    }
    Write-Host "Logged in to $tenant as $login"
}
catch {
    # Handle errors and bail out gracefully without closing the console window
    Write-Host "An error occurred while logging in: $_"   
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

#build the request to be posted
$data = @{
    "details" = @{
        "effects"     = @{}
        "name"        = "$name"
        "description" = "$description"
        "bodyHtml"    = "$stockresponse"
        "segmentID"   = $segmentid
    }
}

#serialize the data to json
$jsonData = $data | ConvertTo-Json

try {
    #post the data to the api to create the stock response. 
    $response = Invoke-RestMethod -Uri "$tenant/f/webapp-api-admin?api=stockresponses&mode=new" -Method Post -Body $jsonData -WebSession $Session -ContentType "application/json"
    if ($null -eq $response.stockid) {
        throw "$($response.errors[0])"
    }
    else {
        Write-Host "Generated new stock response with id: " $response.stockid
    }
}
catch {
    Write-Host "Unable to generate stock response: $_"   
}

#log out of the api. The out-null is to suppress the raw output to the console
Invoke-WebRequest -Uri "$tenant/f/webapp-api-login?api=logout" -WebSession $Session -Method Post | Out-Null
Write-Host "Logged out of $tenant"

#pause to allow the user to read the results without closing the console window
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")