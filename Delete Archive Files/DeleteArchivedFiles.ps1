#The log file

$date = (Get-Date).tostring("dd-MMM-yyyy")
$fileName = $date + "DeleteOldArchive"
$log = $fileName + ".log"
$logFilePath = "\\seapeaapp01\d$\DeleteArchiveLogs\" + $log
$fileSW = New-Object System.IO.StreamWriter("\\seapeaapp01\d$\DeleteArchiveLogs\" + $log);

#Configuring the email

$Sub = "No Action: EA Archive file deletion: More than 30 days"
$Bod = $Bod = "<p>Hi Team,</p>
<p>Files older than 30 days have been deleted from EA App Archive (\\Seapeaappfile01\eaapp$). Please find the attached log for more details.</p>
<p>**This is an automated email triggered from the job running in SEAPEAAPP01. Please do not reply to this email.**</p>"
$To = "itseadops@site.com"
$CC = "pradeep.a.anchan@site.com"
$From = "itseadops@site.com"
$SMTP = "smtprelay.site.com"

#Deleting files

$fileSW.WriteLine("Looking for files")
$fileSW.Flush()

$files = Get-ChildItem \\Seapeaappfile01\eaapp$\ -recurse | ? {(($_.Extension -eq '.txt') -or ($_.Extension -eq '.xlsx') -or ($_.Extension -eq '.csv') -or ($_.Extension -eq '.xlsb')) -and ($_.LastWriteTime -lt (Get-Date).AddDays(-30))}

if($file -eq $null)
{
    $fileSW.WriteLine("No files to delete. No files are present which are more than 30 days old.")
    $fileSW.Flush()
}

else
{

    foreach($file in $files)
    {

        $fileSW.WriteLine("Deleting " + $file.fullname)
        $fileSW.Flush()
        #Remove-Item -Path $file.fullname

    }

}

$fileSW.Close()

#Sending Email

Send-MailMessage  -From $From -To $To -CC $CC -Subject $Sub -Body $Bod -SMTPServer $SMTP -BodyAsHtml -Attachments $logFilePath