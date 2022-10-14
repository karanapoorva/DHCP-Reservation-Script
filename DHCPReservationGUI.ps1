#region prereqs
[reflection.assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
Add-Type -AssemblyName PresentationFramework

$DHCPMenu = New-Object System.Windows.Forms.form
$DHCPMenu.Text = "DHCP Reservation"
$DHCPMenu.Size = '800,550'

# Label Box

$IPHelperLabel = New-Object System.Windows.Forms.Label
$IPHelperLabel.Location = '50,30'
$IPHelperLabel.Size = '250,30'
$IPHelperLabel.Text = "Enter IP Helper Address :"

$DHCPMenu.Controls.Add($IPHelperLabel)

$IPAddressLabel = New-Object System.Windows.Forms.Label
$IPAddressLabel.Location = '50,70'
$IPAddressLabel.Size = '250,30'
$IPAddressLabel.Text = "Enter the IP Address :"

$DHCPMenu.Controls.Add($IPAddressLabel)

$ServerRoleLabel = New-Object System.Windows.Forms.Label
$ServerRoleLabel.Location = '50,150'
$ServerRoleLabel.Size = '250,30'
$ServerRoleLabel.Text = "Server Role is :"

$DHCPMenu.Controls.Add($ServerRoleLabel)

$ScopeIdLabel = New-Object System.Windows.Forms.Label
$ScopeIdLabel.Location = '50,190'
$ScopeIdLabel.Size = '250,30'
$ScopeIdLabel.Text = "Scope ID is :"

$DHCPMenu.Controls.Add($ScopeIdLabel)

$MACLabel = New-Object System.Windows.Forms.Label
$MACLabel.Location = '50,230'
$MACLabel.Size = '250,30'
$MACLabel.Text = "Enter The MAC Address :"

$DHCPMenu.Controls.Add($MACLabel)

$TASKLabel = New-Object System.Windows.Forms.Label
$TASKLabel.Location = '50,320'
$TASKLabel.Size = '300,30'
$TASKLabel.Text = "Enter the Task Number :"

$DHCPMenu.Controls.Add($TASKLabel)

$HostLabel = New-Object System.Windows.Forms.Label
$HostLabel.Location = '50,360'
$HostLabel.Size = '300,30'
$HostLabel.Text = "Enter the Hostname :"

$DHCPMenu.Controls.Add($HostLabel)

#Text Box

$IPHelperTbox = New-Object System.Windows.Forms.TextBox
$IPHelperTbox.Location = '400,30'
$IPHelperTbox.Size = '250,30'

$DHCPMenu.Controls.Add($IPHelperTbox)

$IPAddressTbox = New-Object System.Windows.Forms.TextBox
$IPAddressTbox.Location = '400,70'
$IPAddressTbox.Size = '250,30'

$DHCPMenu.Controls.Add($IPAddressTbox)

$IPActiveLabel = New-Object System.Windows.Forms.Label
$IPActiveLabel.Location = '400,50'
$IPActiveLabel.AutoSize = $true

$DHCPMenu.Controls.Add($IPActiveLabel)


$IPvalLabel = New-Object System.Windows.Forms.Label
$IPvalLabel.Location = '660,70'
$IPvalLabel.AutoSize = $true


$DHCPMenu.Controls.Add($IPvalLabel)

$ServerRoleTbox = New-Object System.Windows.Forms.TextBox
$ServerRoleTbox.Location = '400,150'
$ServerRoleTbox.Size = '250,30'

$DHCPMenu.Controls.Add($ServerRoleTbox)

$ScopeIDTbox = New-Object System.Windows.Forms.TextBox
$ScopeIDTbox.Location = '400,190'
$ScopeIDTbox.Size = '250,30'

$DHCPMenu.Controls.Add($ScopeIDTbox)

$MACTbox = New-Object System.Windows.Forms.TextBox
$MACTbox.Location = '400,230'
$MACTbox.Size = '250,30'

$DHCPMenu.Controls.Add($MACTbox)

$TaskTBox = New-Object System.Windows.Forms.TextBox
$TaskTBox.Location = '400,320'
$TaskTBox.Size = '250,30'

$DHCPMenu.Controls.Add($TaskTBox)

$HostTbox = New-Object System.Windows.Forms.TextBox
$HostTbox.Location = '400,360'
$HostTbox.Size = '250,30'

$DHCPMenu.Controls.Add($HostTbox)

$SFbutton = New-Object System.Windows.Forms.Button
$okbutton = New-Object System.Windows.Forms.Button
$cancelbutton = New-Object System.Windows.Forms.Button
$validatebutton = New-Object System.Windows.Forms.Button
$resetbutton = New-Object System.Windows.Forms.Button

$SFbutton.Text = 'Click To check server role and Find Scope'
$SFbutton.Location = '50,110'
$SFbutton.Width = 600
$SFbutton.BackColor = 'Orange'

$resetbutton.Text = 'Reset'
$resetbutton.Location = '365,410'
$resetbutton.Width = 80

$validatebutton.Text = 'Validate'
$validatebutton.Location = '400,270'
$validatebutton.Width = 80

$okbutton.Text = 'ok'
$okbutton.Location = '470,410'

$cancelbutton.Text = 'cancel'
$cancelbutton.Location = '575,410'

$DHCPMenu.Controls.Add($SFbutton)
$DHCPMenu.Controls.Add($resetbutton)
$DHCPMenu.Controls.Add($validatebutton)
$DHCPMenu.Controls.Add($okbutton)
$DHCPMenu.Controls.Add($cancelbutton)

$MACValLabel = New-Object System.Windows.Forms.Label
$MACValLabel.Location = '660,230'
$MACValLabel.AutoSize = $true
$DHCPMenu.Controls.Add($MACValLabel)

#Logic

$SFbutton.add_click({

$ServerName = (Resolve-DnsName $IPHelperTbox.Text| select NameHost).NameHost
$Scoids = Get-DhcpServerv4Scope -ComputerName $ServerName -ErrorAction Ignore

function IsIpAddressInRange {
  param(
    [System.Version] $IPAddress,
    [System.Version] $FromAddress,
    [System.Version] $ToAddress
  )
  $FromAddress -le $IPAddress -and $IPAddress -le $ToAddress
}

foreach($scoid in $Scoids)
{

$start = $scoid.startRange
$End = $scoid.EndRange
$Scope = $scoid.ScopeId
$result = IsIpAddressInRange $IPAddressTbox.Text $start.IPAddressToString $End.IPAddressToString
if ($result -eq $true){$Scopeid = $Scope.IPAddressToString}
}

$ScopeIDTbox.Text = $Scopeid

$failover = Get-DhcpServerv4Failover -ComputerName $ServerName -ScopeId $Scopeid
$ServerRole = $failover.ServerRole

If($serverRole -eq "Active"){
$ServerRoleTbox.Text = "$serverName is $ServerRole server"
}elseIf($ServerRole -eq "Standby"){
$ServerRoleTbox.Text = "$serverName is $ServerRole Server "}
else{ $ServerRoleTbox.Text = "Either server is not found or Server is Windows 2008"}

If($serverRole -eq "Standby"){

$active = $failover.Partnerserver
$activeIp = (Resolve-DnsName $active).IPAddress
$IPActiveLabel.Text = "Active ip helper is $activeIp"
$IPActiveLabel.ForeColor = "Green"

}

})

$validatebutton.add_click({

$ServerName = (Resolve-DnsName $IPHelperTbox.Text| select NameHost).NameHost
$Scopeid = $ScopeIDTbox.Text

$Result = Get-DhcpServerv4reservation -ComputerName $ServerName -ScopeId $Scopeid -ClientID $MACTbox.Text -ErrorAction Ignore
$EIp = $Result.IPAddress.IPAddressToString
$EScopeid = $Result.ScopeID.IPAddressToString
$EClientid = $Result.ClientId
$EName = $Result.Name
$EDescription = $Result.Description
$EfreeIp = Get-DhcpServerv4FreeIPAddress –ComputerName $ServerName -ScopeId $Scopeid -NumAddress 5

if($Result -ne $null)
{ $MACValLabel.Text = "X"
  $MACValLabel.ForeColor = 'Red'
  [void][System.Windows.MessageBox]::Show( " IPAddress = $EIp `n ScopeId = $EScopeid `n MacAddress = $EClientid `n HostName = $EName `n Description = $EDescription `n FreeIP = $EfreeIp", "Reservation Details", "OK", "Information" )
    
}
else {
  $MACValLabel.Text = "✔"
  $MACValLabel.ForeColor = 'Green'}

$reservation = Get-DhcpServerv4reservation -ComputerName $ServerName -ScopeId $ScopeIDTbox.Text -ErrorAction Ignore
$Ipstoval = $reservation.IPAddress.ipaddresstostring

if($Ipstoval -contains $IPAddressTbox.Text)
    {
    $IPvalLabel.Text = "X"
    $IPvalLabel.ForeColor = 'Red'

    $dict = New-Object System.Collections.Generic.Dictionary"[String,string]"
    foreach($reservations in $reservation)
    {
    $dict.add($reservations.IPAddress.Ipaddresstostring, $reservations.ClientID)
    }
    $IClientid = $dict[$IPAddressTbox.Text]
    $IIp = $IPAddressTbox.Text
    $IScopeid = $ScopeIDTbox.Text
    $Iresult = Get-DhcpServerv4Reservation -ComputerName $ServerName -ScopeId $ScopeIDTbox.Text -ClientId $IClientid -ErrorAction Ignore
    $IName = $IResult.Name
    $IDescription = $IResult.Description
    $IfreeIp = Get-DhcpServerv4FreeIPAddress –ComputerName $ServerName -ScopeId $ScopeIDTbox.Text -NumAddress 5
    [void][System.Windows.MessageBox]::Show( " IPAddress = $IIp `n ScopeId = $IScopeid `n MacAddress = $IClientid `n HostName = $IName `n Description = $IDescription `n FreeIp = $IfreeIp", "Reservation Details", "OK", "Information" )
    
    }
else{
    $IPvalLabel.Text = "✔"
    $IPvalLabel.ForeColor = 'Green'
    }
  
})

$okbutton.Add_Click({
$ServerName = (Resolve-DnsName $IPHelperTbox.Text| select NameHost).NameHost
$Scopeid = $ScopeIDTbox.Text

do{
$Failed = $false
try {

$ReservedIP = Add-DhcpServerv4Reservation -ComputerName $ServerName -ScopeId $Scopeid –Ipaddress $IPAddressTbox.Text -ClientID $MACTbox.Text -Description $TaskTBox.Text -Name $HostTbox.Text -ErrorAction Stop
sleep 2
Invoke-DhcpServerv4FailoverReplication -ComputerName $ServerName -ScopeId $Scopeid -Confirm:$false

$output = Get-DhcpServerv4reservation -ComputerName $ServerName -ScopeId $Scopeid -ClientID $MACTbox.Text -ErrorAction Ignore
$FIP = $output.IPAddress.IPAddressToString
$Fscopeid = $output.ScopeId
$FClientID = $output.ClientID
$FHostName = $output.Name
$FDesc = $output.Description
[void][System.Windows.MessageBox]::Show( " IPAddress = $FIP `n ScopeId = $Fscopeid `n MacAddress = $FClientID `n HostName = $FHostName `n Description = $FDesc ", "Reservation Details", "OK", "Information" )

} catch {
[void][System.Windows.MessageBox]::Show("An error has occurred while trying to add a reservation for '$MACTbox.Text' with IP '$IPAddressTbox.Text'. Kindly do manually.", "Error", "OK", "Information")
}
} while ($Failed)

})

$DHCPMenu.CancelButton = $cancelbutton

$resetbutton.Add_click({
    $IPHelperTbox.Clear()
    $IPAddressTbox.Clear()
    $MACTbox.Clear()
    $HostTbox.Clear()
    $TaskTBox.Clear()
    $ScopeIDTbox.Clear()
    $ServerRoleTbox.Clear()
    $IPActiveLabel.Text = ""
    $MACValLabel.Text = ""
    $IPvalLabel.Text = ""    
    })

$DHCPMenu.ShowDialog()