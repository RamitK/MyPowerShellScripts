$custConnectors = Import-Csv -Path "C:\Users\ramit.kishore.saha\Desktop\CustConStatus.csv"
$log = New-Item -Path "C:\Ramit\addCustConToDlpLog.txt"
foreach($cust in $custConnectors){
    if(($cust.Status -in ("Can be retired", "Not replied")) -and ($cust.EnvironmentDisplayName -eq "Avanade (PRODUCTION)  (org0062045a)")){
        Write-Host $cust.DisplayName $cust.Status $cust.EnvironmentDisplayName
        $connectorId = "/providers/Microsoft.PowerApps/apis/" + $cust.ConnectorName
        try{
            Add-CustomConnectorToPolicy  -PolicyName "fa5c8669-2f3e-4fbd-9c10-b3a92a5d57d2" -ConnectorName $cust.DisplayName -ConnectorId $connectorId -ConnectorType Custom -GroupName lbi
            $line = $connectorId + "|" + $cust.DisplayName + "|Connector moved to 'No Business Data' group"
            Add-Content -Path "C:\Ramit\addCustConToDlpLog.txt" -Value $line
        }
        catch{
            $line = $connectorId + "|" + $cust.DisplayName + "|Connector could not be moved. Error: $($_.Exception.Message)"
            Add-Content -Path "C:\Ramit\addCustConToDlpLog.txt" -Value $line
        }
    }
    
    
}