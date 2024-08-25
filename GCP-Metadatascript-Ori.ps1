# Authenticate with GCP
# gcloud auth login
# gcloud auth activate-service-account --key-file="path-to-your-service-account-key.json"

# Define a function to fetch VM details
function Get-VMDetails {
  param (
      [string]$projectId
  )
  
  # Set the project
  gcloud config set project $projectId
  
  # Fetch VM instances
  $instances = gcloud compute instances list --format=json | ConvertFrom-Json

  $vmDetailsList = @()

  foreach ($instance in $instances) {
      $instanceName = $instance.name
      $zone = $instance.zone
      
      try {
          # Get metadata for the instance to check if scripts are setup
          $metadata = gcloud compute instances describe $instanceName --zone=$zone --format=json | ConvertFrom-Json
          $metadataItems = $metadata.metadata.items

          # Filter metadata items to get all startup script related keys
          $startupScripts = $metadataItems | Where-Object { $_.key -like '*start*' }
          
          foreach ($startupScript in $startupScripts) {
              $vmDetails = [PSCustomObject]@{
                  ProjectId = $projectId
                  InstanceName = $instanceName
                  Zone = $zone.Split('/')[-1]
                  Key = $startupScript.key
                  StartupScript = $startupScript.value
              }
              $vmDetailsList += $vmDetails
          }
      } catch {
          Write-Error "Failed to describe instance $instanceName in zone $zone $_"
      }
  }
  
  return $vmDetailsList
}

# Get list of all projects
function Get-AllProjects {
  $projects = gcloud projects list --format=json | ConvertFrom-Json
  return $projects
}

# Main script execution
$allVmDetails = @()
$projects = Get-AllProjects

foreach ($project in $projects) {
  $projectId = $project.projectId
  Write-Output "Fetching VMs for project: $projectId"
  
  $vmDetails = Get-VMDetails -projectId $projectId
  
  if ($vmDetails) {
      $allVmDetails += $vmDetails
  } else {
      Write-Output "No startup scripts found for project: $projectId"
  }
}

# Export the data to a CSV file
$csvFilePath = "C:\D Drive\VMsWithStartupScripts.csv"
$allVmDetails | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Output "Data exported to $csvFilePath"

#------------------------------------------------------------------------------------------------------------------#

<## Authenticate with GCP
#gcloud auth login
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

    $vmDetailsList = @()

    foreach ($instance in $instances) {
        $instanceName = $instance.name
        $zone = $instance.zone
        
        try {
            # Get metadata for the instance to check if scripts are setup
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
    }
    
    return $vmDetailsList
}

# Main script execution
$projectId = "test-poc-01"  # Replace with your project ID
Write-Output "Fetching VMs for project: $projectId"
    
$vmDetails = Get-VMDetails -projectId $projectId
    
if ($vmDetails) {
    # Export the data to a CSV file
    $csvFilePath = "C:\D Drive\VMsWithStartupScripts.csv"
    $vmDetails | Export-Csv -Path $csvFilePath -NoTypeInformation
    Write-Output "Data exported to $csvFilePath"
} else {
    Write-Output "No startup scripts found for project: $projectId"
}
#>
