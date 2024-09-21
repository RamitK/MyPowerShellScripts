Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.Runtime.dll" 

Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\OfficeDevPnP.Core.dll" 

$siteUrl = 'https://site.sharepoint.com/teams/ITS/ITSEAOpsandEng'
$listName = 'Azure Apps Details'
$flag = 0

$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager; 
$clientContext = $authManager.GetWebLoginClientContext($siteUrl);

$list = $clientContext.Web.Lists.GetByTitle($listName)
#$cquery = [New-Object Microsoft.SharePoint.Client.CamlQuery] :: CreateAllItemsQuery()
#$camlQuery = "<Query><Where><Eq><FieldRef Name='sequence'/><Value Type='Number'>1</Value></Eq></Where></Query>"
#$cquery.ViewXml=$camlQuery
$listItems = $list.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
$clientContext.Load($listItems)
$clientContext.ExecuteQuery()


Login-AzureRmAccount
$subs = get-azurermsubscription
$fileSW = New-Object System.IO.StreamWriter "C:\Ramit\webappcerts8.txt"
$fileSW.WriteLine("Subscription Name|Site Name|Default Hostname|State|Location|Resource Group|Certificate|Certificate Expiry Date|Certificate Issuer|Binding|SSL State|Thumbprint")
foreach ($sub in $subs)
{
	select-azurermsubscription -subscriptionname $sub.name
	$webs = get-azurermwebapp
	foreach ($web in $webs)
	{
        $certbind = get-azurermwebappsslbinding -webappname $web.sitename -resourcegroupname $web.resourcegroup
		$certs = get-azurermwebappcertificate -resourcegroupname $web.resourcegroup
        $cert = $certs | where{$_.thumbprint -eq $certbind.Thumbprint}
		$fileSW.Write($sub.name+ "|" +$web.sitename+ "|" +$web.defaulthostname+ "|" +$web.state+ "|" +$web.location+ "|" +$web.resourcegroup)

		
		
		$fileSW.Write( "|" +$cert.hostnames+ "|" +$cert.expirationdate+ "|" +$cert.issuer)
		
		$fileSW.Write("|" +$certbind.Name+ "|" +$certbind.SslState+ "|" +$certbind.Thumbprint)
		$fileSW.WriteLine("")
		

        foreach($listItem in $listItems)
        {
	        if($listItem["Title"] -eq $web.sitename)
		        {
			        $flag = 1;
			        $listItem["SubscriptionName"] = $sub.name
			        $listItem["Title"] = $web.sitename
			        $listItem["DefaultHostname"] = $web.defaulthostname
			        $listItem["State"] = $web.state
			        $listItem["Location"] = $web.location
			        $listItem["ResourceGroup"] = $web.resourcegroup
			        $hostnames = ''
                    foreach($hostname in $web.HostNames)
                    {
                        $hostnames = $hostnames  + $hostname + ';'
                    }

                    $hostnames = $hostnames.substring(0,$hostnames.length-1)
                    $listitem["HostNames"] = $hostnames

			        $listItem["CertificateExpiryDate"] = $cert.expirationdate
			        $listItem["CertificateIssuer"] = $cert.issuer
			        $listItem["Binding"] = $certbind.Name
			        $listItem["SSLState"] = $certbind.SslState
			        $listItem["Thumbprint"] = $certbind.Thumbprint
			        $listItem.Update()
			        
			        $clientContext.Load($listItem)
	
			        $clientContext.ExecuteQuery()
		        }
	
        }

	    if($flag -eq 0)
		{
            $listItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation  
			$listItem = $list.AddItem($listItemInfo)
			$listItem["SubscriptionName"] = $sub.name
			$listItem["Title"] = $web.sitename
			$listItem["DefaultHostname"] = $web.defaulthostname
			$listItem["State"] = $web.state
			$listItem["Location"] = $web.location
			$listItem["ResourceGroup"] = $web.resourcegroup
			$listItem["HostName1"] = $web.hostnames[0]
            if($web.hostnames[1] -ne $null)
            {
			    $listItem["HostName2"] = $web.hostnames[1]
            }
			if($web.hostnames[2] -ne $null)
            {
			    $listItem["HostName3"] = $web.hostnames[2]
            }
			if($web.hostnames[3] -ne $null)
            {
			    $listItem["HostName4"] = $web.hostnames[3]
            }
            If($certs[-1].hostnames -ne $null)
            {
			    $listItem["Certificate"] = $cert.hostnames
            }
			$listItem["CertificateExpiryDate"] = $cert.expirationdate
			$listItem["CertificateIssuer"] = $cert.issuer
			$listItem["Binding"] = $certbind.Name
			$listItem["SSLState"] = $certbind.SslState
			$listItem["Thumbprint"] = $certbind.Thumbprint
			$listItem.Update()
			
			$clientContext.Load($listItem)
	
            $clientContext.ExecuteQuery()
		}

	}
	

}
$fileSW.Close()