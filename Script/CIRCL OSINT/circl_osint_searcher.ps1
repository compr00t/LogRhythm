# Search parameter
$search = "172.29.21.174"
$ErrorActionPreference = 'Continue'

# Settings
function ConvertFrom-Json2{
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]

param
(  
    [parameter(
        ParameterSetName='object',
        ValueFromPipeline=$true,
        Mandatory=$true)]
        [string]
        $InputObject,
    [parameter(
        ParameterSetName='object',
        ValueFromPipeline=$true,
        Mandatory=$false)]
        [int]$MaxJsonLength = 67108864
)

BEGIN 
{ 
    [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')        
    $jsonserial= New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer 
    $jsonserial.MaxJsonLength  = $MaxJsonLength

}

PROCESS
{
    if ($PSCmdlet.ParameterSetName -eq 'object')
    {
        $deserializedJson = $jsonserial.DeserializeObject($InputObject)
        foreach($desJsonObj in $deserializedJson){
            $psObject = New-Object -TypeName psobject -Property $desJsonObj

            $dicMembers = $psObject | Get-Member -MemberType NoteProperty
            $psObject
        }
    }
}

END
{
}

}

# Get list of new intel
Invoke-WebRequest -Uri https://www.circl.lu/doc/misp/feed-osint/ | Foreach { $_.Links.innerHTML } | Select-String "json" | Select-String "manifest.json" -NotMatch | Foreach-Object {Add-Content C:\Temp\intels.txt "https://www.circl.lu/doc/misp/feed-osint/$_"}

# Download OSINT
Get-Content C:\Temp\intels.txt | foreach { Invoke-WebRequest -Uri $_ | ConvertFrom-Json2 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | foreach { $_.Event.Attribute } | Where-Object { $_.value -eq $search } }

# Cleanup
Remove-Item C:\Temp\intels.txt