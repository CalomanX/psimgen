param (
    [string]$platform = "all", # [all|android|ios|windowsmobile]
    [string]$filename = "*", # the name of the .svg source file (wildcards are ok)
    [string]$exportType = "png", # [png|pdf]
    [int]$width = 16, # reference width
    [int]$height = 16, # reference height
    [string]$targetPath = ".\", # target path
    [string]$commandFile, # can use a file as a source for commands
    [string]$prefix, # optional prefix for the filename
    [string]$sufix, # optional sufix for the filename 
    [switch]$freeze, # the files generated are NOT transfered to the target path
    [switch]$single, # only the base image (witn the defined width and height) will be created
    [switch]$quiet  # disable inkscape output
)


# Utility functions

function WriteToHost(
    [string]$message, $level = 0 ) {
    if (!$quit) {
        switch ($level) {
            1 { Write-Host $message -BackgroundColor DarkYellow -ForegroundColor Black }
            2 { Write-Host $message -BackgroundColor Red }
            default { Write-Host $message }
        } 
    }
}


function makedir( [string]$path) {
    WriteToHost  $path
    if ( !(Test-Path $path)) {
        mkdir -Path $path | Out-Null
    }
    return $path
}

# Script functions

function transferImage(
    [string]$sourceFileName,
    [string]$targetPath,
    [string]$targetFileName
) {

                
    if ( $prefix.Length -gt 0) {
        $targetFileName = ($prefix + $targetFileName);
    }
    if ( $sufix.Length -gt 0) {
        $targetFileName = ($targetFileName + $sufix);
    }   
    $targetPath = Join-Path $targetPath -ChildPath $targetFileName  
    try {
        WriteToHost  ("A transferir " + $sourceFileName + " para " + $targetPath + "...") -NoNewline
        Copy-Item $sourceFileName $targetPath;
        Remove-Item $sourceFileName       
        WriteToHost  "OK!"
    }
    catch {
        WriteToHost  ("ERRO! >> " + $_.Exception.Message), 2;    
    }


}

function exportImage (
    [string]$sourceFileName,
    [string]$targetFileName,
    [string]$asType = "png",
    [int]$height,
    [int]$width) {
        
    if ( $prefix.Length -gt 0) {
        $targetFileName = ($prefix + $targetFileName);
    }
    if ( $sufix.Length -gt 0) {
        $targetFileName = ($targetFileName + $sufix);
    }        
    $cmd = "-f=" + $sourceFileName + " -D -z -h=" + $h + " -w=" + $w + " --export-" + $asType + "=" + $targetFileName;
    $in.WriteLine($cmd);    
}

function transferImagesForDroid {
    if ( ($platform -eq $droid) -or ($platform -eq $all)) {
        foreach ($reffile in $files) {
            [System.IO.FileInfo]$file = $reffile;

            # drawable
            $sourceFileName = ("drawable_" + $file.BaseName + "." + $exportType);
            $targetPath = (".\" + $droid + "\drawable\");
            $targetFileName = ( $file.BaseName + "." + $exportType);            
            transferImage $sourceFileName $targetPath $targetFileName

            if (!$single) {
                # drawable-mdpi
                $sourceFileName = ("drawable-mdpi_" + $file.BaseName + "." + $exportType);
                $targetPath = (".\" + $droid + "\drawable-mdpi\");
                $targetFileName = ( $file.BaseName + "." + $exportType);            
                transferImage $sourceFileName $targetPath $targetFileName 

                # drawable-hdpi
                $sourceFileName = ("drawable-hdpi_" + $file.BaseName + "." + $exportType);
                $targetPath = (".\" + $droid + "\drawable-hdpi\");
                $targetFileName = ( $file.BaseName + "." + $exportType);            
                transferImage $sourceFileName $targetPath $targetFileName          
        
                # drawable-xhdpi
                $sourceFileName = ("drawable-xhdpi_" + $file.BaseName + "." + $exportType);
                $targetPath = (".\" + $droid + "\drawable-xhdpi\");
                $targetFileName = ( $file.BaseName + "." + $exportType);            
                transferImage $sourceFileName $targetPath $targetFileName            
        
                # drawable-xxhdpi
                $sourceFileName = ("drawable-xxhdpi_" + $file.BaseName + "." + $exportType);
                $targetPath = (".\" + $droid + "\drawable-xxhdpi\");
                $targetFileName = ( $file.BaseName + "." + $exportType);            
                transferImage $sourceFileName $targetPath $targetFileName     
            
            
                # drawable-xxxhdpi
                $sourceFileName = ("drawable-xxxhdpi_" + $file.BaseName + "." + $exportType);
                $targetPath = (".\" + $droid + "\drawable-xxxhdpi\");
                $targetFileName = ( $file.BaseName + "." + $exportType);            
                transferImage $sourceFileName $targetPath $targetFileName     
            }
            
        } 
    }
}


function generateImagesForDroid {
    if ( ($platform -eq $droid) -or ($platform -eq $all)) {
        makedir (".\" + $droid);
        makedir (".\" + $droid + "\drawable");

        if (!($single)) {
            makedir (".\" + $droid + "\drawable-hdpi");
            makedir (".\" + $droid + "\drawable-mdpi");
            makedir (".\" + $droid + "\drawable-xhdpi");
            makedir (".\" + $droid + "\drawable-xxhdpi");
            makedir (".\" + $droid + "\drawable-xxxhdpi");    
        }

        foreach ($reffile in $files) {
            [System.IO.FileInfo]$file = $reffile;

            # droid\drawable
            $h = $height;
            $w = $width;
            exportImage $file.Name ("drawable_" + $file.BaseName + "." + $exportType) $exportType $h $w

            if (!$single) {

                # droid\drawable-mdpi
                $h = ($height / 2);
                $w = ($width / 2);
                exportImage $file.Name ("drawable-mdpi_" + $file.BaseName + "." + $exportType) $exportType $h $w

                # droid\drawable-hdpi
                $h = ($height * 2);
                $w = ($width * 2);
                exportImage $file.Name ("drawable-hdpi_" + $file.BaseName + "." + $exportType) $exportType $h $w

                # droid\drawable-xhdpi
                $h = ($height * 4);
                $w = ($width * 4);
                exportImage $file.Name ("drawable-xhdpi_" + $file.BaseName + "." + $exportType) $exportType $h $w

                # droid\drawable-xxhdpi
                $h = ($height * 8);
                $w = ($width * 8);
                exportImage $file.Name ("drawable-xxhdpi_" + $file.BaseName + "." + $exportType) $exportType $h $w

                # droid\drawable-xxxhdpi
                $h = ($height * 16);
                $w = ($width * 16);
                exportImage $file.Name ("drawable-xxxhdpi_" + $file.BaseName + "." + $exportType) $exportType $h $w
            }                    
        } 
    }
}


function transferImagesForIOS {
    if ( ($platform -eq $ios) -or ($platform -eq $all)) {
        foreach ($reffile in $files) {
            [System.IO.FileInfo]$file = $reffile;

            # ios
            $sourceFileName = ("ios_" + $file.BaseName + "." + $exportType);
            $targetPath = (".\" + $ios + "\");
            $targetFileName = ( $file.BaseName + "." + $exportType);            
            transferImage $sourceFileName $targetPath $targetFileName     

            if ($single) {

                # ios@2x
                $sourceFileName = ("ios_" + $file.BaseName + "@2x." + $exportType);
                $targetPath = (".\" + $ios + "\");                
                $targetFileName = ($file.BaseName + "2@x." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName 

                # ios@3x
                $sourceFileName = ("ios_" + $file.BaseName + "@3x." + $exportType);
                $targetPath = (".\" + $ios + "\");                
                $targetFileName = ($file.BaseName + "@3x." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName 
            }
        }
    }
}


function generateImagesForIOS {
    if ( ($platform -eq $ios) -or ($platform -eq $all)) {
        makedir (".\" + $ios);

        foreach ($reffile in $files) {
            [System.IO.FileInfo]$file = $reffile;

            # @
            $h = $height;
            $w = $width;
            exportImage $file.Name ("ios_" + $file.BaseName + "." + $exportType) $exportType $h $w

            if (!$single) {
                # @x2
                $h = ($height * 2);
                $w = ($width * 2);
                exportImage $file.Name ("ios_" + $file.BaseName + "@2x." + $exportType) $exportType $h $w

                # @x3
                $h = ($height * 3);
                $w = ($width * 3);
                exportImage $file.Name ("ios_" + $file.BaseName + "@3x." + $exportType) $exportType $h $w   
            }                 
        } 
    }
}


function transferImagesForWindowsPhone {
    if ( ($platform -eq $winphone) -or ($platform -eq $all)) {
        foreach ($reffile in $files) {
            [System.IO.FileInfo]$file = $reffile;

            if ($single) {
                $sourceFileName = ("winphone_" + $file.BaseName + "." + $exportType);
                $targetPath = (".\" + $winphone + "\");                
                $targetFileName = ($file.BaseName + "." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName            
            }
            else {           

                # winphone
                $sourceFileName = ("winphone_" + $file.BaseName + ".scale-100." + $exportType);
                $targetPath = (".\" + $winphone + "\");                
                $targetFileName = ($file.BaseName + ".scale-100." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName 

                $sourceFileName = ("winphone_" + $file.BaseName + ".scale-125." + $exportType);
                $targetPath = (".\" + $winphone + "\");                
                $targetFileName = ($file.BaseName + ".scale-125." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName 

                $sourceFileName = ("winphone_" + $file.BaseName + ".scale-150." + $exportType);
                $targetPath = (".\" + $winphone + "\");                
                $targetFileName = ($file.BaseName + ".scale-150." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName 

                $sourceFileName = ("winphone_" + $file.BaseName + ".scale-200." + $exportType);
                $targetPath = (".\" + $winphone + "\");                
                $targetFileName = ($file.BaseName + ".scale-200." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName 
                
                $sourceFileName = ("winphone_" + $file.BaseName + ".scale-400." + $exportType);
                $targetPath = (".\" + $winphone + "\");                
                $targetFileName = ($file.BaseName + ".scale-400." + $exportType);
                transferImage $sourceFileName $targetPath $targetFileName 

            }

        }
    }
}

function generateImagesForWindowsPhone {
    if ( ($platform -eq $winphone) -or ($platform -eq $all)) {
        makedir (".\" + $winphone);

        foreach ($reffile in $files) {
            [System.IO.FileInfo]$file = $reffile;

            if ($single) {
                $h = $height;
                $w = $width;
                exportImage $file.Name ("winphone_" + $file.BaseName + "." + $exportType) $exportType $h $w 
            }
            else {
                # 100
                $h = $height;
                $w = $width;
                exportImage $file.Name ("winphone_" + $file.BaseName + ".scale-100." + $exportType) $exportType $h $w 
            
                # 125
                $h = ($height * 1.25);
                $w = ($width * 125);
                exportImage $file.Name ("winphone_" + $file.BaseName + ".scale-125." + $exportType) $exportType $h $w 
             
                # 150
                $h = ($height * 1.5);
                $w = ($width * 1.5);
                exportImage $file.Name ("winphone_" + $file.BaseName + ".scale-150." + $exportType) $exportType $h $w 
             
                # 200
                $h = ($height * 2);
                $w = ($width * 2);
                exportImage $file.Name ("winphone_" + $file.BaseName + ".scale-200." + $exportType) $exportType $h $w 
                      
                # 400
                $h = ($height * 4);
                $w = ($width * 4);
                exportImage $file.Name ("winphone_" + $file.BaseName + ".scale-400." + $exportType) $exportType $h $w 
            }
            
        } 
    }
}


function generateImages {
    generateImagesForDroid;
    generateImagesForIOS;
    generateImagesForWindowsPhone;
}

function transferImages {
    transferImagesForDroid;
    transferImagesForIOS;
    transferImagesForWindowsPhone;
}


# START


[string]$all = "all"
[string]$droid = "android"
[string]$ios = "ios"
[string]$winphone = "windowsmobile" 


# INIT
$shell = "C:\temp\Inkscape\App\Inkscape\inkscape.com"
$psi = New-Object System.Diagnostics.ProcessStartInfo;
$psi.FileName = $shell; #process file
$psi.UseShellExecute = $false; #start the process from it's own executable file
$psi.RedirectStandardInput = $true; #enable the process to read from standard input
$psi.RedirectStandardOutput = $quiet; #enable the process to write from standard input
$psi.WorkingDirectory = (Get-Item -Path ".\").FullName
$psi.Arguments = "--shell"  
$files = Get-ChildItem ($filename + ".svg")

[System.Diagnostics.Process]$proc = [System.Diagnostics.Process]::Start($psi);
Start-Sleep 2
[System.IO.StreamWriter]$in = $proc.StandardInput



if ( ($platform -eq $all) -or ($platform -eq $droid) -or ($platform -eq $ios) -or ($platform -eq $winphone) ) {

    if ( $commandFile.Length -eq 0) {
        generateImages
    }
    else {
        $freeze = $true;
        Get-Content $commandFile | ForEach-Object {
            if ($_.Length -gt 0) {
                if (!$quiet) {
                    WriteToHost  ("Exec > " + $shell + " :: " + $_);        
                }    
                $in.WriteLine($_);
            }
        }

    }
    $in.WriteLine("quit")
    $proc.WaitForExit();
    if ( !($freeze)) {
        transferImages;
    }
    return

}


<#
    .SYNOPSIS 
      Generates png/pdf files from .svg
    .EXAMPLE
     .\imgen.ps1 all -exporttype png -width 32 -height 32
  #>

