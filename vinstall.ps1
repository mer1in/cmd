vim --version 2>&1 | out-null
$vim = !$?
python --version 2>&1 | out-null
$python = !$?
choco --version 2>&1 | out-null
$choco = !$?

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	if ($choco)
	{
		# blindly trust chockolatey
		iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	}
	if ($python)
	{
		choco install -y python --version=3.6.8
	}
	# get latest by always upgrade
	choco install -y vim git git-lfs googlechrome
	choco upgrade -y vim git git-lfs googlechrome
}else{
	# Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList "-NoExit","-Command", "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass ; $($MyInvocation.MyCommand.Source)"
    Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList "-Command", "$($MyInvocation.MyCommand.Source)"
}

