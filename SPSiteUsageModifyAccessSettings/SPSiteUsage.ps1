
# Graph API configuration #####################
$cID = "9f5e21c5-f654-456d-b483-1c0a2bcc3523" 
$cSecret = "yF-HLo/E31b=MOlU38V:zU0-2.Bwgxe4" 
$tenantId = "cf36141c-ddd7-45a7-b073-111f66d0b30c"
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
$uri = "https://graph.microsoft.com/v1.0/reports/getSharePointSiteUsageDetail(period='D30')"
$method = "GET"
# Run Graph API query 
$Results = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop -UseBasicParsing
# Storing site usage details
$sitesUsageDetails = ($Results.RawContent -split "\?\?\?", 2)[1] | ConvertFrom-Csv

($Results.RawContent -split "\?\?\?", 2)[1]

# $write = "Looping through sites with at least one visited page in last 30 days...."
[System.Collections.ArrayList]$logCollection = @{};
# Write-OutPut $write
foreach($site in $sitesUsageDetails)
{
    if($site."Visited Page Count" -gt 9){
		try{
			Connect-PnPOnline -Url $site."Site URL" -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370=
			$web = Get-PnPWeb -Includes "Url", "WebTemplate", "RequestAccessEmail", "AccessRequestSiteDescription", "UseAccessRequestDefault", "HasUniqueRoleAssignments"
			$log = [PSCustomObject]@{ 
                WebsiteUrl = $web.Url;            
                WebTemplate = $web.WebTemplate;
                RequestAccessEmail = $web.RequestAccessEmail;
                AccessRequestSiteDescription = $web.AccessRequestSiteDescription;
                UseAccessRequestDefault = $web.UseAccessRequestDefault;
                HasUniqueRoleAssignments = $web.HasUniqueRoleAssignments
            }
            $logCollection.Add($log)|Out-Null
            $subwebs = Get-PnPSubWebs -Includes "Url", "WebTemplate", "RequestAccessEmail", "AccessRequestSiteDescription", "UseAccessRequestDefault", "HasUniqueRoleAssignments" -Recurse
			foreach($sweb in $subwebs){
                if($sweb.HasUniqueRoleAssignments -eq $true){
                    try{
                        # Connect-PnPOnline -Url $site."Site URL" -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370=
                        # $web = Get-PnPWeb -Includes "Url", "WebTemplate", "RequestAccessEmail", "AccessRequestSiteDescription", "UseAccessRequestDefault", "HasUniqueRoleAssignments"
                        $log = [PSCustomObject]@{    
                            # SiteCollectionUrl  = $site."Site URL";    
                            # WebsiteUrl = $sweb.Url;  
                            WebsiteUrl = $sweb.Url;       
                            WebTemplate = $sweb.WebTemplate;
                            RequestAccessEmail = $sweb.RequestAccessEmail;
                            AccessRequestSiteDescription = $sweb.AccessRequestSiteDescription;
                            UseAccessRequestDefault = $sweb.UseAccessRequestDefault;
                            HasUniqueRoleAssignments = $sweb.HasUniqueRoleAssignments
                        }
                        $logCollection.Add($log)|Out-Null
                    }      
                    Catch{
                        # $fileSW3.WriteLine("Error fetching web " + $_.Url + " details: " + $_.Exception.Message);
                        # $fileSW3.Flush();
                        $write = "Error fetching web " + $_.Url + " details: " + $_.Exception.Message
                        Write-Host $write
                    }
               }
			}
		}
		Catch{
			# $fileSW3.WriteLine("Error fetching web " + $site."Site URL" + " details: " + $_.Exception.Message);
			# $fileSW3.Flush();
			$write = "Error fetching web " + $site."Site URL" + " details: " + $_.Exception.Message
			Write-Host $write			
		}
    }
}

$logCollection | Export-Csv SpSiteUsage.csv

# $logJson = $logCollection | ConvertTo-Json

# Write-OutPut $logJson

<#Set-PnPRequestAccessEmails -Emails ramit.kishore.saha@site.com

$web.SetAccessRequestSiteDescriptionAndUpdate("Ramit is the owners of the site")
$web.Update()
$web.Context.ExecuteQuery()#>


# Connect-PnPOnline -Url "https://site.sharepoint.com/sites/eaopsworkshop" -UseWebLogin
# $web = Get-PnPWeb -Includes RoleAssignments, SiteGroups, SiteUsers
# $roles = $web.RoleAssignments
# $spgroups = $web.SiteGroups
# $spusers = $web.SiteUsers



# foreach($ra in $web.RoleAssignments) {
#     $member = $ra.Member
#     $loginName = get-pnpproperty -ClientObject $member -Property LoginName
#     $rolebindings = get-pnpproperty -ClientObject $ra -Property RoleDefinitionBindings


#     write-host "$($loginName) - $($rolebindings.Name)"
#     write-host
#     }