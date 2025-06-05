param (
    [string]$DATASET_PATH, 
    [string]$VERSION
)

# Set-Location -Path $DATASET_PATH

# colmap feature_extractor `
#     --database_path $DATASET_PATH/database_8.db `
#     --image_path $DATASET_PATH/images_8 `
#     --ImageReader.single_camera 1

colmap exhaustive_matcher `
    --database_path $DATASET_PATH/database$VERSION.db `
    --SiftMatching.use_gpu 1
    # --SiftMatching.max_ratio 1.1 `
    # --SiftMatching.max_num_matches 30000
    # --SiftMatching.max_num_trials 0 `
    
    # --SiftMatching.min_num_inliers 0 `
    # --SiftMatching.min_inlier_ratio 0 `
    # --SiftMatching.multiple_models false `
    
    # --SiftMatching.max_num_matches 57000
    

New-Item -ItemType Directory -Path "$DATASET_PATH\sparse$VERSION" -Force

colmap mapper `
    --database_path $DATASET_PATH\database$VERSION.db `
    --image_path $DATASET_PATH\images_8 `
    --output_path $DATASET_PATH\sparse$VERSION `
    --Mapper.multiple_models 0 `
    --Mapper.num_threads 16 `
    --Mapper.init_min_tri_angle 4 
    # --Mapper.extract_colors 0 
