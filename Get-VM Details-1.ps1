#gcloud auth login
#$PR = Get-GcpProject | Where-Object {($_.Name -match "KD-") -or ($_.Name -match "test-poc-01")}
$PR = Get-GcpProject | Where-Object {$_.Name -match "test-poc-01"}
foreach($p in $PR){
$PRID = $P.ProjectId
$GceInstance = Get-GceInstance -Project "$PRID"
foreach($Instance in $GceInstance){
$info = [ordered]@{
         'Project' = $PRID;
            'ID'   = $Instance.Id;
            'Name' = $Instance.name;
    'CreationDate' = $Instance.CreationTimestamp;
    'Zone'         = $Instance.zone.Split('/')[-1];
    'Machine_Type' = $Instance.MachineType.Split('/')[-1];
    'Status'       = $Instance.Status;
    'sap_ins_name' = $Instance.Labels.sap_ins_name;
    'ritm'         = $Instance.Labels.ritm;
    'owner'        = $Instance.Labels.owner;
    'os'           = $Instance.Labels.os;
    'env'          = $Instance.Labels.env;
    'db_ins_name'  = $Instance.Labels.db_ins_name;
    'cost_center'  = $Instance.Labels.cost_center;
    'backup'       = $Instance.Labels.backup;
    'app_name'     = $Instance.Labels.app_name
            }
$obj = New-Object -TypeName psobject -Property $info
Write-Output $obj | Export-csv -Path "D:\OutFiles\Snap.csv" -NoTypeInformation -Append
}
}