####################################################
#                                                  #
# File: export-vmsto-json-v1.2                     #
# Steven Rhoods <steven.rhoods@rms.com>            #
#                                                  #
# Exports config data for all VMs in the current   #
# subscription to the folder specified.            #
#                                                  #
####################################################

param(
	[Parameter(Mandatory=$True)]
	[string]$exportPath,				# Folder used to jump JSON files, include trailing '\' e.g. C:\TEMP\
	
	[Parameter(Mandatory=$True)]
	[string]$subscriptionId				# Azure SubscriptionId to use for the deployment
)

# end of custom variables

if (-not $exportPath.EndsWith("\")){ $exportPath = $exportPath + "\" }	# Adds a (\) onto the export path if it doesn't already exist

$sub = Get-AzureRmSubscription|? SubscriptionId -eq $subscriptionId
if(-not $sub) {  
    Write-Verbose ("Specified subscription does not exist or you do not have access to it, please verify and try again.")
	throw "Unable to select Subscription: " + $subscriptionId + " cannot continue."	# Throw an error if the specified sub does not exist
}

# Switch subscription
$sub = Select-AzureRmSubscription -SubscriptionId $subscriptionId

clear
Write ("Exporting VM info from Subscription: " + $sub.Subscription.SubscriptionName + " (" + $sub.Subscription.SubscriptionId + ")`n")
#Write ("")
Write-Verbose "Getting List of VMs to Export"

$VMs = Get-AzureRmVM|SELECT Name,Location,ResourceGroupName

for ($i=0;$i -lt $VMs.Count ; $i++ ){	# Requires more than 1 VM in a subscription for the script to fire.
	Write-Progress -Activity "Exporting JSON Data" -status $VMs[$i].Name -percentComplete (($i+1) / ($VMs.Count+1)*100)
	$filename = $VMs[$i].Location + '-' + $VMs[$i].ResourceGroupName + '-' + $VMs[$i].Name + '.json'
	$vm = Get-AzureRmVM -ResourceGroupName $VMs[$i].ResourceGroupName -Name $VMs[$i].Name
	ConvertTo-Json -InputObject $vm -Depth 100 | Out-File -FilePath ($exportPath+$filename.ToLower())
}
Write ("Export to " + $exportPath + " completed, "+$VMs.Count+" JSON files created.`n")