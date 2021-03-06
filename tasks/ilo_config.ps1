[CmdletBinding()]
Param(
  [Parameter(Mandatory = $False)]
  [String]
  $serverName = $env:PT_servername,
  $password = $env:PT_pw,
  $newpassword = $env:PT_newpw
)

#$serverName = "" 
#$password = ""
#$newpassword = ""

#0 = FE, 1 = ESA, 2 = RTS
$userContext1Array = "OU=Users,OU=Admin,OU=Privileged,OU=FE,DC=fenetwork,DC=com"

$userContext2Array = "OU=Users,OU=ADMIN,DC=fenetwork,DC=com"

$group1NameArray = "CN=GS-Admin-ServerAdmins,OU=ADMIN,DC=fenetwork,DC=com"

$group2NameArray = "CN=gs-esmadm,OU=SecGrps,OU=FE,DC=fenetwork,DC=com"

$group3NameArray = "CN=gs-snocadm,OU=SecGrps,OU=FE,DC=fenetwork,DC=com"


#Main Function  
#$password = $password
#Convert SecString to RegString
#$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
#$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)


$defaultDomain = "fenetwork.com"
$domainToUse = $defaultDomain
#$domainToUse = ($defaultDomain, $domainToUse)[[bool]$domainToUse]
#Write-Host $domainToUse


$IP = Get-HPiLOServerInfo -Server $serverName -username Administrator `
 -password $password -DisableCertificateAuthentication  
 Select-Object IP -ExpandProperty IP
  

$Info = Get-HPiLOFirmwareInfo -Server $serverName -username Administrator -password $password -DisableCertificateAuthentication -OutputType XML

Write-Host $Info

Write-Host $IP `
#Get-HPiLOLicense -Server $IP -username Administrator -password $password `
# -DisableCertificateAuthentication | Select-Object LICENSE_KEY `
# -ExpandProperty LICENSE_KEY

Set-HPiLODirectory -Server $IP -username Administrator `
 -password $password -DisableCertificateAuthentication `
 -ServerAddress $domainToUse `
 -UserContext1 $userContext1Array `
 -UserContext2 $userContext2Array `
 -LDAPDirectoryAuthentication Use_Directory_Default_Schema `

#iLO 5s have additional Permissions but no module support yet
Set-HPiLOSchemalessDirectory -Server $IP -username Administrator `
 -password $password `
 -DisableCertificateAuthentication `
  -Group1Name $group1NameArray `
  -Group1Priv "1,2,3,4,5,6" `
  -Group2Name $group2NameArray `
  -Group2Priv "1,2,3,4,5,6" `
  -Group3Name $group3NameArray `
  -Group3Priv "1,2,3" `

#Get-HPiLODirectory -Server $IP -Username Administrator `
#-password $password -DisableCertificateAuthentication 

Set-HPiLOUser -Server $IP -Username Administrator -password $password `
 -DisableCertificateAuthentication -UserLoginToEdit Administrator -Newpassword $newpassword

#Write-Host "Complete"
#Add-HPiLOUser -Server $IP -username Administrator -password $password -DisableCertificateAuthentication -NewUsername Adbert -NewUserLogin Adbert -Newpassword $newpassword -AdminPriv Yes -RemoteConsPriv Yes -ResetServerPriv Yes -VirtualMediaPriv Yes -ConfigILOPriv Yes
#Remove-HPiLOUser -Server $IP -username Adbert -password $newpassword -DisableCertificateAuthentication -RemoveUserLogin Administrator
#Get-HPiLONetworkSetting -Server $IP -username Adbert -password $newpassword -DisableCertificateAuthentication | Select-Object DNS_NAME -ExpandProperty DNS_NAME
#$DNSName = Read-Host 'What is the new ILO DNS Name?'
#Set-HPiLONetworkSetting -Server $IP -Username Adbert -password $newpassword -DisableCertificateAuthentication -DNSName $DNSName
#Get-HPiLONetworkSetting -Server $IP -username Adbert -password $newpassword -DisableCertificateAuthentication | Select-Object DNS_NAME -ExpandProperty DNS_NAME

Write-Host "Done"

