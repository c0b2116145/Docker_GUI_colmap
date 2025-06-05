param (
    [string]$IMAGESPATH
)

for($j = 400; $j -le 700; $j+=10){
    $hs = [string]$j
    $path_hs = $IMAGESPATH
    New-Item -ItemType Directory -Path "$path_hs\image$hs"
    Get-ChildItem -Path .\$path_hs\*$hs.png -Recurse | Move-Item -Destination ".\$path_hs\image$hs"   
}

