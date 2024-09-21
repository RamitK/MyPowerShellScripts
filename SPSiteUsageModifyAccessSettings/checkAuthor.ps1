
$fileSW = New-Object System.IO.StreamWriter("C:\Users\ramit.kishore.saha\Desktop\Microsoft.SharePointOnline.CSOM.16.1.8316.1200\sites.txt")
$fileSW.WriteLine("URL|Author");
$fileSW.Flush()
Connect-PnPOnline -Url https://site-admin.sharepoint.com -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370= -TenantAdminUrl https://site-admin.sharepoint.com
$siteCols = Get-PnPTenantSite #Fetch all site collections
# [System.Collections.ArrayList]$siteCollection = @{};
$siteCols | ForEach-Object{
    Connect-PnPOnline -Url $_.Url -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370=
    # $web = Get-PnPSite -Includes Url, RootWeb.Author
    Connect-PnPOnline -Url https://site.sharepoint.com/sites/eaopsworkshop -AppId 20fa80b9-9742-40b8-be8b-6bc7b10a3fe6 -AppSecret XC7Q/zac92gVYRd4grSW/ksaaGdC2JzavedebxZo370=
    $web = Get-PnPWeb -Includes 
    #  $site = [PSCustomObject]@{
                    
    #     # SiteCollectionUrl  = $site."Site URL";    
    #     WebsiteUrl = $_.Url;            
    #     WebTemplate = $web.RootWeb.Author;
        
    # }
    # $siteCollection.Add($log)|Out-Null

    $fileSW.WriteLine($_.Url + "|" + $web.RootWeb.Author)
    $fileSW.WriteLine()


}