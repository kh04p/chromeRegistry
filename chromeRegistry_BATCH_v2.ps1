function updateRegistry {
	param([string]$computer)

	if (!(Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
        Write-Warning "Computer $computer cannot be reached."
        return
    }
	
	try {
		Enter-PSSession -ComputerName $computer -ErrorAction Stop | Out-Null
	} catch {
		Write-Host "Unable to remote connect with $computer. Please check if computer is online."
	}
	

	$registryPath = 'Registry::HKEY_CLASSES_ROOT\ChromeHTML\shell\open\command'
	$name = '(Default)'
	$value = '"C:\Program Files\Google\Chrome\Application\chrome.exe" -- %1"'

	#If registry path does not exist, create it.
	if (-not (Test-Path $registryPath)) {
		New-Item -Path $registryPath -Force | Out-Null
	}

	#Updates registry.
	try {
		New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType String -Force -ErrorAction Stop | Out-Null
		#Write-Host "Successfully updated registry on $computer."
	} catch {
		Write-Host "Unable to update registry on computer $computer."
		Exit-PSSession
		exit
	}

	Exit-PSSession

	#Checks registry again.
	$regVerify = Invoke-Command -ComputerName $computer {Get-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\ChromeHTML\shell\open\command' -Name '(Default)'} | select '(Default)'
	Write-Host "$computer -> $regVerify"
}

#Gets computer names from list inside same directory.
$computerList = Get-Content -Path $PSScriptRoot\chromeList.txt -Force

foreach($computer in $computerList) {
	updateRegistry -computer $computer
}