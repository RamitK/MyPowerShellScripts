$fileSW = New-Object System.IO.StreamWriter "C:\TaskHandOverSPListBOTrackerDBSyncLog.txt"

Add-Type –Path "C:\Users\ramit.kishore.saha\Downloads\Microsoft.SharePoint.Client.dll" 
Add-Type –Path "C:\Users\ramit.kishore.saha\Downloads\Microsoft.SharePoint.Client.Runtime.dll" 
Add-Type –Path "C:\Users\ramit.kishore.saha\Downloads\DecrpytPassword.dll"



$siteUrl = '<Site URL>'
$listName = '<list name>'


$Password="IMoEdhejFa6FqLVqSS4Rnw=="  #Put Encrypted Password here
$pass=[DecrpytPassword.Decryption]::DecriptPassword($Password) #Decrypting Password here
[System.Security.SecureString] $strPass = ConvertTo-SecureString -String $pass -AsPlainText -Force

$objCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($User, $strPass)

#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($objCred.UserName,$objCred.Password)

$Context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($objCred.UserName,$objCred.Password)

$Query = New-Object Microsoft.SharePoint.Client.CamlQuery $Query.ViewXml = "@ <View> <Query> <Where> <Eq> <FieldRef Name='Category' /><Value Type='Text'>General</Value> </Eq> </Where> </Query> </View>"

$listItems = $list.GetItems($Query)


#Retrieve list
$list = $Context.Web.Lists.GetByTitle($listName)
$Context.Load($list)
$clientContext.Load($listItems)
$Context.ExecuteQuery()
$list.Title

$fileSW.WriteLine("SharePoint connection succeeded. List name is:" + $list.Title)


$SQLServer = "SEADEASQLSRV01"
$SQLDBName = "BOTracker_DB"
$SqlQuery = "SELECT * from TaskHandovers;"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True; "#User ID = $uid; Password = $pwd;"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

$fileSW.WriteLine("SQL table read successful")
$fileSW.WriteLine($DataSet.Tables[0][0])
$fileSW.flush()


foreach($listitem in $listItems)
{

	if($listitem["Category"] -eq 'General')
		{
				$flag = 0;
				foreach($data in $DataSet.Tables[0])
				{
					$fileSW.WriteLine("SharePoint TaskId is " + $listitem["TaskId"] + " and TaskHandOver table TaskId is " + $data.TaskId);
					if($listitem["TaskId"] -eq $data.TaskId)
					{
						$flag = 1;
					}
				}
				if($flag -eq 0)
				{
					$fileSW.WriteLine("Taskhandover table does not contain task with taskid " + $listitem["TaskId"] + " which should be added.")
					$fileSW.flush();
					$sqlCommand = New-Object System.Data.SqlClient.SqlCommand
					$sqlCommand.Connection = $sqlConnection    
					$sqlCommand.CommandText = 'Insert into TaskHandovers(TaskName,TaskId) values(@TaskName, @TaskId)';
					$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TaskName",[Data.SQLDBType]::VarChar, 100))) | Out-Null
					$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TaskId",[Data.SQLDBType]::int))) | Out-Null
					$sqlCommand.Parameters[0].Value = $listitem["Task_x0020_Nam"]
					$sqlCommand.Parameters[1].Value = $listitem["TaskId"]
					$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
					$sqlConnection.ConnectionString = "Server=SEADEASQLSRV01;Database=BOTracker_DB;Integrated Security=True;"
					$sqlCommand.Connection.Open()



					$SqlCommand.ExecuteScalar()		

				}

		}
	
		
}


