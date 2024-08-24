gcloud auth login

gcloud config set project [PROJECT_ID]

$bucket = $(gsutil ls);
    #Write-Host "Bucket: $bucket"
    gsutil du -sh $bucket


    # Set the project (if not already set)
gcloud config set project [PROJECT_ID]

# List all buckets in the project
$buckets=$(gsutil ls)

# Iterate through each bucket and get its storage usage
bucket in $buckets;
    echo "Bucket: $bucket"
    gsutil du -sh $bucket
-----------------------------------------------------------------------------------------------


#gcloud auth login
#$PR = Get-GcpProject | Where-Object {($_.Name -match "KD-") -or ($_.Name -match "test-poc-01")}
$PR = Get-GcpProject | Where-Object {$_.Name -match "test-poc-01"}
foreach($p in $PR){
$PRID = $P.ProjectId
$GceInstance = Get-Gcestorage
$buckets=$(gsutil ls) -Project "$PRID"
foreach($bucket in $buckets){
    $info = [ordered]@{
        'Project' = $PRID;
           'ID'   = $Instance.Id;
}
$Stodetails += $Info
}

Write-Output $bucket | Export-csv -Path "C:\D Drive\Snap.csv"
$obj | Out-GridView

bucket in $(gsutil ls);
    echo "Bucket: $bucket"
    gsutil du -sh $bucket

#$obj = New-Object -TypeName psobject -Property $bucket
#Write-Output $obj | Export-csv -Path "C:\D Drive\Snap.csv"
#$allVMs | Export-csv -Path "C:\D Drive\Snap1.csv"
$obj | Out-GridView
}

# List all buckets in the project
$bucket=$(gsutil ls)

# Iterate through each bucket and get its storage usage
bucket = $bucket;
    #Write-Host "Bucket: $bucket"
    gsutil du -sh $bucket



    