<# 

'  ACTT Tool Extraction Code for GCP
'
'  
' ------------------------------------------------------------------------------------
'   Date			Responsible							Activity			
' ------------------------------------------------------------------------------------
' 23/Aug/2022		Antony, Godwin				Code Created
' 08/Sep/2022 		Antony, Godwin 				Updated code to extract IAM policies for Organizations, Folder and Projects.
' 14/Sep/2022		Antony, Godwin				Updated code to extract service accounts and custom roles.
' 28/Sep/2022		Antony, Godwin 				Updated code to extract storage Bucket and compute instance details
' 06/Oct/2022		Antony, Godwin				Updated code for Service Account and Custom Role IAM policies
' 19/Feb/2022		Kosuri, Tarun				Update code to extract  SubFolders policies
' 15/Jun/2023		Antony, Godwin				Updated code to address Null Projects and Folders
#>
$ScriptStartTime = Get-Date
$Extract_Script_Version = "20.0_pilot"
$psVersion = $PSVersionTable.PSVersion.Major
$Path = Join-Path (Get-Location) "\ACTTGCP_RAW"
If(!(test-path -Path $Path))
{
New-Item -ItemType directory -Path $Path > $null   #-Force  #. (current directory) 3-Name 
}
Start-Transcript -Path $(Join-Path $Path "\ACTTDATA.LOG") -UseMinimalHeader   #create ps session text to a log file
Write-output "*#*" | out-file -Append -encoding unicode -filepath "$Path\ACTT_CONFIG_FIELDTERMINATOR.actt"
Write-output "SettingName VARCHAR(100)*#*SettingValue VARCHAR(max)" | out-file -Append -encoding unicode -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "Extract Application Version*#*GoogleCloud" | out-file -Append -encoding unicode -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "Extract Script Version*#*$($Extract_Script_Version)" | out-file -Append -encoding unicode -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "Data Extraction Date*#*$($ScriptStartTime)" | out-file -Append -encoding unicode -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"
Write-output "PowerShell Version*#*$($psVersion)" | out-file -Append -encoding unicode -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"

function New-ZipExtractedData 
{
    #Simple function to zip the extracted data
    #If(test-path -Path $Path)
    #{
       # If($($PSVersionTable.PSVersion.Major) -ge 3)
		#{
	       
            $source = $Path
        $destination = Join-Path (Get-Location) "\ACTTGCPOutput_RAW.zip"
        
        If(Test-path $destination) {Remove-item $destination}
        Add-Type -assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($Source, $destination)
        
        #Compress-Archive -Path $Path_ZipLOc_target $Path_D\$DBNAME_MAP.zip -Force 
       # Remove-Item -Recurse -Force $Path
       # }
    #}        
}
$orglist = gcloud organizations list --format='value(displayName,name)'
$orglistcount = $orglist.Count
if ( $orglist.Count -eq 1)
	{
	$Org = $orglist.split("`t")[0]
	$Orgid = $orglist.split("`t")[1]
	Write-Host " Organization attached in this GCP account is $Org" -ForegroundColor Green
	Write-Host "Script extracting from the $Org organization"
	Write-Host "`n"
	}
else
	{
	Write-Host "Below are the Organizations available in this gcp account" -ForegroundColor Green
	gcloud organizations list --format='value(displayName,name)'
	$Org=Read-Host "Enter the Organization Name:"
	$Orgid=Read-Host "Enter the Organization ID:"
	Write-Host "Script extracting from the given Organization  $Org"
	}
Write-output "Extraction of Organization Policies is started for $Org " | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of  Organization Policies started"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Policy.json"
Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Policy.json"
Write-Output """Organization"" :""$Org""," | out-file -Append -encoding unicode -filepath "$Path\Organizations_Policy.json"
Write-Output """OrganizationProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Policy.json"
gcloud organizations get-iam-policy $Org --format json | out-file -Append -encoding unicode -filepath "$Path\Organizations_Policy.json"
Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Policy.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Policy.json"
Write-output "Extraction of Organization Policies is ended" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Organization Policies ended"
Write-Host "`n"
##########
Write-Host "Extraction of custom roles attached to the OrganisationID:{$Org} is started"
Write-output "Extraction of custom roles attached to the OrganisationID:{$Org}" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
$orgcrolelist = @()
$orgcrolelist=gcloud iam roles list --organization=$Orgid --format=value'(name)' | %{$_.substring($_.lastindexof("/")+1)}
$crolelistcount = $orgcrolelist.Count
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"
#Write-Host "$orgcrolelist"
foreach ($orgcrole in $orgcrolelist)
	{
	$crolelistcount = $crolelistcount - 1
#Write-Host "$orgcrole"
Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"			
Write-Host "Extraction of includedPermissions under custom role {$orgcrole}: "
Write-output "Extraction of includedPermissions under custom role {$orgcrole}: " | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-output """Organization"" :""$Org""," | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"
Write-output """CustomRole"" :""$orgcrole""," | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"
Write-Output """CustomRoleProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json" #Prakash
gcloud iam roles describe $orgcrole --organization=$orgid --format json | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"
if ($crolelistcount -ge 1)
	{
		Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"
	}
	else
	{
		Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"
	}
		Write-Host "Extraction of includedPermissions under custom role {$orgcrole} is completed "
		Write-output "Extraction of includedPermissions under custom role {$orgcrole} is completed " | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
	}
Write-Host "Extraction of custom roles attached to the OrganisationID:{$Org} is completed"
Write-output "Extraction of custom roles attached to the OrganisationID:{$Org} is completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Organizations_Customroles.json"
Write-Host "`n"
#Write-Output "Extraction of Organizations Custom role completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
##########



#Recursive function to return folders and it's subfolders

Function SubFolders{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory, ValueFromPipeline)]
		[validateNotNullorEmpty()]
		[string]
		$folderId
	)

	$ResultFoldersList =@()
	$FolderList=gcloud resource-manager folders list --folder=$folderId --format=json'(name,displayName)'| convertFrom-json
	foreach($folder in $FolderList)
	{
		$infolderId = $folder.name.substring($folder.name.indexof('/')+1)
		$folderobj = [PSCustomObject] @{
									'Folder Name' = $folder.displayName
									'Folder ID' = $infolderId					            
					}
		$ResultFoldersList += $folderobj
		if((gcloud resource-manager folders list --folder=$infolderId --format=object) -ne $null)
		{
			$ResultFoldersList += SubFolders -folderId $infolderId
		}
	}
	return $ResultFoldersList
}


Function Get-Folder
	{
		Write-Host "Searching the Folders available in this GCP account......." -ForegroundColor Blue
		Write-Host "`n"
		#gcloud resource-manager folders list --organization $Orgid --format='value(displayName,name)'
		#$global:Loop1=''
		
		
		$GCPFoldList=@()
		$ParentFoldersList = gcloud resource-manager folders list --organization $Orgid --format=json'(name,displayName)' | convertFrom-json
		#Loop to iterate through ParentFolders and call Recusive Function for subFolders		
		Foreach($ChildFolder in $ParentFoldersList){
			$ChildFolderID = $ChildFolder.name.substring($ChildFolder.name.indexof('/')+1)
			$folderobj = [PSCustomObject] @{
										'Folder Name' = $ChildFolder.displayName
										'Folder ID' = $ChildFolderID					            
						 }
			$GCPFoldList += $folderobj
			$GCPFoldList += SubFolders -folderId $ChildFolderID
		}
		Write-Host "Below are the Folders available in this gcp account" -ForegroundColor Green
		#To Print Folders List
		$GCPFoldList | Format-Table 
		$GCPFoldList | convertTo-json | out-file -Append -encoding unicode -filepath "$Path\Selected_Folders.json"
		
		$global:Loop1=(Read-Host "Enter the Folder ID to be analyzed in comma(,) separated format")
		if ($global:Loop1)
		{
					
		Write-Host "$global:Loop1"
		$global:Loop1=$global:Loop1.Split(',')
#Write-Host "$global:Loop1"
		$global:Loop1count=$global:Loop1.count
#Write-host $global:Loop1.count
		foreach ($folderid in $global:Loop1)
			{
				$global:Loop1count = $global:Loop1count - 1
				Write-Host "Extraction of the Policies for folderid:{$folderid}"
				Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
				Write-Output """Folder"" :""$folderid""," | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
				Write-Output """FolderProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json" #Prakash
				#gcloud resource-manager folders get-ancestors-iam-policy $folderid --format json | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
				
				$chk1=gcloud resource-manager folders get-iam-policy $folderid --format text
				if($chk1)
				{
				gcloud resource-manager folders get-iam-policy $folderid --format json | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
					if ($global:Loop1count -ge 1)
					{
						Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
					}
					else
					{
						Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
						}
				}
				else
				{
					Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
				}
				
			}
	}
	else
	{
		Write-Host "`n"
		Write-Host "No Folder is selected for extraction"
	}
			Write-Host "`n"
			Write-output "Extraction of  Folders in $Org is ended" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
			Write-Host "Extraction of Folders in $Org ended"
$global:Loop1count=$global:Loop1.count
}
Write-output "Extraction of  Folders in $Org is started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "`n"
Write-Host "Extraction of Folders in $Org started"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
Get-Folder
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Folders_iam_policy.json"
Write-Host "Extraction of Folders in $Orgid Completed"
Write-output "Extraction of  Folders in $Org is Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
gcloud resource-manager folders list --organization $Orgid --format json | out-file -Append -encoding unicode -filepath "$Path\Folders_list.json"
Write-Host "`n"
##########
Function Get-Project
{
	Write-Host "Below are the Projects configured in $Org" -ForegroundColor Green
	#gcloud projects list --format='value(Name,projectId)' | Format-Table Name,@{Label='Project ID';Expression={$_.projectId}} 
	#--------------FOr all projects in a organization
	gcloud projects list --format=json'(name,projectId)' | ConvertFrom-JSON | Format-Table @{Label='Name';Expression={$_.name}},@{Label='Project ID';Expression={$_.projectId}}
	
	#$global:Loop2=''
	$global:Loop2=(Read-Host "Enter the project ID's to be analyzed in comma(,) separated format")
	$global:Loop2=$global:Loop2.Split(',')
	$global:Loop2count=$global:Loop2.count
	foreach ($proid in $global:Loop2)
		{
			
			$global:Loop2count = $global:Loop2count - 1
			Write-Host "Extraction policies for $proid is started"
			Write-Output "{"| out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
			Write-Output """ProjectID"" :""$proid""," | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
			Write-Output """ProjectProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json" #Prakash
			
			$chk2=gcloud projects get-iam-policy $proid --format text
				if($chk2)
				{
			
			gcloud projects get-iam-policy $proid --format json | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
			if ($global:Loop2count -ge 1)
			{
				Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
			}
			else
			{
				Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
			}
			Write-Host "Extraction policies for $proid is completed" 
				}
				else
				{
				Write-Output "{}" | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
				}
				
		}
}
Write-Host "Extraction of Project IAM policy Started"
Write-output "Extraction of Project IAM policy Started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
Get-Project
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Projects_iam_policy.json"
Write-output "Extraction of Project IAM policy Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Project IAM policy Completed"
Write-Host "`n"
##########
Write-output "Extraction of Service User accounts for Projects Started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Service User accounts for Projects started"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
$global:Loop2count=$global:Loop2.count
#Write-Host "$global:Loop2count"
foreach ($proid in $global:Loop2)
	{
		Write-Host "Extracting Service Accounts for $proid"
		Write-Output "Extraction of Service User accounts for project $proid started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
		$global:Loop2count = $global:Loop2count - 1
		Write-Output "{"| out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
		Write-Output """ProjectID"":""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
		$check1=gcloud iam service-accounts list --project=$proid --format json | Select-String "email"
		if ($check1.count -ne 0)
		{
				Write-Output ",""ServiceProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
				gcloud iam service-accounts list --project=$proid --format json | out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
		}
		if ($global:Loop2count -ge 1)
		{
				Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
				Write-Host "Extraction Service Accounts for $proid is completed"
				Write-Host "`n"
		}
		else
		{
			Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
			Write-Host "Extraction Service Accounts for $proid is completed"
			Write-Host "`n"
		}
	}
		
		Write-Output "Extraction of Service User accounts for project $proid Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts.json"
Write-output "Extraction of Service User accounts for Projects Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Service User accounts for Projects Completed"
Write-Host "`n"
################
Write-output "Extraction of Storage Bucket User Lists for Projects started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Storage Bucket User Lists for Projects started"
Write-output "Extraction of Custom Roles List for Projects started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Project Custom Role List for Projects started"
Write-Host "`n"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
$global:Loop2count=$global:Loop2.count
#Write-Host "$global:Loop2count"
foreach ($proid in $global:Loop2)
	{
	Write-Host "Extraction of Storage Buckets for $proid is started"
	Write-output "Extraction of Bucket User Lists for Projects started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
	Write-Host "Extraction of Project Custom Roles List for $proid is started"
	Write-output "Extraction of Custom Roles List for Projects started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
		
	$global:Loop2count = $global:Loop2count - 1
	Write-Output "{"| out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
	Write-Output "{"| out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
	Write-Output """ProjectID"":""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
	Write-Output """ProjectID"":""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
	$check3=gcloud storage buckets list --project=$proid --format json | Select-String "id"
	$check4=gcloud iam roles list --project=$proid --format=value'(name)' | %{$_.substring($_.lastindexof("/")+1)}
		if ($check3.count -ne 0)
		{
			Write-Output ",""BucketProperties"":" | out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
			gcloud storage buckets list --project=$proid --format json | out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
		}
		if ($check4.count -ne 0)
		{
			Write-Output ",""CustomRoleDetails"":" | out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
			gcloud iam roles list --project=$proid --format json | out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
		}
		if ($global:Loop2count -ge 1)
		{
			Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
			Write-Host "Extraction of Storage Buckets for $proid is completed"
			Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
			Write-Host "Extraction of Project Custom Roles for $proid is completed"
			Write-Host "`n"
		}
		else
		{
			Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
			Write-Host "Extraction of Storage Buckets for $proid is completed"
			Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
			Write-Host "Extraction of Project Custom Roles for $proid is completed"
			Write-Host "`n"
		}
		Write-output "Extraction of Bucket User Lists for Projects Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
		Write-output "Extraction of Custom Roles List for Projects Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
	}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Buckets_list.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Project_CustomRole_list.json"
$global:Loop2count=$global:Loop2.count
#Write-Host "$global:Loop2count"
###################
Write-Host "Extraction of  includedPermissions for custom roles under projects started"
Write-Output "Extraction of  includedPermissions for custom roles under projects started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
foreach ($proid in $global:Loop2)
	{
		$global:Loop2count = $global:Loop2count - 1
		#Write-Output "$global:Loop2count"
		$crolelist=gcloud iam roles list --project=$proid --format=value'(name)' | %{$_.substring($_.lastindexof("/")+1)}
		$customrolelistcount = $crolelist.Count
		if ($customrolelistcount -ne 0)
		{
			foreach ($crole in $crolelist)
			{
				$customrolelistcount = $customrolelistcount - 1
				Write-Output "Custom role assigned to project $proid is $crole"
				$check5=gcloud iam roles describe --project=$proid $crole --format json
					if ($check5.count -ne 0)
					{
						Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
						Write-Output """ProjectID"" :""$proid"","| out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
						Write-output """CustomRole"" :""$crole"","| out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
						Write-Output """Permissions"":" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
						gcloud iam roles describe --project=$proid $crole --format json  | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
					}
					if ($customrolelistcount -ge 1)
					{
						Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
					}
					else
					{
						if ($global:Loop2count -ge 1)
						{
							Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
						}
						else
						{
							Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
						}
					
					}
			}
		}
		else
		{
			if ($global:Loop2count -gt 0)
			{
				Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
				Write-Host "No Custom roles in $proid"
				Write-Output """ProjectID"" :""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
				#Write-Output """CustomRole"":" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json" 
				#Write-Output "{}"  | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
				Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
			}
			else
			{
				Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
				Write-Output """ProjectID"" :""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
				#Write-Output """CustomRole"":" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
				#Write-Output "{}"  | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"				
				Write-Host "No Custom Roles in $proid"
				Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
			}
		}
	}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Projects_Customroles.json"
Write-Host "Extraction of  includedPermissions for custom roles under projects started"
Write-Output "Extraction of  includedPermissions for custom roles under projects started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
$global:Loop2count=$global:Loop2.count
Write-Host "`n"
##########
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
Write-Host "Extraction of Service Account details on Instances started"
Write-output "Extraction of Service Account details on Instances started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"

foreach ($proid in $global:Loop2)
	{
		Write-Host "Extracting of Service Account details on Instances for $proid"
		Write-Output "Extraction Service Account details on Instances for project $proid started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
		$global:Loop2count = $global:Loop2count - 1
		Write-Output "{"| out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
		Write-Output """ProjectID"":""$proid"""| out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
		#$check6=gcloud compute instances list --project=$proid --format="json(name,serviceAccounts)" | Select-String "email"
		$check6=gcloud services list --enabled --project=$proid --format json | Select-String "compute.googleapis.com"
		if ($check6.count -ne 0)
		{
				Write-Output ",""ServiceAccountDetails"":" | out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
				$check61=gcloud compute instances list --project=$proid --format="json(name,serviceAccounts)"
				if ($check61.count -ne 0)
				{
					gcloud compute instances list --project=$proid --format="json(name,serviceAccounts)" | out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
				}
				else
				{
					Write-Output "{}"  | out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
				}
		}		
		if ($global:Loop2count -ge 1)
		{
				Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
				Write-Host "Extracting of Service Account details on Instances for $proid is completed"
				Write-Host "`n"
		}
		else
		{
			Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
			Write-Host "Extracting of Service Account details on Instances for $proid is completed"
			Write-Host "`n"
		}
	
	
	}
		
Write-Output "Extraction of Service Account details on Instances started $proid Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\instances_serviceaccounts.json"
Write-Host "Extraction of Service Account details on Instances Completed"
Write-Output "Extraction of Service Account details on Instances Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "`n"
$global:Loop2count=$global:Loop2.count
###########

Write-Host "Extraction of Service Account IAM policies and Keys List started"
Write-output "Extraction Service Account IAM policies and Keys List started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
		
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
foreach ($proid in $global:Loop2)
	{
		Write-Host "Extracting of Service Account IAM policies and Keys List for $proid"
		Write-Output "Extracting of Service Account IAM policies and Keys List for $proid started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
		$global:Loop2count = $global:Loop2count - 1
		#Write-Output "$global:Loop2count"
		$servaccountlist=gcloud iam service-accounts list --project=$proid --format='value(email)'
		$servaccountlistcount = $servaccountlist.Count
		if ($servaccountlistcount  -ne 0)
		{
			foreach ($saccount in $servaccountlist)
			{
				$servaccountlistcount = $servaccountlistcount - 1
				#Write-Output "The name of Project is  $proid"
				#Write-Output "The name of service Account is  $saccount"
				$check3=gcloud iam service-accounts get-iam-policy $saccount --format json
				if ($check3.count -ne 0)
				{
					Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
					Write-Output """ProjectID"" :""$proid"","| out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
					Write-output """ServiceAccountUser"":""$saccount""" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
					Write-Output ",""ServiceAccountsPolicyDetails"":" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
					
					Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
					Write-Output """ProjectID"" :""$proid"","| out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
					Write-output """ServiceAccountUser"":""$saccount""" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
					Write-Output ",""ServiceAccountsKeysDetails"":" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
										
					
					gcloud iam service-accounts get-iam-policy $saccount --format json  | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
					gcloud iam service-accounts keys list --iam-account=$saccount --format json  | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"

				}
				if ($servaccountlistcount -ge 1)
				{
					Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
					Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
				}
				else
				{
					if ($global:Loop2count -ge 1)
					{
						Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
						Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
					}
					else
					{
						Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
						Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
					}
				}
			}
		}
		else
		{
			if ($global:Loop2count -gt 0)
			{
				Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
				#Write-Output "No Service Accounts in $proid"
				Write-Output """ProjectID"" :""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
				Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
				
				Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
				#Write-Output "No Service Accounts in $proid"
				Write-Output """ProjectID"" :""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
				Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
			}
			else
			{
				Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
				Write-Output """ProjectID"" :""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
				#Write-Output "No Service Accounts in $proid"
				Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
				
				Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
				Write-Output """ProjectID"" :""$proid"""| out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
				#Write-Output "No Service Accounts in $proid"
				Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
			}
		}
	}
	
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_iam_policy.json"
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Service_accounts_Keys_List.json"
Write-output "Extraction Service Account IAM policies and Key Lists Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction of Service Account IAM policies and Key Lists Completed"
Write-Host "`n"
gcloud projects list --format json | out-file -Append -encoding unicode -filepath "$Path\Projects_list.json"
##########
Write-Host "Extraction of Users details for Folders started"
Write-output "Extraction of Users details for Folders started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
$folder=gcloud resource-manager folders list --organization $Orgid --format='value(name)'
$folderidcount=$folder.count
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json"
foreach ($fid in $folder)
{
	$folderidcount=$folderidcount-1
	Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json"
	Write-Output """FolderID"" :""$fid""," | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json"
	Write-Output """Properties"":" | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json" #Prakash
	gcloud resource-manager folders get-iam-policy $fid --format json | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json"
	if ($folderidcount -ge 1)	
	{
		Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json"
	}
	else
	{
		Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json"
		}
	}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Folder_list_all.json"
Write-Host "Extraction of Users details for Folders Completed"
Write-output "Extraction of Users details for Folders completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "`n"
##########
Write-Host "Extraction of Users details for Projects started"
Write-output "Extraction of Users details for Projects started" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
$projects=gcloud projects list  --format='value(projectId)'
$projectsidcount=$projects.count
Write-Output "[" | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
foreach ($proid in $projects)
{
	$projectsidcount=$projectsidcount-1
	Write-Output "{" | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
	Write-Output """ProjectID"" :""$proid""," | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
	Write-Output """Properties"":" | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"  #Prakash
	#gcloud projects get-iam-policy $proid --flatten=bindings  --format='value(bindings.members,bindings.role,bindings.condition)' | sed 's/^/\"/' | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
	gcloud projects get-iam-policy $proid --format json | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
	if ($projectsidcount -ge 1)
	{
	Write-Output "}," | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
	}
	else
	{
	Write-Output "}" | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
	}
}
Write-Output "]" | out-file -Append -encoding unicode -filepath "$Path\Projects_list_all.json"
Write-Host "Extraction of Users details for Projects Completed"
Write-Output "Extraction of Users details for Projects Completed" | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"

##########

$ScriptEndTime = Get-Date
Write-output "Extract End Date*#*$($ScriptEndTime)" | out-file -append -encoding unicode  -filepath "$Path\ACTT_CONFIG_SETTINGS.actt"

##Compress-Archive -path $Path -DestinationPath .\acttAzureRaw.zip

Write-output "Extraction Completed  " | out-file -Append -encoding unicode -filepath "$Path\SCRIPT_FLOW.txt"
Write-Host "Extraction Completed"

New-ZipExtractedData

Stop-Transcript

Write-Host "********* IMPORTANT: The file has successfully generated as ACTTGCPOutput_RAW.zip **********" -ForegroundColor Green
Write-Host "**********Please make sure to delete the generated file "ACTTGCPOutput_RAW.zip" and Folder "ACTTGCP_RAW"  from the server after you have provided the file to Deloitte Engagement Team********" -ForegroundColor Green



			
					
					
				


						
						
		
		
	
		
		

		
