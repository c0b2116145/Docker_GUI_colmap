param (
    [string]$DATASET_PATH, 
    [string]$version = ""
)

# Set-Location -Path $DATASET_PATH

colmap feature_extractor `
    --database_path $DATASET_PATH/database$version.db `
    --image_path $DATASET_PATH/images_8 `
    --ImageReader.camera_model PINHOLE `
    --ImageReader.single_camera 1

colmap exhaustive_matcher `
    --database_path $DATASET_PATH/database$version.db `
    --SiftMatching.use_gpu 1
    # --SiftMatching.max_ratio 1.1 `

New-Item -ItemType Directory -Path "$DATASET_PATH\sparse$version" -Force

#--Mapper.init_min_tri_angle 4はLLFFデータセットのfernシーンのようにカメラのの回転があまりないものだとやるといいかも
colmap mapper `
    --database_path $DATASET_PATH\database$version.db `
    --image_path $DATASET_PATH\images_8 `
    --output_path $DATASET_PATH\sparse$version `
    --Mapper.init_min_tri_angle 4 `
    --Mapper.multiple_models 0 
    # --Mapper.num_threads 16 `
    # --Mapper.extract_colors 0 
