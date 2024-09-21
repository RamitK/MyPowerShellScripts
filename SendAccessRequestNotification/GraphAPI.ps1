$cID = "82469b79-dabd-4004-8a43-3b47f2bad303" 
$cSecret = "Nht3-wOMCz]ytb+Cabq.1qtHy43LJx4s" 
$tenantId = "d899bfc0-682c-4bb0-b4ed-dbf6b67df4fe"
# Graph API configuration
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Construct Body
$body = @{
    client_id     = $cID
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $cSecret
    grant_type    = "client_credentials"
}

# Get OAuth 2.0 Token
$tokenRequest = Invoke-WebRequest -Method Post -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $body -UseBasicParsing

# Access Token
$token = ($tokenRequest.Content | ConvertFrom-Json).access_token

# Graph API call in PowerShell using obtained OAuth token (see other gists for more details)

# Specify the URI to call and method
$uri = "https://graph.microsoft.com/v1.0/groups"
$method = "GET"
$QueryResults = @()
# Run Graph API query 
$Results = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop

$value = $Results.Content | ConvertFrom-Json | select value
$groups = $value.value

$groups | Add-Member -MemberType NoteProperty -Name Site -Value NA

foreach($group in $groups){
    if($group.groupTypes -eq "Unified"){
        $uri = "https://graph.microsoft.com/v1.0/groups/" + $group.id + "/sites/root/weburl"
        $method = "GET"
        $QueryResults = @()
        # Run Graph API query 
        $siteDetails = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
        $site = ($siteDetails.Content | ConvertFrom-Json).value
        $group.Site = $site
        
    }
}

$uri = "https://graph.microsoft.com/v1.0/groups/" + "39e303b5-ea83-48db-b9cb-1f2ae9b1732e" + "/owners"
$method = "GET"
$QueryResults = @()
# Run Graph API query 
$groupOwner = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
$groupOwnerJson = $groupOwner.content | ConvertFrom-Json
$owners = $groupOwnerJson.value