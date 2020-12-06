# $uriToBeTested = New-Object System.Collections.ArrayList
# $uriToBeTested.Add('http://localhost')  #Client
# $uriToBeTested.Add('http://localhost:5001')  #identity
# $uriToBeTested.Add('http://localhost:5002')  #dealers
# $uriToBeTested.Add('http://localhost:5003')  #statistics
# $uriToBeTested.Add('http://localhost:5004')  #notifications
# $uriToBeTested.Add('http://localhost:5000')  #admin
# $uriToBeTested.Add('http://localhost:5500/healthchecks') #watchdog

$uriToBeTested = @("http://localhost", #Client
					#"http://localhost:5001", #identity
					#"http://localhost:5002", #dealers
					"http://localhost/dealers",
					#"http://localhost:5003", #statistics
					#"http://localhost:5004", #notifications
					"http://localhost:5000", #admin
					"http://localhost:5500/healthchecks") #watchdog

$problematicUris = @()

For ($i=0; $i -lt $uriToBeTested.Length; $i++) 
{
	$started = $false	
	$count = 0
	do 
	{
		$count++
		
		Try
		{
			$testStart = Invoke-WebRequest -Uri $uriToBeTested[$i] -UseBasicParsing		
		
			if ($testStart.statuscode -eq '200') 
			{
				Write-Output "Successfull statuscode on [Attempt: $count]"
				$started = $true
			} 
		}
		Catch
		{
			Start-Sleep -Seconds 1
		}	
	} until ($started -or ($count -eq 3))
	
	if(!$started)
	{
		#$problematicUris.Add($uriToBeTested[$i])
		$problematicUris += $uriToBeTested[$i]
	}	
}					
 
if ($problematicUris.Count -gt 0) 
{
	Write-Output "Problem found in:"
	For ($k=0; $k -le $problematicUris.Length; $k++) 
	{
		Write-Output $problematicUris[$k]
	}
    exit 1
}
else
{
	Write-Output "Test is successful"
}
