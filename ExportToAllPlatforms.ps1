param(
    [string]$FullPath,
    [string]$TargetPath,
    [int]$Height,
    [int]$Width,
    [string]$PathToInkscape
)

.\Export-Image.ps1 -FullFileName $FullPath -TargetPath $TargetPath  -ExportType png -ExportArea drawing -Height $Height -Width $Width -Platform Android -Execute -InkspaceFullPath $PathToInkscape
.\Export-Image.ps1 -FullFileName $FullPath -TargetPath $TargetPath  -ExportType png -ExportArea drawing -Height $Height -Width $Width -Platform iOS -Execute -InkspaceFullPath $PathToInkscape
.\Export-Image.ps1 -FullFileName $FullPath -TargetPath $TargetPath  -ExportType png -ExportArea drawing -Height $Height -Width $Width -Platform UWP -Execute -InkspaceFullPath $PathToInkscape
