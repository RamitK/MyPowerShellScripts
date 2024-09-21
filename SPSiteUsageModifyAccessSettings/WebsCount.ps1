connect-sposervice -url https://avanade-admin.sharepoint.com

$sitecols = get-sposite -Limit all

$fileSW = New-Object System.IO.StreamWriter("C:\Users\ramit.kishore.saha\Desktop\Microsoft.SharePointOnline.CSOM.16.1.8316.1200\sites.txt")

foreach($site in $sitecols){
$site = get-sposite -Identity https://avanade.sharepoint.com/sites/eaopsworkshop
$fileSW.WriteLine($site.Url + "|" + $site.webscount)
$fileSW.Flush()
}