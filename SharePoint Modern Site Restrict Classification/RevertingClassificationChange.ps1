Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.Runtime.dll" 
Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\OfficeDevPnP.Core.dll"

#connecting to Exchange Online
$User = "superramits@avanadeitstest.com"
$File = "C:\Password.txt"
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $MyCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

$fileSW = New-Object System.IO.StreamWriter("C:\Ramit\demo.log")
$fileSW.WriteLine("Script started")

#connecting to SharePoint Online

Connect-SPOService -Url https://avanadeitstest-admin.sharepoint.com -Credential $UserCredential

#checking for Team sites
$sites = get-sposite -Limit all | select * | where($_.title -like "*ramit*")}
$groupSites = $sites | where{$_.template -eq "GROUP#0"}
$groupSites | Export-Csv -Path 'C:\Ramit\ExchangeOnline\GroupSites.csv'

#checking for Communications sites
$communicationSites = $sites | where{$_.template -eq "SITEPAGEPUBLISHING#0"}
$communicationSites | Export-Csv -Path 'C:\Ramit\ExchangeOnline\GroupSites.csv'

Get-UnifiedGroup | select name, sharepointsiteurl, classification, identity | Export-Csv -Path 'C:\Ramit\ExchangeOnline\Groups.csv'
$groups = Import-csv -Path 'C:\Ramit\ExchangeOnline\Groups.csv'

#Reverting classification change for Team sites

foreach($site in $groupSites)
{

        $URL = $site.URL
        Write-Host Site URL: $URL
        
        set-spouser -Site $URL -LoginName superramits@avanadeitstest.com -IsSiteCollectionAdmin $true
        set-sposite -identity $URL -DenyAddAndCustomizePages 0
        $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
        $ctx = $authManager.GetWebLoginClientContext($URL)
        $web = $ctx.Web
        $allProperties = $web.allproperties
        $ctx.Load($web)
        $ctx.Load($allProperties)
        $ctx.ExecuteQuery()

        if($allProperties["customclassification"] -ne $null)
        {

            Write-Host Classification: $allProperties["customclassification"] Site: 
            foreach($group in $groups)
            {

                Write-Host Group Name: $group.Name
                if($URL -eq $group.SharePointSiteUrl)
                {
                    Write-Host Site URL: $URL Group Site URL: $group.SharePointSiteUrl
                    Write-Host Group classification: $group.Classification Custom classification: $allProperties["customclassification"]

                    if($allProperties["customclassification"] -ne $group.Classification)
                    {
                        
                        Set-UnifiedGroup -Identity $group.Name -Classification $allProperties["customclassification"]
                    }

                    $fileSW.WriteLine("SharePoint Site: " + $web.url + ", Group Name: " + $group.SharePointSiteUrl + ",  Group Classification: " + $group.Classification + " , SharePoint Site Custom Classification: " + $web.allProperties["customclassification"])
                    $fileSW.Flush()
                        
                }
            }
        }        
}

#Reverting classification change for Communications Sites

foreach($site in $communicationSites)
{

        $URL = $site.Url
        Write-Host Site URL: $URL
        
        set-spouser -Site $URL -LoginName superramits@avanadeitstest.com -IsSiteCollectionAdmin $true
        set-sposite -identity $URL -DenyAddAndCustomizePages 0
        $authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
        $ctx = $authManager.GetWebLoginClientContext($URL)
        $web = $ctx.Web
        $allProperties = $web.allproperties
        $site = $ctx.Site
        $ctx.Load($web)
        $ctx.Load($site)
        $ctx.Load($allProperties)
        $ctx.ExecuteQuery()

        if($allProperties["customclassification"] -ne $null)
        {

            Write-Host WebSite Classification: $allProperties["customclassification"] WebSite: $web.Url Site Classification: $site.Classification
            if($allProperties["customclassification"] -ne $site.Classification)
            {
                        
                $site.Classification = $allProperties["customclassification"]
			    $ctx.ExecuteQuery()
            }

                    Write-Host SharePoint WebSite: $web.url  Site Name:  $site.PrimaryUri  Site Classification: $site.Classification  SharePoint WebSite Custom Classification:  $web.allProperties["customclassification"]
                    $fileSW.Flush()
   
        }    
       
}
$fileSW.Close()
