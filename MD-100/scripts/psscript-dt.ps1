Param (
    [Parameter(Mandatory = $true)]
    [string]
    $DeploymentID,

    [string]
    $resourceGroup,

    [string]
    $location,

    [string]
    $AzureTenantID,

    [string]
    $adminPassword,

    [string]
    $AzureUserName,

    [string]
    $AzurePassword

)

[Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls" 


#Deploying VM image VM

$applicationId = 'f2e55764-1c5e-42b9-b154-8107aa7df5cc'
$secret = 'tIx8Q~r8hjFqMlxhvu7rDcfgNvtTgcqjjKKl1aqo' | ConvertTo-SecureString -AsPlainText -Force
$tenant1 = "0f69441c-29e3-4293-9c7a-c6b8ec38e66e"
$tenant2 = $AzureTenantID
$cred = New-Object -TypeName PSCredential -ArgumentList $applicationId, $secret
#Clear-AzContext
Login-AzAccount -ServicePrincipal -Credential $cred  -Tenant $tenant1
Select-AzSubscription -Subscription e2ee6274-c6e3-4df1-b3d2-79107c10f7b0
Login-AzAccount -ServicePrincipal -Credential $cred -Tenant $tenant2

$DNS = "vm" + $DeploymentID

$vmName = "VM" + $DeploymentID

$imageDefinitionID = "/subscriptions/e2ee6274-c6e3-4df1-b3d2-79107c10f7b0/resourceGroups/cloudlab-mgmt/providers/Microsoft.Compute/galleries/mocImageGallery/images/az-400-image/versions/1.0.2"

$subnetConfig = New-AzVirtualNetworkSubnetConfig `
   -Name default `
   -AddressPrefix 10.0.0.0/24

$vnet = New-AzVirtualNetwork `
   -ResourceGroupName $resourceGroup `
   -Location $location `
   -Name vNet `
   -AddressPrefix 10.0.0.0/16 `
   -Subnet $subnetConfig

$pip = New-AzPublicIpAddress `
   -ResourceGroupName $resourceGroup `
   -Location $location `
  -Name vm-pip `
  -AllocationMethod Static `
  -IdleTimeoutInMinutes 4 `
  -DomainNameLabel $DNS

$nsgRuleRDP = New-AzNetworkSecurityRuleConfig `
   -Name myNetworkSecurityGroupRuleRDP  `
   -Protocol Tcp `
   -Direction Inbound `
   -Priority 1000 `
   -SourceAddressPrefix * `
   -SourcePortRange * `
   -DestinationAddressPrefix * `
   -DestinationPortRange 3389 -Access Allow

$nsg = New-AzNetworkSecurityGroup `
   -ResourceGroupName $resourceGroup `
   -Location $location `
   -Name vm-nsg `
   -SecurityRules $nsgRuleRDP

$nic = New-AzNetworkInterface `
   -Name vm-nic `
   -ResourceGroupName $resourceGroup `
   -Location $location `
  -SubnetId $vnet.Subnets[0].Id `
  -PublicIpAddressId $pip.Id `
  -NetworkSecurityGroupId $nsg.Id


  $vmConfig = New-AzVMConfig `
   -VMName $vmName `
   -VMSize Standard_B2s  | `
   Set-AzVMSourceImage -Id $imageDefinitionId | `
   Add-AzVMNetworkInterface -Id $nic.Id

# Create a virtual machine
New-AzVM `
-ResourceGroupName $resourceGroup `
-Location $location `
-VM $vmConfig

Start-Sleep 30
