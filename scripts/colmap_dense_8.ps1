<#
sfmはそれぞれのバージョンごとにスクリプトを作ったが、
MVSは一つのスクリプトでVERSION引数を変えるだけでできるようにした。
#>


param (
    [string]$DATASET_PATH, 
    [string]$VERSION = ""
)

New-Item -ItemType Directory -Path "$DATASET_PATH\dense$VERSION" -Force

colmap image_undistorter `
    --image_path $DATASET_PATH\images_8 `
    --input_path $DATASET_PATH/sparse$VERSION/0 `
    --output_path $DATASET_PATH/dense$VERSION `
    --output_type COLMAP

colmap patch_match_stereo `
    --workspace_path $DATASET_PATH/dense$VERSION `
    --workspace_format COLMAP `
    --PatchMatchStereo.geom_consistency true

colmap stereo_fusion `
    --workspace_path $DATASET_PATH/dense$VERSION `
    --workspace_format COLMAP `
    --input_type geometric `
    --output_path $DATASET_PATH/dense$VERSION/fused.ply