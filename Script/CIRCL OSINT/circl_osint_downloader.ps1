# Get your LR installation
$lr = "YOUR_LR_SERVER_HERE"

# Get list of new intel
Invoke-WebRequest -Uri https://www.circl.lu/doc/misp/feed-osint/ | Foreach { $_.Links.innerHTML } | Select-String "json" | Select-String "manifest.json" -NotMatch | Foreach-Object {Add-Content C:\Temp\intels.txt "https://www.circl.lu/doc/misp/feed-osint/$_"}

# Download OSINT
Get-Content C:\Temp\intels.txt | foreach { Invoke-WebRequest -Uri $_ | ConvertFrom-Json | foreach { $_.Event.Attribute } | Where-Object {($_.type -eq "ip-dst") -or ($_.type -eq "domain") -or ($_.type -eq "ip-src")} | foreach { $_.value } | Out-File C:\Temp\circl_temp.txt -Append }

# Copy to LogRhythm
Copy-Item -Path C:\Temp\circl_temp.txt -Destination "\\$lr\C$\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\circl.txt"

# Clean up
Remove-Item C:\Temp\intels.txt
Remove-Item C:\Temp\circl_temp.txt