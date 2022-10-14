cls
function IsIpAddressInRange {
  param(
    [System.Version] $IPAddress,
    [System.Version] $FromAddress,
    [System.Version] $ToAddress
  )
  $FromAddress -le $IPAddress -and $IPAddress -le $ToAddress
}
$IP = "10.255.122.15"
$Scopeids = Get-DhcpServerv4Scope -ComputerName nlnhsrk-dhcp01.aptiv.com

foreach($scopeid in $Scopeids)
{

$start = $scopeid.startRange
$End = $scopeid.EndRange
$Scope = $scopeid.ScopeId
$result = IsIpAddressInRange $IP $start.IPAddressToString $End.IPAddressToString
if ($result -eq $true){$Scope.IPAddressToString}
}



