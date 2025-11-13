📄 README.md — NTLMv1 Audit Script
🧭 Executive Summary
This PowerShell script audits NTLMv1 authentication events on Windows systems by scanning the Security event log for Event ID 4624 with LmPackageName = "NTLM V1". It filters out anonymous logons, applies a 7-day date range, and exports relevant fields to a CSV file. The script also generates a timestamped log file with UK-formatted dates and clear console feedback, making it ideal for scheduled audits, compliance checks, or forensic reviews.

⚙️ Technical Overview
🔍 What It Does
- Queries the Windows Security event log for NTLMv1 logon events (Event ID 4624)
- Filters out ANONYMOUS LOGON entries
- Applies a date range (default: last 7 days)
- Extracts key fields:
- TimeCreated (UK format)
- Account Name
- Account Domain
- Logon Type
- Workstation Name
- Source Network Address
- Exports results to C:\NTLMv1Events.csv
- Logs all actions to C:\Logs\NTLMv1Audit_dd-MM_HH-mm.log
🛡️ Error Handling & Feedback
- Gracefully handles “no events found” as a [WARN], not [ERROR]
- Logs unexpected errors with [ERROR]
- Displays console messages for audit status and log location
📦 Output Files
|  |  |  | 
|  | C:\NTLMv1Events.csv |  | 
|  | C:\Logs\NTLMv1Audit_dd-MM_HH-mm.log |  | 



🧪 Example Usage
Simply run the script in PowerShell:
.\Audit-NTLMv1.ps1


Console output:
Running NTLMv1 audit... Please wait.
⚠️ No NTLMv1 logon events found between 06-11-2025 and 13-11-2025
📄 Log file created: C:\Logs\NTLMv1Audit_13-11_13-09.log



📊 Sample CSV Output
"TimeCreated","Account Name","Account Domain","Logon Type","Workstation Name","Source Network Address"
"12-11-2025 14:22:10","jdoe","CORP","3","WS01","192.168.1.45"
"10-11-2025 09:15:33","asmith","CORP","3","WS02","192.168.1.88"



📁 Sample Log Output
13-11-2025 13:09:08 [INFO] Starting NTLMv1 event extraction for range 06-11-2025 to 13-11-2025
13-11-2025 13:09:08 [WARN] No NTLMv1 logon events found in the specified date range.
13-11-2025 13:09:08 [INFO] Audit finished with 0 events found.
13-11-2025 13:09:08 [INFO] NTLMv1 audit script completed.




