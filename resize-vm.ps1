####################################################
#                                                  #
# File: resize-vm-v1.0                             #
# Steven Rhoods <steven.rhoods@rms.com>            #
#                                                  #
# Resizes Azure VM's.                              #
#                                                  #
####################################################

param(
	[Parameter(Mandatory=$True)]
	[string[]]$VMs,					#Names of Windows VMs to resize in Azure
	
	[Parameter(Mandatory=$True)]
	[string]$resourceGroupName,		#Resource group name of VMs

	[Parameter(Mandatory=$True)]
	[string]$newVMSize,				#New instance size in Azure

	[Parameter(Mandatory=$True)]	
	[string]$subscriptionId			#Azure SubscriptionId to use for the deployment
)

# end of custom variables

$sub = Get-AzureRmSubscription|? SubscriptionId -eq $subscriptionId
if(-not $sub) {  
    Write-Verbose ("Specified subscription does not exist, please verify and try again.")
	throw "Unable to select Subscription: " + $subscriptionId + " cannot continue."	# Throw an error if the specified sub does not exist
}

# Switch subscription
$sub = Select-AzureRmSubscription -SubscriptionId $subscriptionId

clear
Write ("Resizing VM's in Subscription: " + $sub.Subscription.SubscriptionName + " (" + $sub.Subscription.SubscriptionId + ")")
Write ("")

Write ("Resizing VMs to: " + $newVMSize)
Write ("")
foreach ($name in $VMs){
	Write ("Resizing VM: " + $name)

	$vm = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $name
	$vm.HardwareProfile.vmSize = $newVMSize
	$result = Update-AzureRmVM -ResourceGroupName $resourceGroupName -VM $vm

	if($result.StatusCode -eq 'OK') {  
		Write ("VM named " + $name + " has been resized.`n")
	} else {
		Write-Error 'VM was not resized successfully.'	#Display error if VM wasn't provisioned successfully.
	}
	Write-Host
}