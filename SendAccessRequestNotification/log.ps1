foreach($log in $logs){
    $audit = $log.AuditData | ConvertFrom-Json; 
    # Write-Host $audit.CreationTime , $log.UserIds , $audit.Operation , $audit.ObjectId , $audit.SourceFileName
    $fileSW.WriteLine($audit.CreationTime + "|" + $log.UserIds + "|" + $audit.Operation + "|" + $audit.ObjectId + "|" + $audit.SourceFileName)
    $fileSW.Flush();
}