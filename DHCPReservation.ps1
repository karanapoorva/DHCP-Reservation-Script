#DHCP Reservation
cls

#Validate if IP Helper is active or not
$IPhelper  = Read-Host "Enter IP Helper Address"

#Scopefinder
function IsIpAddressInRange {
  param(
    [System.Version] $IPAddress,
    [System.Version] $FromAddress,
    [System.Version] $ToAddress
  )
  $FromAddress -le $IPAddress -and $IPAddress -le $ToAddress
}

$Ip = Read-Host "Please provide the IP Address for reservation "
$Scoids = Get-DhcpServerv4Scope -ComputerName $ServerName

foreach($scoid in $Scoids)
{

$start = $scoid.startRange
$End = $scoid.EndRange
$Scope = $scoid.ScopeId
$result = IsIpAddressInRange $IP $start.IPAddressToString $End.IPAddressToString
if ($result -eq $true){$Scopeid = $Scope.IPAddressToString}
}

Write-Host "Scope Id is $Scopeid"

$ServerName = (Resolve-DnsName $IPhelper| select NameHost).NameHost
Write-Host "Checking if $ServerName is primary server..."

$ServerRole = (Get-DhcpServerv4Failover -ComputerName $ServerName -ScopeId $Scopeid| select ServerRole).ServerRole

If($serverRole -eq "Active"){
Write-host "$serverName is $ServerRole server for mentioned gateway"
}elseIf($ServerRole -eq "Standby"){
Write-Host "$serverName is $ServerRole Server for Menitoned Gateway"}
else{ Write-Host "Either $Gateway is not found or Server is Windows 2008"}

#MAC Address validation
$MacAddress = Read-Host "Enter the MAC Address"

$Result = Get-DhcpServerv4reservation -ComputerName $ServerName -ScopeId $Scopeid -ClientID “$MacAddress” -ErrorAction Ignore

if($Result -ne $null)
{ Write-Host "Reservation already exists" }
else {Write-Host "MAC Address is available for reservation"}

Write-Host "Do you want to proceed with IP reservation (Y/N) ?"
$response = read-host

if ( $response -ne "Y" ) { exit }
$desc = Read-Host "Please provide the Description/Task Number "
$hostname = Read-Host "Please provide the Host Name "

do{
$Failed = $false
try {

$ReservedIP = Add-DhcpServerv4Reservation -ComputerName $ServerName -ScopeId $Scopeid -ClientId $MacAddress -IPAddress $Ip -Description $desc -Name $hostname -ErrorAction Stop
sleep 2
Invoke-DhcpServerv4FailoverReplication -ComputerName $ServerName -ScopeId $Scopeid -confirm:$false

$output = Get-DhcpServerv4reservation -ComputerName $ServerName -ScopeId $Scopeid -ClientID $MacAddress
$output

} catch {
Write-Host "An error has occurred while trying to add a reservation for '$MacAddress' with IP '$Ip'. Kindly do manually."
}
} while ($Failed)




