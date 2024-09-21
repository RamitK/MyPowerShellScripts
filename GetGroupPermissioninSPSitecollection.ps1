Add-Type –Path "D:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "D:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\Microsoft.SharePoint.Client.Runtime.dll" 
Add-Type –Path "D:\Ramit\pnp\SharePointPnPPowerShell2016\2.24.1803.0\OfficeDevPnP.Core.dll"

#$fileSW = New-Object System.IO.StreamWriter("D:\Ramit\pnp\PermissionFroGroups1.txt");

#$fileSR = New-Object System.IO.StreamReader("C:\Users\ramit.kishore.saha\Desktop\Scripts\CSOM\PermissionForGroups\");



    

    

#Checking for the site collection



function CheckPermissions($website)
{

    Write-Host Checking for site $website.Url
    Write-Host -------------------------------------------------------------------------
    $webUrl = $website.Url

    #$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager; 
    #$clientContext = $authManager.GetWebLoginClientContext($website.Url);
	$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($website.Url) 
	$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials("svc_eatestsp@site.com", $password)
	$clientContext.Credentials = $credentials
    $web = $clientContext.Web
    $clientContext.Load($web)
    $clientContext.Load($web.webs)
    $clientContext.Executequery()
    Write-Host $web.Url
    
    
    
    $lists = $clientContext.Web.Lists
    $subsites = $clientContext.Web.Webs
    
    $spgroups=$clientContext.Web.SiteGroups
    $spusers = $clientContext.Web.SiteUsers
    $roles = $clientContext.Web.RoleAssignments
    $clientContext.Load($web)
    $clientContext.Load($spgroups)
    $clientContext.Load($spusers)
    $clientContext.Load($roles)
    $clientContext.Load($lists)
    $clientContext.Load($subsites)
    
   
 
    

    $clientContext.Executequery()
    $flag = 1

    if($spusers.GetByEmail($groupName1) -ne $null)
    {
        $spuser = $spusers.GetByEmail($groupName1)
        $clientContext.Load($spuser)
        $clientContext.Executequery()
    }
    else
    {
        Write-Host $groupName1 does not exist in this site. Skipping this site.
        $flag = 0
    }

    Write-Host Total sites inside this site: $subsites.count

    Write-Host Total list and document libraries inside this site: $lists.Count

    if($flag -eq 1)
    {

    foreach($role in $roles)
    {
        
        $oprincipal = $role.Member
        
        $bindings = $role.RoleDefinitionBindings
        $clientContext.Load($oprincipal)
        $clientContext.Load($bindings)
        $clientContext.Executequery()
        
        
        #Write-Host $oprincipal.TypedObject
        
       
        if($oprincipal.TypedObject.ToString() -eq "Microsoft.SharePoint.Client.Group")
        {
            #$fileSW.WriteLine("SharePoint group found " + $oprincipal.Title)
            Write-host Group Name $oprincipal.Title

            $group=$spgroups.GetByName($oprincipal.Title)
            $members = $group.Users
            $clientContext.Load($group)
            $clientContext.Load($members)
            $clientContext.ExecuteQuery()

            foreach($member in $members)
            {
               Write-Host Comparing $member.Email.ToUpper() with $groupName1.ToUpper()
            
                if($member.Email.ToUpper() -eq $groupName1.ToUpper())
                {

                    foreach($binding in $bindings)
                    {
                       #fileSW.WriteLine($groupName1 + " is added in the site " + $web + " inside the SharePoint group " + $oprincipal.Title + " with " + $binding + " permissions.")
                       Write-Host $groupName1  is FOUND the site  $web inside the SharePoint group  $oprincipal.Title  with  $binding.name  permissions.
                        
                    }         
                }

            
            }
            
        }

        if($oprincipal.TypedObject.ToString() -eq "Microsoft.SharePoint.Client.User")
        {  
            
           if($oprincipal.Title.ToUpper() -eq $spuser.Title.toupper())
           {
                    foreach($binding in $bindings)
                    {
                       #fileSW.WriteLine($groupName1 + " is added in the site " + $web + " inside the SharePoint group " + $oprincipal.Title + " with " + $binding + " permissions.")
                       Write-Host $groupName1  is FOUND in the site  $web.Url  with  $binding.name  permissions.
                        
                    }          
            
           
           }
        
        }
	}	


        #$binding
        #$role.member.GetType() 
        #$lists[0].HasUniqueRoleAssignments

        Write-Host List count in $web.Url is $lists.Count
    
    
    
	foreach($list in $lists)
	{
        
        $clientContext.Load($list)
        $listroles = $list.RoleAssignments
        
        $clientContext.Load($listroles)
        Load-CSOMProperties -object $list -PropertyNames "HasUniqueRoleAssignments"
        
        $clientContext.ExecuteQuery()
        Write-Host List/Library : $list.Title
        if($list.HasUniqueRoleAssignments -eq "True")
        {

            Write-Host $list.Title has unique permissions, checking further    
			foreach($listrole in $listroles)
			{
				
				$listoprincipal = $listrole.member
				
				$lrolebindings = $listrole.RoleDefinitionBindings
				$clientContext.Load($listoprincipal)
				$clientContext.Load($lrolebindings)
				$clientContext.Executequery()
                    
                
				
				
				#Write-Host $oprincipal.TypedObject
				
			   
				if($listoprincipal.TypedObject.ToString() -eq "Microsoft.SharePoint.Client.Group")
				{
						#$fileSW.WriteLine("SharePoint group found " + $oprincipal.Title)
						
                    
                    Write-Host $listoprincipal.Title.ToUpper() is the group
					$group=$spgroups.GetByName($listoprincipal.Title)
					$members = $group.Users
					$clientContext.Load($group)
					$clientContext.Load($members)
					$clientContext.ExecuteQuery()

					foreach($member in $members)
					{
						#Write-Host Comparing $member.Email.ToUpper() with $groupName1.ToUpper()
				
						if($member.Email.ToUpper() -eq $groupName1.ToUpper())
						{

							foreach($lrolebinding in $lrolebindings)
							{
							   #fileSW.WriteLine($groupName1 + " is added in the site " + $web + " inside the SharePoint group " + $oprincipal.Title + " with " + $binding + " permissions.")
							   Write-Host $groupName1  is FOUND in the site  $web inside the SharePoint group  $listoprincipal.Title  with  $lrolebinding.name  permissions for list .
									
							}         
						}

					}	
							
						
				}

				if($listoprincipal.TypedObject.ToString() -eq "Microsoft.SharePoint.Client.User")
				{  

                    Write-Host $listoprincipal.Title.ToUpper() is the user
						
				   if($listoprincipal.Title.ToUpper() -eq $spuser.Title.toupper())
				   {
						foreach($lrolebinding in $lrolebindings)
						{
						   #fileSW.WriteLine($groupName1 + " is added in the site " + $web + " inside the SharePoint group " + $oprincipal.Title + " with " + $binding + " permissions.")
						   Write-Host $groupName1  is FOUND in the site  $web.Url  with  $lrolebinding.name  permissions.
									
						}          
						
					   
				   }
				}
				
			
			}
		}

	}

    }	

    
}


$groupName1 = 'oldleadership@site.com'
$groupName2 =  'oldleadership@site.com'


    $siteUrl = <Site URL>;

    ##$fileSW.WriteLine("Checking for " + $siteUrl)
    #$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager; 
    #$ctx = $authManager.GetWebLoginClientContext($siteUrl);
	
	$password = Read-Host -Prompt "Enter password" -AsSecureString 
	$ctx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl) 
	$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials("svc_eatestsp@site.com", $password)
	$ctx.Credentials = $credentials

    $web = $ctx.Web
    $ctx.Load($web)
    $ctx.Load($web.webs)
    $ctx.Executequery()
    Write-Host $web.title

Write-Host Checking for site collection $web.Url
Write-Host -------------------------------------------------------------------------

Function EnumerateSubSites($web)
{
	#$ctx1 = $authManager.GetWebLoginClientContext($web);
	#$authManager = New-Object OfficeDevPnP.Core.AuthenticationManager; 
	#$ctx1 = $authManager.GetWebLoginClientContext($web.Url);
	$ctx1 = New-Object Microsoft.SharePoint.Client.ClientContext($web.Url) 
	$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials("svc_eatestsp@site.com", $password)
	$ctx1.Credentials = $credentials
	$website = $ctx1.Web
	$ChildWebs = $website.Webs;
	$ctx1.Load($ChildWebs)
    $ctx1.Load($website)
	$ctx1.ExecuteQuery();
	CheckPermissions $website
	
	foreach($ChildWeb in $ChildWebs)
	{
		
		EnumerateSubSites($ChildWeb);
	}
}

EnumerateSubSites $web 
    
    

    