
# Install and enable OpenSSH server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service sshd -StartupType Automatic


Start-Service sshd

# Ajouter un commande de print ("verifiez que la règle existe")
Get-NetFirewallRule -Name *ssh*

# Ajouter un commande de print ("verifiez quele port 22 est écouté")
netstat -aon | findstr -i listen | findstr 22


iwr -useb https://raw.githubusercontent.com/filebrowser/get/master/get.ps1 | iex
New-NetFirewallRule -Name filebrowser -DisplayName 'Filebrowser Server (filebrowser)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 8080

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$params = @{
  Name = "filebrowser"
  BinaryPathName = '"C:\Program Files\filebrowser\filebrowser.exe -a 0.0.0.0 -r C:\Users\Administrator"'
  DisplayName = "filebrowser"
  StartupType = "Automatic"
  Description = "Filebrowsing web application"
}

New-Service @params

