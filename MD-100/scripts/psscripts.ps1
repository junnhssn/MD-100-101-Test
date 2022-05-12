Param (
    [Parameter(Mandatory = $true)]
    [string]
    $AzureUserName,

    [string]
    $AzurePassword,

    [string]
    $AzureTenantID,

    [string]
    $AzureSubscriptionID,

    [string]
    $ODLID,

    [string]
    $InstallCloudLabsShadow,

    [string]
    $vmAdminUsername,

    [string]
    $trainerUserName,

    [string]
    $trainerUserPassword
)

Start-Transcript -Path C:\WindowsAzure\Logs\CloudLabsCustomScriptExtension.txt -Append
[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 

#Import Common Functions
$path = pwd
$path=$path.Path
$commonscriptpath = "$path" + "\cloudlabs-common\cloudlabs-windows-functions.ps1"
. $commonscriptpath

# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
#InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow

#Download and Install PowerBi Desktop
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup_x64.exe","C:\Packages\PBIDesktop_x64.exe")
$filetocheck= "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
if(!(Test-Path $filetocheck -PathType leaf))
{
 Write-Output "Powerbi is not installed, Installing it"
 Start-Process -FilePath "C:\Packages\PBIDesktop_x64.exe" -ArgumentList '-quiet','ACCEPT_EULA=1' -Wait
}


InstallAzPowerShellModule
InstallAzCLI
InstallEdgeChromium


Enable-CloudLabsEmbeddedShadow azureuser trainer Password.1!!

sleep 5
