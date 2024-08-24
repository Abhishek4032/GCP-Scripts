#This script will create the lables for GCP VMs as per the details provided in csv file. Column name should not be changed for the csv file

#import the values from csv, change the file path as per requirement
$instances = Import-Csv C:\Users\HCL\Desktop\label\label_format.csv

foreach ($ins in $instances){

    # Below command can be used if labels need to be updated for multiple project at once
    #gcloud config set project $ins.ProjectId

    #value for labels are fetched from csv file 
    #1
    [string]$RITM = $ins.RITM
    $ritm_number = $RITM.ToLower()
    #2
    [string]$Application = $ins.Application
    $application_name = $Application.ToLower()
    #3
    [string]$Owner = $ins.owner
    $application_owner = $Owner.ToLower()
    #4
    [string]$cost = $ins.costcenter
    $costcenter = $cost.ToLower()
    #5
    [string]$env = $ins.environment
    $environment = $env.ToLower()
    #6
    [string]$operatingsystem = $ins.os
    $os = $operatingsystem.ToLower()
    #7
    [string]$bck = $ins.backup
    $backup = $bck.ToLower()
    #8
    [string]$sapins = $ins.sapinstance
    $sap_instance_name = $sapins.ToLower()
    #9
    [string]$dbins = $ins.dbinstance
    $db_instance_name = $dbins.ToLower()

    $zone =$ins.Zone

   

    #Updating the Labels info for VMs 

    gcloud compute instances add-labels $ins.Name --labels=ritm=$ritm_number --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=app_name=$application_name --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=owner=$application_owner --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=cost_center=$costcenter --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=env=$environment --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=os=$os --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=backup=$backup --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=sap_ins_name=$sap_instance_name --zone=$zone
    gcloud compute instances add-labels $ins.Name --labels=db_ins_name=$db_instance_name --zone=$zone
   


 
}





Exp-
    Import-Csv
    
    Project	ProjectId	Name	Zone	RITM	Application	owner	costcenter	environment	os	backup	sapinstance	dbinstance
    test-poc-01	test-poc-01	test-upgrade1	us-east4-c	RITM00000	test	cloud-ops	675	dev	2012-r2	na	na	na
    test-poc-01	test-poc-01	test-iis	us-east4-a	RITM00001	test1	cloud-ops	1234	dev	2016_standard	na	na	na
    