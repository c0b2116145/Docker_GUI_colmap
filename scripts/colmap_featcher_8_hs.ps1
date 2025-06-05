param (
    [string]$DATASET_PATH, 
    [string]$VERSION = ""
)
$database_dir = "$DATASET_PATH\database_hs$VERSION"
New-Item -ItemType Directory -Path $database_dir -Force

for($j = 400; $j -le 700; $j+=10){
    $hs = [string]$j
    $path_hs = "$DATASET_PATH\images_8_HSI\image$hs"
    colmap feature_extractor `
            --database_path $database_dir/database_8_hs_$hs.db `
            --image_path $path_hs `
            --ImageReader.single_camera 1 `
            --ImageReader.camera_model PINHOLE 
            --SiftExtraction.use_gpu 1
}
