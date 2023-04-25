function inputPrompt {
	param (
		$title,
		$prompt
	)

	[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

	$value = [Microsoft.VisualBasic.Interaction]::InputBox($prompt, $title)

	return $value
}

$computer = inputPrompt -title "CHROME REGISTRY FIX" -prompt "Please enter a computer name: "

$s = New-PSSession -ComputerName $computer
Enter-PSSession -Session $s

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
Invoke-Command -ComputerName $computer {Get-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\ChromeHTML\shell\open\command' -Name '(Default)'} | select '(Default)'