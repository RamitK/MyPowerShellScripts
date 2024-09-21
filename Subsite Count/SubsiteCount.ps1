Add-Type –Path "C:\panchan\PowerShell Libs\SharePointPnPPowerShell2016\2.19.1710.2\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\panchan\PowerShell Libs\SharePointPnPPowerShell2016\2.19.1710.2\Microsoft.SharePoint.Client.Runtime.dll" 
Add-Type –Path "C:\panchan\PowerShell Libs\SharePointPnPPowerShell2016\2.19.1710.2\OfficeDevPnP.Core.dll"
	

$fileRW = New-Object System.IO.StreamReader("C:\Ramit\sites.txt");
$fileSW = New-Object System.IO.StreamWriter("C:\Ramit\subsites.txt");
	
while (($line = $fileRW.ReadLine()) -ne $null)
{
	$siteUrl = $line
	$count = 0
	
	$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager;
	
	$ctx = $authManager.GetWebLoginClientContext($siteUrl);

	$web = $ctx.Web
	$ctx.Load($web)
	$ctx.Load($web.webs)
	$ctx.Executequery()
	Write-Host $web.title

	Write-Host Checking for site collection $web.Url
	Write-Host -------------------------------------------------------------------------

	Function EnumerateSubSites($web, $count)
	{

		
		$authManager1 = New-Object OfficeDevPnP.Core.AuthenticationManager;
		
		$ctx1 = $authManager1.GetWebLoginClientContext($web.Url);
		$website = $ctx1.Web
		$ChildWebs = $website.Webs;
		$ctx1.Load($ChildWebs)
		$ctx1.Load($website)
		$ctx1.ExecuteQuery();
		$fileSW.WriteLine('Site Name: ' + $web.Url)
		$fileSW.flush()
		$count ++
		


		
		foreach($ChildWeb in $ChildWebs)
		{
			
			EnumerateSubSites($ChildWeb, $count);
			
		}

		
	

	}



	EnumerateSubSites $web $count

	$fileSW.WriteLine($count)
	$fileSW.flush()

} 