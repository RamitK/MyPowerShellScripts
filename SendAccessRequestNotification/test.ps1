Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\OfficeDevPnP.Core.dll"
$clientId = "ceb4f40f-cceb-4a5c-b032-4f290f3c224a"
$clientSecret = "+iVuTrRF4ezftUpNJ8vhetJCVM77Pn20RlLCdYHivAE="
$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
$site = "https://siteitstest.sharepoint.com/sites/ramitdemo1"
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

if($website.WebTemplate -eq "GROUP"){
    
}

foreach($spuser in $spusers){
    if($spuser.IsSiteAdmin){
        Write-Host $spuser.Title
    }
}

foreach($role in $roles){
    
    $oprincipal = $role.Member
    $bindings = $role.RoleDefinitionBindings
    $ctx.Load($oprincipal)
    $ctx.Load($bindings)
    $ctx.Executequery()

    foreach($binding in $bindings){
        if($binding.Name -eq "Full Control"){
            if($oprincipal.TypedObject.ToString() -eq "Microsoft.SharePoint.Client.Group"){
                $group=$spgroups.GetByName($oprincipal.Title)
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


$fileSW = New-Object System.IO.StreamWriter("logs1.txt")
$content = $logs.Content
$ccontent = $content | ConvertFrom-Json
$blobContentAR = @()
$count = 0
foreach($contentUri in $ccontent.contenturi){
    $data = Invoke-WebRequest -Method GET -Headers $headerParams -uri $contentUri
    $blobContent = $data.content | ConvertFrom-Json
    
    foreach($bContent in $blobContent){ 
            $fileSW.WriteLine($bContent.CreationTime + "|" + $bContent.Operation + "|" + $bContent.ObjectId + "|" + $bContent.UserId + "|" + $bContent.ItemType)
            $fileSW.Flush()
            Write-Host Creation Time:   $bContent.CreationTime   Operation:   $bContent.Operation   ObjectId:   $bContent.ObjectId  User Id:  $bContent.UserId  Item Type: $bContent.ItemType
            $blobContentAR = $blobContentAR + $bContent
            }
    $count ++
}

Foreach($site in $sites){
    $data.WriteLine($site.Url + "`" + $site.Title + "`" + $site.Template + "`"+ $site.WebsCount);
    $data.Flush();
}

Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\3.10.1906.0\OfficeDevPnP.Core.dll"

$clientId = "ceb4f40f-cceb-4a5c-b032-4f290f3c224a"
$clientSecret = "+iVuTrRF4ezftUpNJ8vhetJCVM77Pn20RlLCdYHivAE="

$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
$site = "https://siteitstest.sharepoint.com"
$ctx = $authManager.GetAppOnlyAuthenticatedContext($site, $clientId, $clientSecret)

$EmailProperties = New-Object Microsoft.SharePoint.Client.Utilities.EmailProperties
# $EmailProperties.From = "ramit.kishore.saha@siteitstest.com"
$EmailProperties.To = [String[]] "ramit.kishore.saha@site.com"
$EmailProperties.Subject = "Hi"
$EmailProperties.Body = "Hi"
[Microsoft.SharePoint.Client.Utilities.Utility]::SendEmail($Ctx,$EmailProperties)
$Ctx.ExecuteQuery()


#Read more: https://www.sharepointdiary.com/2016/11/sharepoint-online-powershell-to-send-email.html#ixzz5z8LVZaod