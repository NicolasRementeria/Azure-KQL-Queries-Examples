#### AUTHENTICATE ####
# Import the ADAL module found in AzureRM.Profile
Import-Module AzureRM.Profile

# Set the client ID from the LA Delete App
$clientId = "XXXXXX"
# Set the key from the LA Delete App
$key = "XXXXXX"
# Select the ID of your AAD tenant
$tenantId = "XXXXXX"
# Assign the subscription ID
$subscriptionId = "XXXXXX"
# Assign the resource group where your workspace lives in
$rg = "XXXXXX"
# Assign workspace name where you want to delete the data
$ws = "XXXXXX"

$tableName = "XXXXXX"
$column = "TimeGenerated"
$operator = ">"
$value = "2020-07-27T19:18:30.000"

# We need to construct the authentication URL and get the authentication context
$authUrl = "https://login.windows.net/${tenantId}"
$AuthContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]$authUrl

# Build the credential object and get the token form AAD
$cred = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential $clientId,$key
$result = $AuthContext.AcquireTokenAsync("https://management.core.windows.net/",$cred)
# Build the authorization header JSON object
$authHeader = @{
'Content-Type'='application/json'
'Authorization'=$result.Result.CreateAuthorizationHeader()
}
#### END AUTHENTICATE ####

#### PURGE DATA ####
# Build the URI according to the documented schema
# https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.OperationalInsights/workspaces/{workspaceName}/purge?api-version=2015-03-20
$URI = "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${rg}/providers/Microsoft.OperationalInsights/workspaces/${ws}/purge?api-version=2015-03-20"

# The REST API takes a JSON Body according to this structure
# Found here https://docs.microsoft.com/en-us/rest/api/loganalytics/workspaces%202015-03-20/purge
$body = @"
{
   "table": "$tableName",
   "filters": [
     {
       "column": "$column",
       "operator": "$operator",
       "value": "$value"
     }
   ]
}
"@

# Invoke the REST API to purge the data
$purgeID=Invoke-RestMethod -Uri $URI -Method POST -Headers $authHeader -Body $body
# Write the purge ID
Write-Host $purgeID.operationId -ForegroundColor Green
#### END PURGE DATA ####