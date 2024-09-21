Import-Module SharePointPnPPowerShellOnline
<#To check Office 365 groups details#>
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
        Write-Host Group checked: $group.mail
        # Run Graph API query 
        $siteDetails = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
        $site = ($siteDetails.Content | ConvertFrom-Json).value
        $group.SiteUrl = $site
        
    }
}

<#Function to check permissions#>
function CheckPermission($roles, $ctx, $spgroups, $spusers, $website, $groups, $roleCollection) {       
    # Checking for each role assignments
    # Write-Host Checking permission for $objectId

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
                        # $fileSW2.WriteLine($member.Title);
                        # $fileSW2.Flush()
                        $role = [PSCustomObject]@{               
                            LoginName = $member.LoginName
                            RoleDefinitionBinding = $binding.Name
                            SharePointGroupName = $group.Title
                            IsSharePointGroupMember = $true
                            IsO365GroupMember = $false
                            O365GroupName = $null
                            Email = $member.Email
                        }
                        $roleCollection.Add($role)|Out-Null
                    }
                }
                else{
                    Write-Host User: $oprincipal.Title
                    # $fileSW2.WriteLine($oprincipal.Title);
                    # $fileSW2.Flush()

                    $role = [PSCustomObject]@{               
                        LoginName = $oprincipal.LoginName
                        RoleDefinitionBinding = $binding.Name
                        SharePointGroupName = $null
                        IsSharePointGroupMember = $false
                        IsO365GroupMember = $false
                        O365GroupName = $null
                        Email = $member.Email
                    }
                    $roleCollection.Add($role)|Out-Null
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
                $uri = "https://graph.microsoft.com/v1.0/groups/" + $group.Id + "/owners"
                # $uri = "https://graph.microsoft.com/v1.0/groups/" + "002655e3-4299-494c-8997-430261e5f887" + "/owners"
                $method = "GET"

                # Run Graph API query 
                $groupOwner = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
                $groupOwnerJson = $groupOwner.content | ConvertFrom-Json
                $owners = $groupOwnerJson.value
                $owners | ForEach-Object{
                    Write-Host Office 365 group: $_.UserPrincipalName
                    # $fileSW2.WriteLine($_.UserPrincipalName);
                    # $fileSW2.Flush()

                    $role = [PSCustomObject]@{               
                        LoginName = $_.UserPrincipalName
                        RoleDefinitionBinding = $null
                        SharePointGroupName = $null
                        IsSharePointGroupMember = $false
                        IsO365GroupMember = $true
                        O365GroupName = $group.DisplayName
                        Email = $_.Email
                    }
                    $roleCollection.Add($role)|Out-Null
                }
                break;
            }
        }
    }   

    Get-PnPSite
    $siteAdmins = Get-PnPSiteCollectionAdmin
    $role = [PSCustomObject]@{               
        LoginName = $_.LoginName
        RoleDefinitionBinding = "Site Collection Admin"
        SharePointGroupName = $null
        IsSharePointGroupMember = $false
        IsO365GroupMember = $null
        O365GroupName = $false
        Email = $_.Email
    }
    $roleCollection.Add($role)|Out-Null
    Return $roleCollection
}

<#Modify Permissions#>
$spSiteUsageDetails = Import-Csv  -Path SpSiteUsage.csv
foreach($spSite in $spSiteUsageDetails){
    Connect-PnPOnline -Url "https://site.sharepoint.com/sites/eaopsworkshop" -UseWebLogin
    $web = Get-PnPWeb -Includes RoleAssignments, SiteGroups, SiteUsers
    $roles = $web.RoleAssignments
    $spgroups = $web.SiteGroups
    $spusers = $web.SiteUsers

    $ctx = $web.Context
    [System.Collections.ArrayList]$roleCollection = @{};
    $collection = CheckPermission $roles $ctx $spgroups $spusers $web $groups $roleCollection
}
Connect-PnPOnline -Url "https://site.sharepoint.com/sites/eaopsworkshop" -UseWebLogin
$web = Get-PnPWeb -Includes RoleAssignments, SiteGroups, SiteUsers
$roles = $web.RoleAssignments
$spgroups = $web.SiteGroups
$spusers = $web.SiteUsers

$ctx = $web.Context
[System.Collections.ArrayList]$roleCollection = @{};
$collection = CheckPermission $roles $ctx $spgroups $spusers $web $groups $roleCollection

<#//////////////////////////////////////////////#>
# foreach($ra in $web.RoleAssignments) {
#     $member = $ra.Member
#     $loginName = get-pnpproperty -ClientObject $member -Property LoginName
#     $rolebindings = get-pnpproperty -ClientObject $ra -Property RoleDefinitionBindings
#     # write-host "$($loginName) - $($rolebindings.Name)"
#     # write-host
#     $roles = $ctx.Web.RoleAssignments
#     $spgroups=$ctx.Web.SiteGroups
#     $spusers = $ctx.Web.SiteUsers
#     # $template = $ctx.Web.WebTemplate
#     # $ctx.Load($website)
#     $ctx.Load($roles)
#     $ctx.Load($spgroups)
#     $ctx.Load($spusers)
#     # $ctx.Load($template)
#     $ctx.ExecuteQuery()
    
#     # CheckPermission $roles $ctx $spgroups $spusers $website $groups $accessRequest.ObjectId $roleCollection

#     # [System.Collections.ArrayList]$roleCollection = @{};
#     if($member.TypedObject.ToString() -eq 'Microsoft.SharePoint.Client.Group'){
#         $grmembers = Get-PnPGroupMembers -Identity $member.LoginName
#         foreach($grmember in $grmembers){
#             foreach($rolebinding in $rolebindings){
#                 $role = [PSCustomObject]@{               
#                     LoginName = $grmember.LoginName
#                     RoleDefinitionBinding = $rolebinding.Name
#                     SharePointGroupName = $member.LoginName
#                     IsSharePointGroupMember = $true
#                     Email = $grmember.Email
#                 }
#                 $roleCollection.Add($role)|Out-Null
#             }
#         } 
#     }
#     else{
#         foreach($rolebinding in $rolebindings){
#             $role = [PSCustomObject]@{               
#                 LoginName = $member.LoginName
#                 RoleDefinitionBinding = $rolebinding.Name
#                 SharePointGroupName = $null
#                 IsSharePointGroupMember = $false
#                 Email = $member.Email
#             }
#             $roleCollection.Add($role)|Out-Null
#         }
#     }
# }