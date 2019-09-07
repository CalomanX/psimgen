param(
    [Parameter(Mandatory=$true)][Parameter(Mandatory=$true)][string]$FullPath,
    [Parameter(Mandatory=$true)][string]$TargetPath,
    [Parameter(Mandatory=$true)][Parameter(Mandatory=$true)][string]$PathToInkscape,
    [Parameter(Mandatory=$true)][Validateset("AppIcon")][string]$IconType,
    [switch]$iPhone,
    [switch]$iPad,
    [switch]$AppStore,
    [switch]$Android,
    [switch]$GoolgePlayStore
)


function ExportBySizeAndPlatform( [int]$height, [int]$width, [string]$platform) {
    .\Export-Image.ps1 -FullFileName $FullPath -TargetPath $TargetPath  -ExportType png -ExportArea drawing -Height $height -Width $width -Platform $platform -Execute -InkspaceFullPath $PathToInkscape
    Out-Null 
}


if ( $iPhone -eq $true) {
    ExportBySizeAndPlatform -height 60 -width 60 -platform iOS

}

if ( $iPad -eq $true) {
    ExportBySizeAndPlatform -height 76 -width 76 -platform iOS
    ExportBySizeAndPlatform -height 83 -width 83 -platform iOS
}

if ( $AppStore -eq $true) {
    ExportBySizeAndPlatform -height 1024 -width 1024 -platform Custom
}

if ( $Android -eq $true) {
    ExportBySizeAndPlatform -height 48 -width 48 -platform Android
}

if ( $GoolgePlayStore -eq $true) {
    ExportBySizeAndPlatform -height 512 -width 512 -platform Custom
}

