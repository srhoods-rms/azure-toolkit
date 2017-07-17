####################################################
#                                                  #
# File: stop-vm-v1.0                               #
# Steven Rhoods <steven.rhoods@rms.com>            #
#                                                  #
# Stop and deallocate a selection of VMs           #
#                                                  #
####################################################

param(
	[Parameter(Mandatory=$True)]
	[string[]]$VMs,						#Names of Windows VMs to stop in Azure
	
	[Parameter(Mandatory=$True)]
	[string]$resourceGroupName,			#Resource group name of VMs
	
	[Parameter(Mandatory=$True)]
	[string]$subscriptionId				#Azure SubscriptionId to use for the deployment
)

# end of custom variables

$sub = Get-AzureRmSubscription|? SubscriptionId -eq $subscriptionId
if(-not $sub) {  
    Write-Verbose ("Specified subscription does not exist, please verify and try again.")
	throw "Unable to select Subscription: " + $subscriptionId + " cannot continue."	# Throw an error if the specified sub does not exist
}

#Switch subscription
$sub = Select-AzureRmSubscription -SubscriptionId $subscriptionId

clear
Write ("Stopping VM's in Subscription: " + $sub.Subscription.SubscriptionName + " (" + $sub.Subscription.SubscriptionId + ")")
Write ("")

foreach ($name in $VMs){
	Write ('Stopping: ' + $name)

	$result = Stop-AzureRmVM -ResourceGroupName $resourceGroupName -Name $name -Force

	if($result.Status -eq 'Succeeded') {  
		Write ("VM named " + $name + " was stopped and deallocated.")
	} else {
		Write-Error 'VM was not stopped successfully.'	#Display error if VM wasn't stopped successfully.
	}
	Write ("")
}