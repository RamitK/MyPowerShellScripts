$clientId = "f776b667-3c54-4c45-9050-4edd7cf797c8"
$clientSecret = "kv3eCAnFzdfkrDBfKKRgFHCH/8AJ32RWPGtFzWZR9ic="

$emailSmtpServer = "site-com.mail.protection.outlook.com"
$emailSmtpServerPort = 587
$emailSmtpUser = "svc_ITSmsflow@site.onmicrosoft.com"
$emailSmtpPass = "19BISkutrotti$"
 
$emailFrom = "svc_ITSmsflow@site.onmicrosoft.com"
$emailTo = "ramit.kishore.saha@site.com"
$emailcc="ramit.kishore.saha@site.com"


$credential = (Get-Credential)
Send-MailMessage -Body test -Subject test -From $emailFrom -To $emailTo -Credential $credential -SmtpServer "smtp.office365.com" -Port 587 -UseSsl
 
$emailMessage = New-Object System.Net.Mail.MailMessage( $emailFrom , $emailTo )
$emailMessage.cc.add($emailcc)
$emailMessage.Subject = "subject" 
#$emailMessage.IsBodyHtml = $true #true or false depends
$emailMessage.Body = "Hi"

$SMTPClient = New-Object System.Net.Mail.SmtpClient( "site-com.mail.protection.outlook.com" , 25 )
$SMTPClient.EnableSsl = $True
$SMTPClient.UseDefaultCredentials = $false
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
$SMTPClient.Send( $emailMessage )
# Connect-PnPOnline -Url https://site.sharepoint.com -AppId $clientId -AppSecret $clientSecret
# Send-PnPMail -To $emailTo -From $emailSmtpUser -Subject "Test" -Body "Test" -Password $emailSmtpPass

# Send-PnPMail -To ramit.kishore.saha@site.com -Subject test -Body test -From svc_ITSmsflow@site.onmicrosoft.com -Password 19BISkutrotti$



# Encrypt the password
$encryptedPassword = ConvertTo-SecureString “19BISkutrotti$” -AsPlainText -Force

# Create a credentials object with the e-mail and password
$mycreds = New-Object System.Management.Automation.PSCredential (“svc_ITSmsflow@site.onmicrosoft.com”, $encryptedPassword)

# Send the e-mail (should take less than 5 seconds)
Send-MailMessage -To "ramit.kishore.saha@site.com" -SmtpServer "smtp.office365.com" -Credential $mycreds -UseSsl "Hello World" -Port "25" -Body "Hello World,<br/>This is your first e-mail<br/>Kind regards,<br/><br/>Your Support Bot" -From "svc_ITSmsflow@site.onmicrosoft.com" -BodyAsHtml