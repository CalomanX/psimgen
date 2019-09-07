<#
    .SYNOPSIS
    Convert images with Inkscape

    .DESCRIPTION
    Parses image files defined by the FullFileName parameter and converts them to a defined format

    .PARAMETER FullFileName
    The name of the file(s) to be converted. Wildcards are accepted

    .PARAMETER TargetPath
    The base path the new images are to be written (check also AditionalDirectory and definitions in each of the platforms instances)

    .PARAMETER ExportType
    The format of the converted images ("png", "ps", "eps", "pdf", "latex", "plain-svg", "wmf", "emf")

    .PARAMETER Height
    The base height
    Please note that for each platform there os a "default" size
    
    .PARAMETER Width
    The base width
    Please note that for each platform there os a "default" size

    .PARAMETER DPI
    The dpi the target images should have

    .PARAMETER AdicionalDirectory
    An adicional folder to be added on top of the target folder

    .PARAMETER Platform
    The targeted platform ("Android", "iOS", "UWP", "Custom")

    .PARAMETER Execute
    The resulting script is to be run immediately

    .PARAMETER InkspaceFullPath
    The full path to the inskspace exe/com

#>
param(
    [Parameter(Mandatory=$true)][string]$FullFileName,
    [string]$TargetPath,
    [ValidateSet("png", "ps", "eps", "pdf", "latex", "plain-svg", "wmf", "emf")][string]$ExportType = "png",
    [ValidateSet("page", "drawing", "snap")][string]$ExportArea = "drawing",
    [int]$Height = 0,
    [int]$Width = 0,
    [int]$DPI = 0,
    [string]$AditionalDirectory,
    [ValidateSet("Android", "iOS", "UWP", "Custom")][string]$Platform,
    [switch]$Execute = $false,
    [Parameter(Mandatory=$true)][string]$InkspaceFullPath = "d:\tools\Inkscape\inkscape.exe",
    [ValidateSet("with-gui", "without-gui")][string]$UIModeI = "without-gui"
)

#################################################################################################################
# Classes
# http://dpi.lv/
# https://ivomynttinen.com/blog/ios-design-guidelines
#################################################################################################################

Class PlatformConfig {
    [int]$VersionCount
    [string]$BaseFolder
    [PlatFormItem[]]$Items

    [string]ToString() { 
        return "Unknown";
    }
}    

Class PlatFormItem {
    [string]$Folder
    [string]$PostFix 
    [double]$Factor

    PlatFormItem([string]$folder_, [string]$postFix_, [double]$factor_) {
        $this.Folder = $folder_
        $this.PostFix = $postFix_
        $this.Factor = $factor_
    }
}

class AndroidConfig : PlatformConfig {

    AndroidConfig() {
        $this.Items = @([PlatFormItem]::new("drawable-ldpi", "", 0.75), 
                        [PlatFormItem]::new("drawable-mdpi", "", 1), 
                        [PlatFormItem]::new("drawable-hdpi", "", 1.5), 
                        [PlatFormItem]::new("drawable-xhdpi", "", 2), 
                        [PlatFormItem]::new("drawable-xxhdpi", "", 3), 
                        [PlatFormItem]::new("drawable-xxxhdpi", "", 4), 
                        [PlatFormItem]::new("drawable-tvpi", "", 1.33))
        $this.VersionCount = 7
        $this.BaseFolder = "Android"
    }

    [string]ToString() {
        return "Android";
    }
}


class iOSConfig : PlatformConfig {

    iOSConfig() {
        $this.Items = @([PlatFormItem]::new("", "", 1.0), 
                        [PlatFormItem]::new("", "@x2", 2.0), 
                        [PlatFormItem]::new("", "@x3", 3.0), 
                        [PlatFormItem]::new("", "@x4", 4.0))
        $this.VersionCount = 4
        $this.BaseFolder = "IOS"
    }

    [string]ToString() {
        return "iOS";
    }
}

class UWPConfig : PlatformConfig {

    UWPConfig() {
        $this.Items = @([PlatFormItem]::new("", "-100", 1.0), 
                        [PlatFormItem]::new("", "-150", 1.5),
                        [PlatFormItem]::new("", "-200", 2.0), 
                        [PlatFormItem]::new("", "-300", 3.0), 
                        [PlatFormItem]::new("", "-400", 4.0),
                        [PlatFormItem]::new("", "-800", 8.0))
        $this.VersionCount = 6
        $this.BaseFolder = "UWP"
    }

    [string]ToString() {
        return "UWP";
    }
}

class CustomConfig : PlatformConfig {

    CustomConfig() {
        $this.Items = @([PlatFormItem]::new("", "", 1))
        $this.VersionCount = 1
        $this.BaseFolder = "Custom"
    }

    [string]ToString() {
        return "Custom";
    }
}



#################################################################################################################
# Functions
#################################################################################################################

function LogVerbose($message_) {
    if ( $Verbose -eq $true) {
        Write-Host $message_
    }
}



function BuildTargetDirectoryStructure([string]$path_) {
    $path_ = Split-Path -Path $path_ -Parent
    if ($(Test-Path $path_) -eq $false) {
        New-Item -ItemType "Directory" -Path $path_
    }
    return
}


function GenerateLine([System.IO.FileInfo]$file_,[PlatformItem]$configItem_){
    $Width_ = $Width * $($configItem_.Factor)
    $Height_ = $Height * $($configItem_.Factor)
    $exportName_ = $file_.BaseName + $configItem_.PostFix + "." + $ExportType
    $exportPath_ = Join-Path $(Join-Path $TargetPath -ChildPath $configItem_.Folder)  -ChildPath $exportName_
    BuildTargetDirectoryStructure $exportPath_ | Out-Null
    
    $DPI_ = ""
    if ( $DPI -gt 0) {
        $DPI_ = " --export-dpi=$DPI"
    }
    $line_ = "--file=`"$file_`" --export-$ExportType=`"$exportPath_`" --export-width=$Width_ --export-height=$Height_ $DPI_ --export-area-$ExportArea --$UIModeI"
    return $line_
}

function ForEachPlatFormItem([System.IO.FileInfo]$file_, [PlatformConfig]$config_) {
    if ( $config_.BaseFolder.Length -gt 0) {
        $TargetPath = Join-Path $TargetPath -ChildPath $config_.BaseFolder
        BuildTargetDirectoryStructure $TargetPath | Out-Null
    }
    $lines_ = $config_.Items | ForEach-Object {
        GenerateLine $file_ $_
    }
    return $lines_
}

function GetPlatformItems([System.IO.FileInfo]$file_) {

    switch ($Platform) {
        "Android" { 
            $pA = [AndroidConfig]::new()
            $item_ = ForEachPlatFormItem $file_ $pA
         }
         "iOS" { 
            $pios = [iOSConfig]::new()
            $item_ =  ForEachPlatFormItem $file_ $pios
         }
         "UWP" { 
            $puwp = [UWPConfig]::new()
            $item_ =  ForEachPlatFormItem $file_ $puwp
         }                  
        "Custom" {
            $pcustom = [CustomConfig]::new()
            $item_ = ForEachPlatFormItem $file_ $pcustom
        }
    }
    return $item_
}

function ExecuteInkspace([string[]]$lines) {

}


#################################################################################################################
# Main
#################################################################################################################

# Validate entry params

Write-Verbose "Checking the source path..." 
if ($(Test-Path -Path $FullFileName) -eq $false) {
    Write-Error -Message "$FullFileName is not a valid path" -Category InvalidArgument -ErrorAction Stop
}

Write-Verbose "Checking the Execute flag"
if ($Execute -eq $true -and ($InkspaceFullPath.Length -eq 0) ) {
    Write-Error -Message "$if execute you must provide the full path to inkscape" -Category InvalidArgument -ErrorAction Stop
}

$allfiles = Get-Item -Path $FullFileName

# Normalize input parameters
if ( $TargetPath.Length -eq 0) {
    $TargetPath = $allfiles[0].DirectoryName
    Write-Verbose "Normalizing the TargetPath with path $TargetPath"
}


if ($AditionalDirectory.Length -gt 0) {
    $TargetPath = [System.IO.Path]::Combine($TargetPath, $AditionalDirectory)
    Write-Verbose "Including $aditionalDirectory to the TargetPath"
}

if ( $DPI -eq 0 -and ( $Height -eq 0 -or $Width -eq 0 )) {
    Write-Verbose "Checking Height, Width and dpi definitions"
    Write-Error -Message "Must provide dimensions or dpi for the exported image." -Category InvalidArgument -ErrorAction Stop
    
}


# START

BuildTargetDirectoryStructure -path_ $TargetPath | Out-Null

$lines = $allfiles | ForEach-Object {
    return GetPlatformItems $_
}

#$lines = GetPlatformItems
$fileId = $(Get-Date -Format "yyyyMMddhhmmss") + "_" + ([System.Guid]::NewGuid()).ToString()
$fileName = ($fileId + ".txt")
Out-File -FilePath $fileName -InputObject $lines -Encoding "ascii" 
LogVerbose "File saved as $fileId"
if ($Execute -eq $true) {
    & cmd.exe /r $InkspaceFullPath --shell `< $fileName
}
