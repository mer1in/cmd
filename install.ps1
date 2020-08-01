(New-Object System.Net.WebClient).DownloadString('https://github.com/mer1in/v/raw/master/vinstall.ps1') > $env:TEMP\vinstall.ps1
Start-Process "$psHome\powershell.exe" -ArgumentList "-NoExit", "-Command", "$env:TEMP\vinstall.ps1"
