# Wake-on-LAN Script: Sendet ein Magic Packet, um einen Rechner mit einer angegebenen MAC-Adresse aufzuwecken
function Send-WakeOnLan {
    param (
        [string]$MacAddress,                      # MAC-Adresse des Zielcomputers (Format: 00:11:22:33:44:55)
        [string]$BroadcastAddress = "255.255.255.255",  # Broadcast-Adresse (Standard: Alle Geräte im Netzwerk)
        [int]$Port = 9,                          # UDP-Port für Wake-on-LAN (Standard: 9)
        [IPAddress]$LocalIPAddress = $null       # Lokale IP-Adresse der Netzwerkschnittstelle (optional)
    )

    # Debug: MAC-Adresse überprüfen und bereinigen
    # Erlaubt Formate wie 00:11:22:33:44:55 oder 00-11-22-33-44-55
    if ($MacAddress -notmatch "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$") {
        Write-Error "Fehler: Die MAC-Adresse hat ein ungültiges Format. Bitte verwende: 00:11:22:33:44:55 oder 00-11-22-33-44-55"
        return
    }

    # Bereinigen der MAC-Adresse (Entfernen von ":" oder "-")
    $MacAddressClean = $MacAddress.Replace("-", "").Replace(":", "")

    # Magic Packet erstellen
    # Aufbau: 6x FF (Broadcast) + 16x die MAC-Adresse
    [byte[]]$MagicPacket = (@(0xFF) * 6) + ([byte[]]@(
        [convert]::ToByte($MacAddressClean.Substring(0, 2), 16),
        [convert]::ToByte($MacAddressClean.Substring(2, 2), 16),
        [convert]::ToByte($MacAddressClean.Substring(4, 2), 16),
        [convert]::ToByte($MacAddressClean.Substring(6, 2), 16),
        [convert]::ToByte($MacAddressClean.Substring(8, 2), 16),
        [convert]::ToByte($MacAddressClean.Substring(10, 2), 16)
    ) * 16)

    # UDP-Socket erstellen und Magic Packet senden
    $UdpClient = New-Object System.Net.Sockets.UdpClient
    try {
		if ($LocalIPAddress) {
            # Lokale IP-Adresse explizit binden
            $UdpClient.Client.Bind([System.Net.IPEndPoint]::new($LocalIPAddress, 0))
        }
		
        $UdpClient.Connect($BroadcastAddress, $Port)
        $UdpClient.Send($MagicPacket, $MagicPacket.Length)
        Write-Host "Wake-on-LAN: Magic Packet erfolgreich an $MacAddress gesendet." -ForegroundColor Green
    } catch {
        Write-Error "Fehler beim Senden des Magic Packets: $_"
    } finally {
        $UdpClient.Close()
    }
}

# Beispielaufruf der Funktion mit spezifischem Netzwerkinterface
# Stelle sicher, dass du eine gültige IP-Adresse für die lokale Netzwerkschnittstelle angibst:
#Send-WakeOnLan -MacAddress "xx-xx-xx-xx-xx-xx" -LocalIPAddress (Get-NetIPAddress | Where-Object { $_.InterfaceAlias -eq "Ethernet" }).IPAddress
#Send-WakeOnLan -MacAddress "xx-xx-xx-xx-xx-xx" -LocalIPAddress "x.x.x.x"
Send-WakeOnLan -MacAddress "xx-xx-xx-xx-xx-xx"
