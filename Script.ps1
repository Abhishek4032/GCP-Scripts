#gcloud auth login
$PR = Get-GcpProject | Where-Object {($_.Name -match "test-poc-01")}
foreach($p in $PR){
$PRID = $P.ProjectId
$GCEDISK = Get-GceDisk -Project "$PRID"
foreach($disk in $GCEDISK){
#$InUSE = $disk.Users.ToArray()
$InUse = $Disk.Users.Split('/')[-1] | -Append
$info = [ordered]@{
         'Project' = $PRID;
            'Name' = $disk.Name;
            'ID'   = $disk.Id;
        'Size (GB)'= $disk.SizeGB;
    'CreationDate' = $disk.CreationTimestamp;
    'Disk Type'    = $disk.Type.Split('/')[-1];
    'Zone'         = $disk.Zone.Split('/')[-1];
    'In Use by'    = $InUse
            } 
$obj = New-Object -TypeName psobject -Property $info
Write-Output $obj | Export-csv -Path $env:USERPROFILE\Documents\VMsDisks.csv -Append
}
}
