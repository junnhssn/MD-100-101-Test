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

Function InstallEdgeChromiumupdated
{
    #Download and Install edge
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/59c478d3-513a-4060-837b-01ad385d6aaa/MicrosoftEdgeEnterpriseX86.msi","C:\Packages\MicrosoftEdgeEnterpriseX86.msi")
    sleep 5
    
    Start-Process msiexec.exe -Wait '/I C:\Packages\MicrosoftEdgeEnterpriseX86.msi /qn' -Verbose 
    sleep 5
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\Azure Portal.lnk")
    $Shortcut.TargetPath = """C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"""
    $argA = """https://portal.azure.com"""
    $Shortcut.Arguments = $argA 
    $Shortcut.Save()

}

# Run Imported functions from cloudlabs-windows-functions.ps1
WindowsServerCommon
#InstallCloudLabsShadow $ODLID $InstallCloudLabsShadow

WindowsServerCommon

InstallAzPowerShellModule
InstallAzCLI
InstallEdgeChromiumupdated

Enable-CloudLabsEmbeddedShadow azureuser trainer Password.1!!

sleep 5


#Download git repository
New-Item -ItemType directory -Path C:\AllFiles
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://github.com/MicrosoftLearning/MD-100T00-Windows10/archive/refs/heads/master.zip","C:\AllFiles\AllFiles.zip")
#unziping folder
function Expand-ZIPFile($file, $destination)
{
$shell = new-object -com shell.application
$zip = $shell.NameSpace($file)
foreach($item in $zip.items())
{
$shell.Namespace($destination).copyhere($item)
}
}
Expand-ZIPFile -File "C:\AllFiles\AllFiles.zip" -Destination "C:\AllFiles\" 

#creating directories 
New-Item -ItemType directory -Path C:\labFiles
New-Item -ItemType directory -Path C:\temp
New-Item -ItemType directory -Path c:\ADK

#Download and installing ADK
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://download.microsoft.com/download/8/6/c/86c218f3-4349-4aa5-beba-d05e48bbc286/adk/adksetup.exe","C:\LabFiles\adksetup.exe")
Start-Process -FilePath "C:\LabFiles\adksetup.exe" -ArgumentList '/quiet /layout c:\temp\ADKoffline'
Start-Process -FilePath "C:\temp\ADKoffline\adksetup.exe" -ArgumentList '/installpath c:\ADK'


#Download and installing ADKwinPE 
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://download.microsoft.com/download/3/c/2/3c2b23b2-96a0-452c-b9fd-6df72266e335/adkwinpeaddons/adkwinpesetup.exe","C:\LabFiles\adkwinpesetup.exe")
Start-Process -FilePath "C:\LabFiles\adkwinpesetup.exe" -ArgumentList '/quiet /layout c:\temp\ADKWINPE'
Start-Process -FilePath "C:\temp\ADKWINPE\adkwinpesetup" -ArgumentList '/quiet /installpath c:\ADK'
