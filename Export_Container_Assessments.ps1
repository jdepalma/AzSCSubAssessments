[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$Subscription,
	[Parameter(Mandatory = $true)]
    [string]$FileName
	)



Function Export-Container-Assessments($subscription ,$filename) {

$context = Get-AzContext
$profile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($profile)
$token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
$authHeader = @{
	'Content-Type'  = 'application/json' 
	'Authorization' = 'Bearer ' + $token.AccessToken 
    }
	
	
$url = "https://management.azure.com/subscriptions/$($subscription)/providers/Microsoft.Security/subAssessments?api-version=2019-01-01-preview"


$values = (Invoke-RestMethod -Method "Get" -Uri $url -Headers $authHeader )
$results = $values.value
$NextLink = $values.nextLink

foreach ($result in $results){
#$decription = $result.properties.Description
$id = $result.properties.id
$severity = $result.properties.status.severity
$remediation = $result.properties.remediation
$displayName = $result.properties.displayName
$impact = $result.properties.impact
$category = $result.properties.category
$imageDigest = $result.properties.additionalData.imageDigest
$repositoryName = $result.properties.additionalData.repositoryName
$type = $result.properties.additionalData.type
[pscustomobject]@{ id = $id; severity =  $severity; remediation = $remediation; displayName = $displayName; impact = $impact; category = $category; imageDigest = $imageDigest; repositoryName = $repositoryName; type = $type } | Export-Csv $filename -Append -NoTypeInformation
}


While ($NextLink -ne $Null){
    $values = (Invoke-RestMethod -Method "Get" -Uri $NextLink -Headers $authHeader )
	$results = $values.value
	$NextLink = $values.nextLink
	
	foreach ($result in $results){
		#$decription = $result.properties.Description
		$id = $result.properties.id
		$severity = $result.properties.status.severity
		$remediation = $result.properties.remediation
		$displayName = $result.properties.displayName
		$impact = $result.properties.impact
		$category = $result.properties.category
		$imageDigest = $result.properties.additionalData.imageDigest
		$repositoryName = $result.properties.additionalData.repositoryName
		$type = $result.properties.additionalData.type
		[pscustomobject]@{ id = $id; severity =  $severity; remediation = $remediation; displayName = $displayName; impact = $impact; category = $category; imageDigest = $imageDigest; repositoryName = $repositoryName; type = $type } | Export-Csv $filename -Append -NoTypeInformation
}
	}


echo "Done"

}

Export-Container-Assessments $Subscription $FileName

