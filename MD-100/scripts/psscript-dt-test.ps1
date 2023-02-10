Param (
    [Parameter(Mandatory = $true)]
    [string]
    $adminUsername,

    [string]
    $adminPassword
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#Reset VM password to update it to random password, it is a custom image based VM
net user $adminUsername $adminPassword

sleep 5
