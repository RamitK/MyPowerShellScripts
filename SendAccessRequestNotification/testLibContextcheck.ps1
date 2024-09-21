$site = "https://site.sharepoint.com/sites/testingsubsites"
$objectId = "https://site.sharepoint.com/sites/testingsubsites/Shared documents"
$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;

$ctx = $authManager.GetAppOnlyAuthenticatedContext($site, $clientId, $clientSecret)

$serverRelativeUrl = $objectId.Substring(30)
$list = $ctx.web.GetList($serverRelativeUrl)

$ctx.Load($list)

Load-CSOMProperties -object $list -propertyNames "Title"
Load-CSOMProperties -object $list -propertyNames "HasUniqueRoleAssignments", "RoleAssignments"
$ctx.ExecuteQuery()