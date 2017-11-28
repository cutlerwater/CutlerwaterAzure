<#
	.SYNOPSIS 
        Start or Stop all WebApps (Websites) in your subscription.

	.DESCRIPTION
        Runbook which allows you to start/stop all WebApps (Websites) in your subscription.

    .PARAMETER Stop
        If set to true: stop the WebApps (Websites). Otherwise start the WebApps (Websites)

    .PARAMETER CredentialAssetName
        The name of a working AutomationPSCredential
		
	.NOTES
        AUTHOR: Carlos Mendible
        LASTEDIT: June 2, 2016
#>
Workflow Stop-Start-All-WebApps 
{
	# Parameters
	Param(
		[Parameter (Mandatory= $true)]
	    [bool]$Stop,
		
		[Parameter (Mandatory= $true)]
		[string]$CredentialAssetName
	   )  
	   
	#The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    $CredentialAssetName = $CredentialAssetName;
	
	#Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }

    #Connect to your Azure Account   	
	Add-AzureRmAccount -Credential $Cred
	Add-AzureAccount -Credential $Cred
	
	$status = 'Stopped'
	if ($Stop)
	{
		$status = 'Running'
	}

	# Get Running WebApps (Websites)
	$websites = Get-AzureWebsite | where-object -FilterScript{$_.state -eq $status }
	
	foreach -parallel ($website In $websites)
	{
		if ($Stop)
		{
			$result = Stop-AzureWebsite $website.Name
			if($result)
			{
				Write-Output "- $($website.Name) did not shutdown successfully"
			}
			else
			{
				Write-Output "+ $($website.Name) shutdown successfully"
			}
		}
		else
		{
			$result = Start-AzureWebsite $website.Name
			if($result)
			{
				Write-Output "- $($website.Name) did not start successfully"
			}
			else
			{
				Write-Output "+ $($website.Name) started successfully"
			}
		} 
	}	
}