param(
	[Parameter(Mandatory=$True)]
	[string]$VMname,

	[Parameter(Mandatory=$True)]
	[string]$RGname,

	[Parameter(Mandatory=$True)]
	[string]$StorageURI
	
)

$Host.UI.RawUI.BackgroundColor = ($bckgrnd = 'Black')

$DiskSizeGB = 125
$NumberofDisks = 8
$StartingLUN = 1

$VMObject =  Get-AzureRmVM -ResourceGroupName $RGName -Name $VMname

if($VMObject){
	For($i = 1; $i -le $NumberofDisks; $i++){

		Add-AzureRmVMDataDisk -VM $VMObject -Name ($VMObject.Name + "-DD" + $i) -VhdUri ($StorageURI + $VMname + "_datadisk" + $i + ".vhd") -Caching ReadWrite -DiskSizeInGB $DiskSizeGB -Lun $StartingLUN -CreateOption Empty
		$StartingLUN = $StartingLUN + 1
	}
	Update-AzureRmVM -VM $VMObject -ResourceGroupName $RGName
}else{
	Write-Host "VM Not Found - aborting"
}