# by Patrick Schmid
# Scrape DGArchive list and returns text file with Domains listed one on each line

#set the maximum amount of items to import from each website
$ItemMax = 1000000
$Count = 0

$Path_32 = "C:\Program Files (x86)\LogRhythm\LogRhythm Job Manager\config\list_import\"
$Path_64 = "C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\"
$OutputFileName = "dgarchive.txt"


if ((Test-Path -path $Path_32)){
	$FilePath = $Path_32 + $OutputFileName
	$FilePathTMP = $Path_32 + $OutputFileName + "_tmp"
}

if ((Test-Path -path $Path_64)){
	$FilePath = $Path_64 + $OutputFileName
	$FilePathTMP = $Path_64 + $OutputFileName + "_tmp"

}

######################
#Ignoring SSL trust relationship within this PS script only
$netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])
if($netAssembly) {
    $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
    $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")
    $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())
        if($instance) {
            $bindingFlags = "NonPublic","Instance"
            $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)
            if($useUnsafeHeaderParsingField) {
                $useUnsafeHeaderParsingField.SetValue($instance, $true)
            }
        }
}

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
######################

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}


# Uses the .Net Object Net.Webclient to scrape the listed website and store the contents in a text file.
$blocklist = New-Object Net.WebClient
$blocklist.Credentials = New-Object System.Net.NetworkCredential("USERNAME", "PASSWORD", "")
$blocklist.DownloadString("https://dgarchive.caad.fkie.fraunhofer.de/today/3/dnsrbl") > .\tempDGA.txt

#checks for blank text file and exits the program if the file is blank
Get-Content .\tempDGA.txt | Measure-Object -word
if ($word -eq 0){
    Break
    }
    
#Get-Content will put each individual line in the text file as an individual object which sets up the "if" loop below.
$blocklist = Get-Content .\tempDGA.txt

# removes temp blocklist text file
Remove-Item .\tempDGA.txt

# if a line in $blocklist is not a header column AND the max number of objects has not been
# reached ($ItemMax) then strip of the extraneous content and append to text file.
$blocklist | ForEach-Object{
     if( $_ -match "^[^#]" -and $ItemMax -gt 0 ){
    
        #decrement count to limit the amount of objects in final text file
        $ItemMax = $ItemMax - 1
        
        #increase counter to count number of items on webpage
        $Count = $Count +1
        
    	## remove trailing text
    	Foreach-Object {$_ -replace " # .*\b", ""} |
        Foreach-Object {$_.Substring(0,$_.Length-5)}  |
    	Out-file $FilePathTMP -append } 
        # End of the if statement

} ## end of ForEach-Object Statement

Rename-Item -path $FilePathTMP -newname $FilePath

#output number of objects (for testing only)
#$Count

#read the new blocklist (for testing only)
#notepad .\dgarchive.txt