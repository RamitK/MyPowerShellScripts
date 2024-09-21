#Deleting archived People files which are more than 7 days old

# © Ramit Kishore Saha
# Verified and edited by Eric Lafnitzegger

$logFilePath = "\\seapeaapp01\d$\DeletePeopleArchiveLogs\$((Get-Date).tostring("dd-MMM-yyyy"))DeleteOldArchive.log"

$fileSW = New-Object System.IO.StreamWriter($logFilePath);

$sendCompletionNotice = {
    Param (
        [string] $logFilePath
    )

    $args = @{
        From = "itseadops@site.com"
        To = "itseadops@site.com"
        CC = "pradeep.a.anchan@site.com"
        Subject = "No Action: EA Archive People file deletion: More than 7 days"
        Body = "<p>Hi Team,</p><p>People files older than 7 days have been deleted from EA App Archive. Please find the attached log for more details.</p><p>**This is an automated email triggered from the job running in SEAPEAAPP01. Please do not reply to this email.**</p>"
        SMTPServer = "smtprelay.site.com"
        BodyAsHtml = $true
        Attachments = $logFilePath


    }

    Send-MailMessage @args
}

function deleteFiles($path, $fileInclude)
{

    $fileSW.WriteLine("Looking for files")
    $fileSW.Flush()

    $files = Get-ChildItem $path -include $fileInclude -Recurse | ? {(($_.Extension -eq '.txt') -or ($_.Extension -eq '.xlsx') -or ($_.Extension -eq '.csv') -or ($_.Extension -eq '.xlsb')) -and ($_.LastWriteTime -lt (Get-Date).AddDays(-7))}

    if($files -eq $null)
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
}

$archives = @(
    @{
        path = "\\seapaapbi01\d$\DigitalHub"
        fileInclude = 'CandidateSkillInventory*','LearningActivity*','LearningActivityToDomain*','LearningActivityToLevel*','LearningActivityToSkill*','LearningDomain*','LearningDomain*','LearningPublisher*','MRDRPeople*'
    }
    @{
        path = "\\SEAPEAAPPFILE01\EAAPP$\A3\In\AcnMRDR\Archive\MRDR\"
        fileInclude = '*-PeopleDirectory-PeopleRole.csv','*-PeopleDirectory-tblPeople.csv','*-PeopleDirectory-tblPeopleCoInstruction.csv','*-PeopleDirectory-tblPeopleSensitive.csv'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\ADP\In"
        fileInclude = 'ADP_*'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\AEBI\In\BI_Files\Archive\FMR\"
        fileInclude = '*-FinanceEBI-AccountGroupExecutivesExtract.csv'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\siteHardwareReq_IQN\IQNCSV\Archive"
        fileInclude = '*-siteAssignmentDetails.csv'
    }
        @{path = "\\Seapeaappfile01\eaapp$\siteHardwareReq_IQN\SSP\Archive"
        fileInclude = '*-AvaContractorHardwareStatus.csv'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\sitePeopleData_DWI\Archive\"
        fileInclude = '*-sitePeopleData.xlsx'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\Benevity\Archive"
        fileInclude = '*-Benevity_User_Demographic.csv','benevity_deduction_Australia_*','benevity_deduction_Canada_*','benevity_deduction_UK_*','benevity_deduction_USA_*','site_success_Australia_*','site_success_Canada_*','site_success_UK_*','site_success_USA_*'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\DI\In\Archive"
        fileInclude = '*-DeliveryEBI-CertificationWall*','*-DeliveryEBI-DILeadershipComments*'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\GloboForce\PayrollIN"
        fileInclude = 'site_PayrollFeed_*'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\HRInsights\Archive"
        fileInclude = 'Attrition Metrics.xlsx','*-Activity1.nopag.xlsx','*-Activity2.nopag.xlsx','*-Approval.nopag.xlsx','*-Assignment.nopag.xlsx','*-Attempt.nopag.xlsx','*-AvaBigThinkAttempts.csv','*-AvaBigThinkCourses.csv','*-CandidateSurvey.xlsx','*-Compliance.nopag.xlsx','*-Evaluation.nopag.xlsx','*-HeadCountChanges.xlsx','*-HeadCountChanges.xlsx','*-HREBI-AzureCertTargetsExtract.csv','*-HREBI-CandidateSurveyExtract.csv','*-HREBI-HeadcountChangesExtract.csv','*-HREBI-HeadcountChangesExtract.csv','*-HREBI-Level4TargetsExtract.csv','*-HREBI-Level5TargetsExtract.csv','*-HREBI-Level6TargetsExtract.csv','*-HREBI-LMSCertificationExamExtract.csv','*-HREBI-LMSCertificationExtract.csv','*-HREBI-LMSUserCertificationExamExtract.csv','*-HREBI-LMSUserCertificationExtract.csv','*-HREBI-MySchedulingCertsExtract.csv','*-HREBI-MySchedulingCertsExtract.csv','*-HREBI-MySchedulingCertsExtract_DI.csv','*-HREBI-ProductivityTargetsExceptionExtract.csv','*-HREBI-ProductivityTargetsExtract.csv','*-HREBI-SAPRosterExtract.csv','*-HREBI-SharedServiceUsersExtract.csv','*-HREBI-TaleoCandidateDiversityExtract.csv','*-HREBI-TaleoCandidateSlatingExtract.csv','*-HREBI-TaleoHiresExtract.csv','*-HREBI-TaleoInterviewComplianceExtract.csv','*-HREBI-TaleoOARExtract.csv','*-HREBI-TaleoRequitionExtract.csv','*-HREBI-TaleoThruputExtract.csv','*-HREBI-TaleoThruputHiresExtract.csv','*-HREBI-TaleoTTOExtract.csv','*-Instructor.nopag.xlsx','*-Interest.nopag.xlsx','*-LMS_Activity1.csv','*-LMS_Activity2.csv','*-LMS_Approval.csv','*-LMS_Assignment.csv','*-LMS_Attempt.csv','*-LMS_Compliance.csv','*-LMS_Evaluation.csv','*-LMS_Instructor.csv','*-LMS_Interest.csv','*-LMS_Waitlist.csv','*-MTDProductivity.csv','*-MySchedulingUpload.xlsx','*-MySchedulingUpload.xlsx','*-ProductivityMTD.xlsx','*-ProductivityYTD.xlsx','*-SAPRoster.xlsx','*-SAPRoster.xlsx','*-TalentReview.csv','*-TalentReview.xlsx','*-TaleoScorecardDataFile.xlsx','*-Waitlist.nopag.xlsx','*-YTDProductivity.csv'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\LegalHoldContactsFeed\Archive"
        fileInclude = 'LegalHoldContactsFeed_*'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\MME\Archive"
        fileInclude = '*-MME-siteEACExtract.csv'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\MySchedulingInsights\Archive"
        fileInclude = '*-MySchedulingEBI-CandidateRoster.csv','*-MySchedulingEBI-CandidateRoster.csv','*-MySchedulingEBI-CandidateRoster.csv','*-MySchedulingEBI-CandidateSkillInventory.csv','*-MySchedulingEBI-CandidateSkillInventory.csv','*-MySchedulingEBI-CandidateSkillInventory.csv','*-MySchedulingEBI-DataPeopleExtract.csv','*-MySchedulingEBI-DataPeopleExtract.csv','*-MySchedulingEBI-DataPeopleExtract.csv','*-MySchedulingEBI-DemandCandidateList.csv','*-MySchedulingEBI-DemandCandidateList.csv','*-MySchedulingEBI-DemandCandidateList.csv','*-MySchedulingEBI-IndividualRawStatus.csv','*-MySchedulingEBI-IndividualRawStatus.csv','*-MySchedulingEBI-IndividualRawStatus.csv','*-MyschedulingEBI-PeopleSpecialInterestGroup.csv','*-PeopleProductivityDetail.csv','*-PeopleProductivityDetail.csv','*-PeopleProductivityDetail.csv'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\ServiceNow\Archive"
        fileInclude = '*_User_Supplementary_Data.xlsx'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\ServiceNowContractors\Archive"
        fileInclude = 'ContractorAttributes-*'
    }
    @{
        path = "\\Seapeaappfile01\eaapp$\TCC\Archive"
        fileInclude = 'GBLVNDPAI454.*'
    }
)

foreach ($archive in $archives) {
    deleteFiles $archive.path $archive.fileInclude
}

$fileSW.Close()

& $sendCompletionNotice $logFilePath