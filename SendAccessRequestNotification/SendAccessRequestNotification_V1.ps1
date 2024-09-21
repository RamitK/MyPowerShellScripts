Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\OfficeDevPnP.Core.dll"

# Get the access request log from yesterday
$logs = Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-8).tostring('MM/dd/yyyy') -EndDate (Get-Date).tostring('MM/dd/yyyy') -RecordType 14 -Operations AccessRequestCreated -ResultSize 5000 | Sort-Object -Property CreationDate
$clientID = "20fa80b9-9742-40b8-be8b-6bc7b10a3fe6";
$clientSecret = "XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370=";
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
                    }
                }
                else{
                    Write-Host User: $oprincipal.Title
                }
            }
        }
    }
    # If group site, check the group owners
    if($website.WebTemplate -eq "GROUP"){
        foreach($group in $groups){
            if($website.Url -eq $group.SharePointSiteUrl){
                $owners = Get-UnifiedGroupLinks -Identity $group.DisplayName -LinkType "Owners"
                $owners | ForEach-Object{
                    Write-Host Office 365 group: $_.Name
                }
            }
        }
    }   
    # Checking site collection admin
    foreach($spuser in $spusers){
        if($spuser.IsSiteAdmin){
            Write-Host Site Admin: $spuser.Title
        }
    }
}
# Get all Office 365 groups
Get-UnifiedGroup -ResultSize Unlimited | select name, sharepointsiteurl, classification, identity | Export-Csv -Path 'C:\Ramit\ExchangeOnline\Groups.csv'
$groups = Import-Csv -Path 'C:\Ramit\ExchangeOnline\Groups.csv'

# For each access request, check the site/library/list and check it's owner
foreach($log in $logs){
    $auditData = $log.AuditData | ConvertFrom-Json
    # Condition to check what type of context and select owner accordingly
    switch ($auditData.ItemType){
        "Web"{
            Write-Host Web request: $auditData.ObjectId
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $site = $auditData.ObjectId
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
            CheckPermission $roles $ctx $spgroups $website $groups $auditData.ObjectId
            # Checking for each role assignments
            break;
        }
        "File"{
            Write-Host File request: $auditData.ObjectId
            $siteUrl = $auditData.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $file = $ctx.Web.GetFileByUrl($auditData.ObjectId)
            $ctx.Load($file)
            Load-CSOMProperties -object $file -propertyNames "Title"
            Load-CSOMProperties -object $file.ListItemAllFields -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $file.ListItemAllFields.RoleAssignments
            CheckPermission $roles $ctx $spgroups $website $groups $auditData.ObjectId
            # Checking for each role assignments
            break;
        }
        "Folder"{
            Write-Host Folder request: $auditData.ObjectId
            $siteUrl = $auditData.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $serverRelativeUrl = $auditData.ObjectId.Substring(30)
            $folder = $ctx.Web.GetFolderByServerRelativeUrl($serverRelativeUrl)
            $ctx.Load($folder)
            Load-CSOMProperties -object $folder -propertyNames "Name"
            Load-CSOMProperties -object $folder.ListItemAllFields -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $folder.ListItemAllFields.RoleAssignments
            CheckPermission $roles $ctx $spgroups $website $groups $auditData.ObjectId
            # Checking for each role assignments
            break;
        }
        "List"{
            Write-Host List request: $auditData.ObjectId
            $siteUrl = $auditData.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $serverRelativeUrl = $objectId.Substring(30)
            $list = $ctx.Web.GetList($serverRelativeUrl)
            $ctx.Load($list)
            Load-CSOMProperties -object $list -propertyNames "Title"
            Load-CSOMProperties -object $list -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $list.RoleAssignments
            CheckPermission $roles $ctx $spgroups $website $groups $auditData.ObjectId
            # Checking for each role assignments
            break;
        }
        "DocumentLibrary"{
            Write-Host Document Library request: $auditData.ObjectId
            $siteUrl = $auditData.SiteUrl
            $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
            $ctx = $authManager.GetAppOnlyAuthenticatedContext($siteUrl, $clientId, $clientSecret)
            $serverRelativeUrl = $objectId.Substring(30)
            $list = $ctx.web.GetList($serverRelativeUrl)
            $ctx.Load($list)
            Load-CSOMProperties -object $list -propertyNames "Title"
            Load-CSOMProperties -object $list -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
            $ctx.ExecuteQuery()
            $roles = $list.RoleAssignments
            CheckPermission $roles $ctx $spgroups $website $groups $auditData.ObjectId
            # Checking for each role assignments
            break;
        }
        Default {
            Write-Host Item type is new and does not match with any of the item types defined.
        }
    }
}

