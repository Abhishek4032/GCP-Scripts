gcloud auth login
#$PR = Get-GcpProject | Where-Object {($_.Name -match "KD-") -or ($_.Name -match "test-poc-01")}
$PR = Get-GcpProject | Where-Object {$_.Name -match "test-poc-01"}
foreach($p in $PR){
$PRID = $P.ProjectId
$GCEDISK = Get-GceDisk -Project "$PRID"
foreach($disk in $GCEDISK){
$info = [ordered]@{
         'Project' = $PRID;
            'Name' = $disk.Name;
            'ID'   = $disk.Id;
        'Size (GB)'= $disk.SizeGB;
    'CreationDate' = $disk.CreationTimestamp;
    'Disk Type'    = $disk.Type.Split('/')[-1];
    'Zone'         = $disk.Zone.Split('/')[-1];
    'In Use by'    = $InUSE.Split('/')[-1];
    'SnapSched'    = $disk.SourceSnapshotId
            }
$obj = New-Object -TypeName psobject -Property $info
Write-Output $obj | Export-csv -Path "D:\OutFiles\Snap.csv" -NoTypeInformation -Append
}
}