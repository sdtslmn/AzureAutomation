# Connect to Azure Account
Connect-AzAccount 

# Specify parameters
$subscriptionId = "Your Subscription ID"
$daysToLookBack = 30  # How many days of usage data to analyze
$cpuUtilizationThreshold = 10   # Below this % average CPU, VM is considered underutilized
$networkUtilizationThreshold = 500000 # Below this average network out (Bytes), VM is considered underutilized

# Select the subscription
Select-AzSubscription -SubscriptionId $subscriptionId

# Get all VMs within the subscription
$vms = Get-AzVM 

# Iterate through each VM
foreach ($vm in $vms) {
    $vmName = $vm.Name
    $resourceGroupName = $vm.ResourceGroupName

    # Get performance metrics for the VM 
    $startTime = (Get-Date).AddDays(-$daysToLookBack)
    $endTime = Get-Date

    $cpuMetrics = Get-AzMetric -ResourceId $vm.Id -MetricName "Percentage CPU" -StartTime $startTime -EndTime $endTime
    $networkOutMetrics = Get-AzMetric -ResourceId $vm.Id -MetricName "Network Out Total" -StartTime $startTime -EndTime $endTime

    # Calculate average CPU and Network Utilization
    $avgCpuUtilization = $cpuMetrics.Data.Average
    $avgNetworkOut = $networkOutMetrics.Data.Average 

    # If VM falls below thresholds, provide recommendations
    if ($avgCpuUtilization -le $cpuUtilizationThreshold -and $avgNetworkOut -le $networkUtilizationThreshold) {
        Write-Output "$vmName in Resource Group $resourceGroupName is a potential candidate for optimization."
        Write-Output "  - Average CPU Utilization: $avgCpuUtilization%"
        Write-Output "  - Average Network Out: $avgNetworkOut Bytes"
        Write-Output "  - Consider downsizing or deallocating if the trend persists."
        Write-Output "-------------------------"
    }    
}
