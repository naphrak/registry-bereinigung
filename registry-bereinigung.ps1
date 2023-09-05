# Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Winners\
# amd64_microsoft-windows-d..definition-defender_31bf3856ad364e35_none_672a2c212598d823
#

#####################
# Variables
#####################
#region Variables

$currDate            = Get-Date -Format "yyyy-MM-dd"           # -HHmmss"
$programPath         = Split-Path $(( Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
$logFilePath         = $programPath + "\log"
$logFile             = $logFilePath + "\pwsync_$currDate.log"

$rootPath            = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Winners'
$searchPattern       = 'defender'

#endregion Variables
#####################


#####################
# Functions
#####################
#region Functions

#####################
# Function: Write Log File
#####################
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$logText,
        [Parameter(Mandatory=$false)]
        [int]$logLevel = 0
    )

    if ($logLevel -eq 0) {
        $logPartialText = "[INFO]    " + $logText
        $logLine = "["+$currDate+"] - " + $logPartialText
        Write-Host -ForegroundColor White $logLine
    }

    if ($logLevel -eq 1) {
        $logPartialText = "[WARNING] " + $logText
        $logLine = "["+$currDate+"] - " + $logPartialText
        Write-Host -ForegroundColor Yellow $logLine    
    }

    if ($logLevel -eq 2) {
        $logPartialText = "[ERROR]   " + $logText
        $logLine = "["+$currDate+"] - " + $logPartialText
        Write-Host -ForegroundColor Red $logLine    
    }

    Out-File -InputObject $logLine -FilePath $logFile -Encoding UTF8 -Append -Force
}
#####################

#endregion Functions
#####################


#####################
# Main
#####################

$allSubKeys = Get-ChildItem  -Path $rootPath

foreach ($entry in $allSubKeys ) {

    if ($entry.name -match $searchPattern) {
    #if ($entry.name -match 'x86_windows-defender-management-powershell_31bf3856ad364e35_none_61bdaff6e87aeece') {
        $keyInfo = Get-ChildItem -Path "Registry::$($entry.name)"
        $props = @()

        foreach ($property in $($keyInfo.Property)) {
            if ($property -notmatch 'default') {
                $props += $property
            }
        }
        
        if ($($props.count) -gt 1) {
            $pathExtract = ($($keyInfo.pspath).Replace("\10.0",'')).Split('\')[-1]
            Write-Host -ForegroundColor Red    "$pathExtract"
            Write-Host -ForegroundColor Yellow "$($props[0])`t"    -NoNewline
            Write-Host -ForegroundColor Cyan   "$($props[1])`t"    -NoNewline

            if ($($($props[0].Split('.')[0..($($props[0].split('.')).length -2)]) -join '.') -eq $($($props[0].Split('.')[0..($($props[0].split('.')).length -2)]) -join '.')) {
                Write-Host -ForegroundColor green "`tmatch"
            } else {
                Write-Host ""
            }            
        }
    } 
}