Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.Runtime.dll" 

Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\OfficeDevPnP.Core.dll" 

$siteUrl = 'https://site.sharepoint.com/teams/ITS/ITSEAOpsandEng'
$listName = 'Azure Web Job Details'

$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager; 
$clientContext = $authManager.GetWebLoginClientContext($siteUrl);

$list = $clientContext.Web.Lists.GetByTitle($listName)
#$cquery = [New-Object Microsoft.SharePoint.Client.CamlQuery] :: CreateAllItemsQuery()
#$camlQuery = "<Query><Where><Eq><FieldRef Name='sequence'/><Value Type='Number'>1</Value></Eq></Where></Query>"
#$cquery.ViewXml=$camlQuery
$listItems = $list.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
$clientContext.Load($listItems)
$clientContext.ExecuteQuery()


Connect-MsolService

$services = Get-MsolServicePrincipal -All
#$fileSW = New-Object System.IO.StreamWriter("C:\Ramit\servicesdetailstest1.log");
#$fileSW.Writeline('Display Name|Client Id|Start Date|End Date|Key Id|Usage|Site URL');
#$counter = 0;

foreach ($service in $services)
{
    
    try
    {
        #Write-host $service.displayname
        $servicecredentialdetail = Get-MsolServicePrincipalCredential -AppPrincipalId $service.AppPrincipalId -ReturnKeyValues $false
        $servicePrincipalNames = $service.serviceprincipalnames

#[0].Substring($y.IndexOf("/")+1)
    
   

            #$fileSW.writeline($service.displayname + '|' + $service.AppPrincipalId + '|' + $servicecredentialdetail.startdate + '|' + $servicecredentialdetail.enddate + '|' + $servicecredentialdetail.keyid + '|' + $servicecredentialdetail.usage + '|' + $siteUrl)
        foreach($listItem in $listItems)
        {
            
           if($listItem["ClientId"] -eq $service.AppPrincipalId)
		   {
                Write-Host $listItem["ClientId"] 'matches with '  $service.AppPrincipalId
               
			    $listItem["StartDate"] = $servicecredentialdetail[0].startdate			            
                $listItem["ExpiryDate"] = $servicecredentialdetail[0].enddate
                       
                $listItem.Update()
			        
			    $clientContext.Load($listItem)
	
			    $clientContext.ExecuteQuery()
           }
            

	
           }
         

        }
    
    
    finally
    {}
    
}


	

