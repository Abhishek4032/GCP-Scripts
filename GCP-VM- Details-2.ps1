#gcloud auth login
$Year=(Get-date).Year
$Month = (Get-culture).DateTimeFormat.GetMonthName((Get-date).month)
$day = (Get-date).Day
$date1 = "$day"+"$month"+"$Year"
$PR1 = Get-GcpProject | Where-Object {($_.parent.id -match "751300640634") -or ($_.parent.id -match "421951745560") -or ($_.parent.id -match "575159307124") -or ($_.parent.id -match "354757317999") -or ($_.parent.id -match "821693111065")-or ($_.parent.id -match "112884516946")-or ($_.parent.id -match "246668610864") -or ($_.parent.id -match "653425928408") -or ($_.parent.id -match "45252747385") -or ($_.parent.id -match "1017021995723") -or ($_.parent.id -match "327406243841") -or ($_.parent.id -match "93059218263") -or ($_.parent.id -match "232794302593") -or ($_.parent.id -match "1031428186250") -or ($_.parent.id -match "571210934812") -or ($_.parent.id -match "160267993472") -or ($_.parent.id -match "689077429603") -or ($_.parent.id -match "412630874206")}
foreach($p1 in $PR1){
$PRID1 = $P1.ProjectId
$GCEI = Get-GceInstance -Project $PRID1
foreach($GC in $GCEI){
$GCL = $GC.Labels
$GCIP = $GC.NetworkInterfaces
$info3 = [ordered]@{
         'Project' = $PRID1;
            'Name' = $GC.Name;
            'ID'   = $GC.Id;
    'CreationDate' = $GC.CreationTimestamp;
    'Status'       = $GC.Status;
    'Machine Type' = $GC.MachineType.Split('/')[-1];
    'Zone'         = $GC.Zone.Split('/')[-1];
    'IP Address'   = $GCIP.NetworkIP -Join ';';
'Interface Name'   = $GCIP.name;
'VPC Name'         = $GCIP.Network.Split('/')[-1];
'Subnet Name'      = $GCIP.SubNetwork.Split('/')[-1];
    'Labels'       = $GCL.Keys -join ";";
   'Lables Value'  = $GCL.Values -join ";"
            }
$obj3 = New-Object -TypeName psobject -Property $info3
Write-Output $obj3 | Export-csv -Path "C:\D Drive\GCP_VM_$Date1.csv" -NoTypeInformation -Append
}
}

#$obj = New-Object -TypeName psobject -Property $info
#Write-Output $obj | Export-csv -Path "D:\OutFiles\Snap.csv" -NoTypeInformation -Append