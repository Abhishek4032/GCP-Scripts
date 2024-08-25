# Authenticate with GCP
# gcloud auth login
# gcloud auth activate-service-account --key-file="path-to-your-service-account-key.json"

# Define a function to fetch VM details for a specific project
function Get-VMDetails {
    param (
        [string]$projectId
    )
    
    # Set the project
    gcloud config set project $projectId
    
    # Fetch VM instances
    $instances = gcloud compute instances list --format=json | ConvertFrom-Json
    $totalInstances = $instances.Count

    if ($totalInstances -eq 0) {
        Write-Output "No VM instances found in project: $projectId"
        return @()  # Return an empty array
    }

    $currentInstanceIndex = 0
    $vmDetailsList = @()

    foreach ($instance in $instances) {
        $instanceName = $instance.name
        $zone = $instance.zone
        
        try {
            # Get metadata for the instance
            $metadata = gcloud compute instances describe $instanceName --zone=$zone --format=json | ConvertFrom-Json
            $metadataItems = $metadata.metadata.items

            # Add metadata items to the list
            foreach ($metadataItem in $metadataItems) {
                $vmDetails = [PSCustomObject]@{
                    ProjectId = $projectId
                    InstanceName = $instanceName
                    Zone = $zone.Split('/')[-1]
                    Key = $metadataItem.key
                    Value = $metadataItem.value
                }
                $vmDetailsList += $vmDetails
            }
        } catch {
            Write-Error "Failed to describe instance $instanceName in zone $zone $_"
        }
        
        # Update progress
        $currentInstanceIndex++
        $percentageComplete = [math]::Round(($currentInstanceIndex / $totalInstances) * 100, 2)
        Write-Progress -PercentComplete $percentageComplete -Status "Processing VM Instances" -CurrentOperation "Processing instance $currentInstanceIndex of $totalInstances"
    }
    
    return $vmDetailsList
}

# Main script execution
$projectId = "test-poc-01"  # Replace with your project ID
Write-Output "Fetching VMs for project: $projectId"

$vmDetails = Get-VMDetails -projectId $projectId

if ($vmDetails.Count -gt 0) {
    # Export the data to a CSV file
    $csvFilePath = "C:\D Drive\VMsMetadata.csv"  # Update path if necessary
    $vmDetails | Export-Csv -Path $csvFilePath -NoTypeInformation
    Write-Output "Data exported to $csvFilePath"
} else {
    Write-Output "No metadata found for project: $projectId"
}
