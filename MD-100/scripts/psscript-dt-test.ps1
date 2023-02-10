Param (
    [Parameter(Mandatory = $true)]
    [string]
    $adminUsername,

    [string]
    $adminPassword
)

[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 
Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append

#Reset VM password to update it to random password, it is a custom image based VM
net user $adminUsername $adminPassword
