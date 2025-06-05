param (
    [string]$DATASET_PATH
    [string]$VERSION = ""
)
#単眼カメラで撮影された動画みたいな連続したデータ用
# Set-Location -Path $DATASET_PATH

# $DATASET_PATHの下にimagesがあることを想定

# $DATASET_PATHの下にdatabase$VERSIONとsparse$VERSIONができる

colmap feature_extractor `
    --ImageReader.camera_model OPENCV `
    --database_path $DATASET_PATH/database$VERSION.db `
    --image_path $DATASET_PATH/images `
    --ImageReader.single_camera 1

colmap sequential_matcher `
    --SiftMatching.multiple_models=1 `
    --SiftMatching.guided_matching=true `
    --SequentialMatching.quadratic_overlap=0 `
    --SequentialMatching.overlap=3 `
    --database_path $DATASET_PATH/database$VERSION.db

New-Item -ItemType Directory -Path "$DATASET_PATH\sparse$VERSION" -Force

colmap mapper `
    --database_path $DATASET_PATH\database$VERSION.db `
    --image_path $DATASET_PATH\images `
    --output_path $DATASET_PATH\sparse$VERSION

colmap bundle_adjuster `
    --input_path $DATASET_PATH\sparse$VERSION\0 `
    --output_path $DATASET_PATH\sparse$VERSION\0 `
    --BundleAdjustment.refine_principal_point 1
