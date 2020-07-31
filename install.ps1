(New-Object System.Net.WebClient).DownloadString('https://github.com/mer1in/v/raw/master/install.ps1') > $env:TEMP\vinstall.ps1
Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList "-NoExit", "-Command", "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass ; $env:TEMP\vistall.ps1"
