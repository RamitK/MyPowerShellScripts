#loading SharePoint assemblies
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\OfficeDevPnP.Core.dll"

<#Collecting logs#>

# Office 365 Management Activity API configuration #####################
$cID = "9f5e21c5-f654-456d-b483-1c0a2bcc3523" 
$cSecret = "yF-HLo/E31b=MOlU38V:zU0-2.Bwgxe4"
$tenant = "site" 
$tenantdomain = "site.onmicrosoft.com"
$loginURL = "https://login.microsoftonline.com/" 
$resource = "https://manage.office.com" 
$body = @{
    grant_type="client_credentials";
    resource=$resource;
    client_id=$cID;
    client_secret=$cSecret
} 
$oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body 
$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}


<#Command to check if the subscription is created#>
$tenantGUID = "cf36141c-ddd7-45a7-b073-111f66d0b30c"
Invoke-WebRequest -Headers $headerParams -Uri "https://manage.office.com/api/v1.0/$tenantGUID/activity/feed/subscriptions/list"
<#Creating the subscription is not created#>
Invoke-WebRequest -Method Post -Headers $headerParams -Uri "https://manage.office.com/api/v1.0/$tenantGUID/activity/feed/subscriptions/start?contentType=Audit.SharePoint"
# $date = Get-Date
# $startDate = (Get-Date).AddHours(-6)
# $startTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($startDate, [System.TimeZoneInfo]::Local.Id, 'GMT Standard Time')
# $startTime = $startTime.tostring('yyyy-MM-ddTHH:mm:ss')
# $endDate = (Get-Date).AddHours(-3)
# $endTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($endDate, [System.TimeZoneInfo]::Local.Id, 'GMT Standard Time')
# $endTime = $endTime.tostring('yyyy-MM-ddTHH:mm:ss')

# $Uri = "https://manage.office.com/api/v1.0/$tenant/activity/feed/subscriptions/content?contentType=Audit.SharePoint&amp;startTime=" + $startTime + "&amp;endTime=" + $endTime;

# $logs = Invoke-WebRequest -Method GET -Headers $headerParams -Uri $Uri #"https://manage.office.com/api/v1.0/$tenant/activity/feed/subscriptions/content?contentType=Audit.SharePoint"
$logs = Invoke-WebRequest -Method GET -Headers $headerParams -Uri "https://manage.office.com/api/v1.0/$tenant/activity/feed/subscriptions/content?contentType=Audit.SharePoint"

# &amp;startTime={0}&amp;endTime={1}

# Office 365 Management Activity API configuration ends #####################

<#Collecting logs completed#>


<#Collecting group names#>

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
$uri = "https://graph.microsoft.com/v1.0/groups"
$method = "GET"
# Run Graph API query 
$Results = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop

$value = $Results.Content | ConvertFrom-Json | Select-Object value
$groups = $value.value

# Adding site URL property to object
$groups | Add-Member -MemberType NoteProperty -Name SiteUrl -Value NA

# Fetching the value individually and adding
foreach($group in $groups){
    if($group.groupTypes -eq "Unified"){
        $uri = "https://graph.microsoft.com/v1.0/groups/" + $group.id + "/sites/root/weburl"
        $method = "GET"
        # Run Graph API query 
        $siteDetails = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
        $site = ($siteDetails.Content | ConvertFrom-Json).value
        $group.SiteUrl = $site
        
    }
}

# Graph API configuration ends #####################
<#Collecting group names ends#>

<#Function to check owner in SharePoint site#>

function CheckPermission($roles, $ctx, $spgroups, $spusers, $website, $groups, $objectid) {       
    # Checking for each role assignments
    Write-Host Checking permission for $objectId

    foreach($role in $roles){
    $oprincipal = $role.Member
    $bindings = $role.RoleDefinitionBindings
    $ctx.Load($oprincipal)
    $ctx.Load($bindings)
    $ctx.Executequery()

        foreach($binding in $bindings){
            if($binding.Name -eq "Full Control"){
                if($oprincipal.TypedObject.ToString() -eq "Microsoft.SharePoint.Client.Group"){
                    $group = $spgroups.GetByName($oprincipal.Title)
                    $members = $group.Users
                    $ctx.Load($group)
                    $ctx.Load($members)
                    $ctx.ExecuteQuery()
                    foreach($member in $members){
                        Write-Host Group member: $member.Title
                        $fileSW2.WriteLine($member.Title);
                        $fileSW2.Flush()
                    }
                }
                else{
                    Write-Host User: $oprincipal.Title
                    $fileSW2.WriteLine($oprincipal.Title);
                    $fileSW2.Flush()
                }
            }
        }
    }
    # If group site, check the group owners
    if($website.WebTemplate -eq "GROUP"){
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
        foreach($group in $groups){
            if($website.Url -eq $group.SiteUrl){
                $uri = "https://graph.microsoft.com/v1.0/groups/" + "39e303b5-ea83-48db-b9cb-1f2ae9b1732e" + "/owners"
                $method = "GET"

                # Run Graph API query 
                $groupOwner = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
                $groupOwnerJson = $groupOwner.content | ConvertFrom-Json
                $owners = $groupOwnerJson.value
                $owners | ForEach-Object{
                    Write-Host Office 365 group: $_.UserPrincipalName
                    $fileSW2.WriteLine($_.UserPrincipalName);
                    $fileSW2.Flush()
                }
            }
        }
    }   
    # Checking site collection admin
    foreach($spuser in $spusers){
        if($spuser.IsSiteAdmin){
            Write-Host Site Admin: $spuser.Title
            $fileSW2.WriteLine($spuser.Title);
            $fileSW2.Flush()
        }
    }
}
<#Function to check owner in SharePoint site ends#>

# Invoke-WebRequest -Method GET -Headers $headerParams -Uri "https://manage.office.com/api/v1.0/$tenant/activity/feed/subscriptions/content?contentType=Audit.SharePoint"  
# Invoke-WebRequest -Method Post -Headers $headerParams -Uri "https://manage.office.com/api/v1.0/$tenant/activity/feed/subscriptions/start?contentType=Audit.SharePoint"  

$fileSW = New-Object System.IO.StreamWriter("AccessRequestLogs.txt")
$fileW = New-Object System.IO.StreamWriter("SharePointLogs.txt")
$fileW.WriteLine("Creation Time, Operation, ObjectId, User Id, Item Type")
$fileW.Flush()
$content = $logs.Content
$ccontent = $content | ConvertFrom-Json
$blobContentAR = @()
$cID = "9f5e21c5-f654-456d-b483-1c0a2bcc3523" 
$cSecret = "yF-HLo/E31b=MOlU38V:zU0-2.Bwgxe4"
$tenant = "site" 
$tenantdomain = "site.onmicrosoft.com"
$loginURL = "https://login.microsoftonline.com/" 
$resource = "https://manage.office.com" 
$body = @{
    grant_type="client_credentials";
    resource=$resource;
    client_id=$cID;
    client_secret=$cSecret
} 
$oauth = Invoke-RestMethod -Method Post -Uri $loginURL/$tenantdomain/oauth2/token?api-version=1.0 -Body $body 
$headerParams = @{'Authorization'="$($oauth.token_type) $($oauth.access_token)"}
foreach($contentUri in $ccontent.contenturi){
    $data = Invoke-WebRequest -Method GET -Headers $headerParams -uri $contentUri
    $blobContent = $data.content | ConvertFrom-Json
    
    foreach($bContent in $blobContent){
        $fileW.WriteLine($bContent.CreationTime + "," + $bContent.Operation + "," + $bContent.ObjectId + "," + $bContent.UserId + "," + $bContent.ItemType)
        $fileW.Flush()
        if($bContent.Operation -eq "AccessrequestCreated"){
            $bContent
            $fileSW.WriteLine("Creation Time: " + $bContent.CreationTime + ", Operation: " + $bContent.Operation + ", ObjectId: " + $bContent.ObjectId + ", User Id: " + $bContent.UserId + ", Item Type: " + $bContent.ItemType)
            $fileSW.Flush()
            Write-Host Creation Time:   $bContent.CreationTime   Operation:   $bContent.Operation   ObjectId:   $bContent.ObjectId  User Id:  $bContent.UserId  Item Type: $bContent.ItemType
            $blobContentAR = $blobContentAR + $bContent

        }
    }

    # for($i=0; $i -lt $blobContent.count; $i++){
    #     # $fileSW.WriteLine($bContent);
    #     # $aLog = $bContent | ConvertFrom-Json
    #     if($blobContent[$i].Operation -eq "AccessrequestCreated"){
    #     $fileSW.WriteLine("Creation Time: " + $blobContent[$i].CreationTime + ", Operation: " + $blobContent[$i].Operation + ", ObjectId: " + $blobContent[$i].ObjectId + ", User Id: " + $blobContent[$i].UserId + ", Item Type: " + $blobContent[$i].ItemType)
    #     $fileSW.Flush()
    #     }
    # }
}
$fileSW2 = New-Object System.IO.StreamWriter("AccessDetails.txt")

$clientId = "20fa80b9-9742-40b8-be8b-6bc7b10a3fe6"
$clientSecret = "XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370="

foreach($accessRequest in $blobContentAR){
    $fileSW2.WriteLine("Access request from " + $accessRequest.UserId + "for " + $accessRequest.ObjectId)
    $fileSW2.Flush()
    switch ($accessRequest.ItemType){
        "Web"{
            Write-Host Web request: $accessRequest.ObjectId
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $site = $accessRequest.ObjectId
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($site, $clientId, $clientSecret)
            $website = $ctx.Web
            $roles = $ctx.Web.RoleAssignments
            $spgroups=$ctx.Web.SiteGroups
            $spusers = $ctx.Web.SiteUsers
            # $template = $ctx.Web.WebTemplate
            $ctx.Load($website)
            $ctx.Load($roles)
            $ctx.Load($spgroups)
            $ctx.Load($spusers)
            # $ctx.Load($template)
            $ctx.ExecuteQuery()
            CheckPermission $roles $ctx $spgroups $spusers $website $groups $accessRequest.ObjectId
            # Checking for each role assignments
            break;
        }
        "File"{
            Write-Host File request: $accessRequest.ObjectId
            $siteUrl = $accessRequest.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $file = $ctx.Web.GetFileByUrl($accessRequest.ObjectId)
            $ctx.Load($file)
            $spgroups=$ctx.Web.SiteGroups
            $spusers = $ctx.Web.SiteUsers
            $ctx.Load($spgroups)
            $ctx.Load($spusers)
            Load-CSOMProperties -object $file -propertyNames "Title"
            Load-CSOMProperties -object $file.ListItemAllFields -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $file.ListItemAllFields.RoleAssignments
            CheckPermission $roles $ctx $spgroups $spusers $website $groups $accessRequest.ObjectId
            # Checking for each role assignments
            break;
        }
        "Folder"{
            Write-Host Folder request: $accessRequest.ObjectId
            $siteUrl = $accessRequest.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $serverRelativeUrl = $accessRequest.ObjectId.Substring(30)
            $folder = $ctx.Web.GetFolderByServerRelativeUrl($serverRelativeUrl)
            $ctx.Load($folder)
            $spgroups=$ctx.Web.SiteGroups
            $spusers = $ctx.Web.SiteUsers
            $ctx.Load($spgroups)
            $ctx.Load($spusers)
            Load-CSOMProperties -object $folder -propertyNames "Name"
            Load-CSOMProperties -object $folder.ListItemAllFields -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $folder.ListItemAllFields.RoleAssignments
            CheckPermission $roles $ctx $spgroups $spusers $website $groups $accessRequest.ObjectId
            # Checking for each role assignments
            break;
        }
        "List"{
            Write-Host List request: $accessRequest.ObjectId
            $siteUrl = $accessRequest.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $serverRelativeUrl = $objectId.Substring(30)
            $list = $ctx.Web.GetList($serverRelativeUrl)
            $ctx.Load($list)
            $spgroups=$ctx.Web.SiteGroups
            $spusers = $ctx.Web.SiteUsers
            $ctx.Load($spgroups)
            $ctx.Load($spusers)
            Load-CSOMProperties -object $list -propertyNames "Title"
            Load-CSOMProperties -object $list -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $list.RoleAssignments
            CheckPermission $roles $ctx $spgroups $spusers $website $groups $accessRequest.ObjectId
            # Checking for each role assignments
            break;
        }
        "DocumentLibrary"{
            Write-Host Document Library request: $accessRequest.ObjectId
            $siteUrl = $accessRequest.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $serverRelativeUrl = $objectId.Substring(30)
            $list = $ctx.web.GetList($serverRelativeUrl)
            $ctx.Load($list)
            $spgroups=$ctx.Web.SiteGroups
            $spusers = $ctx.Web.SiteUsers
            $ctx.Load($spgroups)
            $ctx.Load($spusers)
            Load-CSOMProperties -object $list -propertyNames "Title"
            Load-CSOMProperties -object $list -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $list.RoleAssignments
            CheckPermission $roles $ctx $spgroups $spusers $website $groups $accessRequest.ObjectId
            # Checking for each role assignments
            break;
        }
        Default {
            Write-Host Item type is new and does not match with any of the item types defined.
        }
    }
}