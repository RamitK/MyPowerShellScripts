Add-Type -Path "C:\Users\superramits\Desktop\Microsoft.SharePointOnline.CSOM.16.1.8316.1200\lib\net40-full\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Users\superramits\Desktop\Microsoft.SharePointOnline.CSOM.16.1.8316.1200\lib\net40-full\Microsoft.SharePoint.Client.Runtime.dll"

Connect-PnPOnline -Url https://site-admin.sharepoint.com -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370= -TenantAdminUrl 1
$siteCol = Get-PnPTenantSite 



foreach($site in $siteCol){
    Connect-PnPOnline -Url $site.Url  -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370=
    Connect-PnPOnline -Url https://site.sharepoint.com/sites/eaopsworkshop  -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370=
    $site = Get-PnPSite
    $webs += Get-PnPSubWebs -Recurse
    $webs
}

