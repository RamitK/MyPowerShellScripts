Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.Runtime.dll" 

Add-Type –Path "C:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\OfficeDevPnP.Core.dll" 

$siteUrl = 'https://site.sharepoint.com/teams/ITS/ITSEAOpsandEng'
$listName = 'Azure Apps Details'

$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager; 
$clientContext = $authManager.GetWebLoginClientContext($siteUrl);

$list = $clientContext.Web.Lists.GetByTitle($listName)
#$cquery = [New-Object Microsoft.SharePoint.Client.CamlQuery] :: CreateAllItemsQuery()
#$camlQuery = "<Query><Where><Eq><FieldRef Name='sequence'/><Value Type='Number'>1</Value></Eq></Where></Query>"
#$cquery.ViewXml=$camlQuery
$listItems = $list.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
$clientContext.Load($listItems)
$clientContext.ExecuteQuery()


#Connect-MsolService

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
            
          <# if($listItem["ClientId"] -eq $service.AppPrincipalId)
		   {
                Write-Host $listItem["ClientId"] 'matches with '  $service.AppPrincipalId 'for ClientId'
                $listItem["ClientId"] = $service.AppPrincipalId
			    $listItem["AppName"] = $service.displayname
			    $listItem["SecretStartDate"] = $servicecredentialdetail[0].startdate			            
                $listItem["SecretEndDate"] = $servicecredentialdetail[0].enddate
                       
                $listItem.Update()
			        
			    $clientContext.Load($listItem)
	
			    $clientContext.ExecuteQuery()
           }
            
            
           else
           { #>
            
                foreach($servicePrincipalName in $servicePrincipalNames)
                {
                          
	                if($listItem["HostName1"] -eq $servicePrincipalName.Substring($servicePrincipalName.IndexOf("/")+1))
                    {
                        Write-Host $listItem["HostName1"] 'matches with '  $servicePrincipalName 'for HostName1'
                        $listItem["ClientId"] = $service.AppPrincipalId
			            $listItem["AppName"] = $service.displayname
			            $listItem["SecretStartDate"] = $servicecredentialdetail[0].startdate			            
                        $listItem["SecretEndDate"] = $servicecredentialdetail[0].enddate
                       
                        $listItem.Update()
			        
			            $clientContext.Load($listItem)
	
			            $clientContext.ExecuteQuery()
		            }
	                elseif($listItem["HostName2"] -eq $servicePrincipalName.Substring($servicePrincipalName.IndexOf("/")+1))
                    {
                        Write-Host $listItem["HostName2"]  'matches with ' $servicePrincipalName 'for HostName2'
                        $listItem["ClientId"] = $service.AppPrincipalId
			            $listItem["AppName"] = $service.displayname
			            $listItem["SecretStartDate"] = $servicecredentialdetail[0].startdate			            
                        $listItem["SecretEndDate"] = $servicecredentialdetail[0].enddate
                       
                        $listItem.Update()
			        
			            $clientContext.Load($listItem)
	
			            $clientContext.ExecuteQuery()
		            }
	                elseif($listItem["HostName3"] -eq $servicePrincipalName.Substring($servicePrincipalName.IndexOf("/")+1))
		            {
                        Write-Host $listItem["HostName3"]  'matches with '  $servicePrincipalName 'for HostName3'
                        $listItem["ClientId"] = $service.AppPrincipalId
			            $listItem["AppName"] = $service.displayname
			            $listItem["SecretStartDate"] = $servicecredentialdetail[0].startdate			            
                        $listItem["SecretEndDate"] = $servicecredentialdetail[0].enddate
                       
                        $listItem.Update()
			        
			            $clientContext.Load($listItem)
	
			            $clientContext.ExecuteQuery()
		            }
	                elseif($listItem["HostName4"] -eq $servicePrincipalName.Substring($servicePrincipalName.IndexOf("/")+1))
		            {
                        Write-Host $listItem["HostName4"]  'matches with '  $servicePrincipalName 'for HostName4'
                        $listItem["ClientId"] = $service.AppPrincipalId
			            $listItem["AppName"] = $service.displayname
			            $listItem["SecretStartDate"] = $servicecredentialdetail[0].startdate			            
                        $listItem["SecretEndDate"] = $servicecredentialdetail[0].enddate
                       
                        $listItem.Update()
			        
			            $clientContext.Load($listItem)
	
			            $clientContext.ExecuteQuery()
		            }
                    elseif($servicePrincipalName -like '*'+$listItem["Title"]+'*' )
		            {
                        Write-Host $listItem["Title"]  'matches with '  $servicePrincipalName 'for sitename'
                        $listItem["ClientId"] = $service.AppPrincipalId
			            $listItem["AppName"] = $service.displayname
			            $listItem["SecretStartDate"] = $servicecredentialdetail[0].startdate			            
                        $listItem["SecretEndDate"] = $servicecredentialdetail[0].enddate
                       
                        $listItem.Update()
			        
			            $clientContext.Load($listItem)
	
			            $clientContext.ExecuteQuery()
		            }
                }
	
           }
         <#}#>

        }
    
    
    finally
    {}
    
}


	

