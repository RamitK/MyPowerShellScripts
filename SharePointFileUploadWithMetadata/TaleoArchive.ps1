$path = "D:\TaleoExtractData\20190424\ApplicationPDFExportFiles\Application_pdf\"
$allFiles = Get-ChildItem -LiteralPath $path
Connect-PnPOnline -Url "<Site URL>" -UseWebLogin

foreach($file in $allFiles){

    $fileName = $file.Name
    $fileNameSplit = $file.Name.split("_")
    Add-PnPFile -Path ($path + $fileName) -Folder "Shared%20Documents%2FApplication_pdf" -Values @{CandidateID = $fileNameSplit[0]; Requisition_x0020_ID = $fileNameSplit[1]; Country = $fileNameSplit[-2]}
}
