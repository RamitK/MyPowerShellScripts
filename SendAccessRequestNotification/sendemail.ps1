
# Graph API configuration #####################
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

# URI which you wish to query 
$mailuri = "https://graph.microsoft.com/v1.0/me/sendMail"

# Create Email JSON object
$body = 
@"
{
"message" : {
   "subject": "Hi",
   "body" : {
       "contentType": "Text",
       "content": "Hi How are you?"
       },
  "toRecipients": [
   {
   "emailAddress" : {
       "address" : "ramit.kishore.saha@site.com"
       }
   }
   ]
   
}
}
"@

# Invokes the request
Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -uri $mailuri -Method Post -ContentType application/json -Body $body





Foreach($site in $sites){$data.WriteLine($site.Url + "~" + $site.Title + "~" + $site.Template + "~"+ $site.WebsCount); $data.Flush();}

($sites | where{$_.template -eq "GROUP#0"}).count

$sites = get-sposite -limit all

$data2 = New-Object System.IO.StreamWriter('sitedetails.txt')

$data2.writeline('url|title|webscount')
foreach($site in $sites)
{

	$sitedetails = get-sposite -identity $site.url
	$data2.writeline($sitedetails.url + '|' + $sitedetails.title + '|' + $sitedetails.webscount)
}

$data2.flush()