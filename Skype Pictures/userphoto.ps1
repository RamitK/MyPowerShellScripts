Connect-EXOPSSession -UserPrincipalName superramits@site.com

$users = 'greg.petersen@site.com', 'joseph.paradi@site.com', 'bob.bruns@site.com', 'cem.urfalioglu@site.com'

foreach($user in $users)
{

	$userphoto = Get-UserPhoto $user
	$path = "C:\Pictures\" + $user + ".jpg"
	$userphoto.picturedata | Set-Content $path -Encoding byte

}