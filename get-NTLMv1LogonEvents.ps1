# Define date range (last 7 days)
$endDate = Get-Date
$startDate = $endDate.AddDays(-7)

# Format timestamp for log filename (dd-MM_HH-mm)
$timestamp = Get-Date -Format "dd-MM_HH-mm"
$logPath = "C:\Logs\NTLMv1Audit_$timestamp.log"
$outputPath = "C:\NTLMv1Events.csv"

# Ensure log directory exists
$logDir = Split-Path $logPath
if (!(Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}

# Function to write to log with UK date format
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $entryTime = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    Add-Content -Path $logPath -Value "$entryTime [$Level] $Message"
}

# Begin processing
Write-Log "Starting NTLMv1 event extraction for range $($startDate.ToString('dd-MM-yyyy')) to $($endDate.ToString('dd-MM-yyyy'))"
Write-Host "Running NTLMv1 audit... Please wait."

try {
    $xmlFilter = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
      *[System[(EventID=4624)]]
      [EventData[Data[@Name='LmPackageName'] and (Data='NTLM V1')]]
    </Select>
  </Query>
</QueryList>
"@

    [xml]$xmlObject = $xmlFilter

    $rawEvents = Get-WinEvent -FilterXml $xmlObject -ErrorAction Stop

    $events = $rawEvents |
        Where-Object {
            $_.TimeCreated -ge $startDate -and $_.TimeCreated -le $endDate -and
            $_.Properties[5].Value -ne "ANONYMOUS LOGON"
        } |
        Select-Object @{Name='TimeCreated';Expression={($_.TimeCreated).ToString("dd-MM-yyyy HH:mm:ss")}},
            @{Name='Account Name';Expression={$_.Properties[5].Value}},
            @{Name='Account Domain';Expression={$_.Properties[6].Value}},
            @{Name='Logon Type';Expression={$_.Properties[8].Value}},
            @{Name='Workstation Name';Expression={$_.Properties[11].Value}},
            @{Name='Source Network Address';Expression={$_.Properties[18].Value}}

    if ($events.Count -eq 0) {
        Write-Log "No NTLMv1 logon events found in the specified date range." "WARN"
        Write-Host "⚠️ No NTLMv1 logon events found between $($startDate.ToString('dd-MM-yyyy')) and $($endDate.ToString('dd-MM-yyyy'))"
    } else {
        Write-Log "Retrieved $($events.Count) NTLMv1 logon events."
        $events | Export-Csv -Path $outputPath -NoTypeInformation -Force
        Write-Log "Exported results to $outputPath"
        Write-Host "✅ Audit complete. $($events.Count) events exported to $outputPath"
    }

    Write-Host "📄 Log file created: $logPath"
    Write-Log "Audit finished with $($events.Count) events found."
}
catch {
    if ($_.Exception.Message -like "*No events were found*") {
        Write-Log "No NTLMv1 logon events found in the specified date range." "WARN"
        Write-Host "⚠️ No NTLMv1 logon events found between $($startDate.ToString('dd-MM-yyyy')) and $($endDate.ToString('dd-MM-yyyy'))"
        Write-Host "📄 Log file created: $logPath"
    } else {
        Write-Log "Unexpected error during event extraction: $_" "ERROR"
        Write-Host "❌ An unexpected error occurred. Check the log file at $logPath"
    }
}
finally {
    Write-Log "NTLMv1 audit script completed."
}
