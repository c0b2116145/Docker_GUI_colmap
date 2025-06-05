param (
    [string]$DATASET_PATH
)

# Set-Location -Path $DATASET_PATH

colmap feature_extractor `
    --ImageReader.camera_model OPENCV `
    --database_path $DATASET_PATH/database_masked_new_m1.db `
    --image_path $DATASET_PATH/images `
    --ImageReader.mask_path $DATASET_PATH/masks_colmap `
    --ImageReader.single_camera 1
    # --SiftExtraction.use_gpu 0

colmap sequential_matcher `
    --SiftMatching.guided_matching=true `
    --database_path $DATASET_PATH/database_masked_new_m1.db `
    --SiftMatching.multiple_models=1
    # --SequentialMatching.quadratic_overlap=0 `
    # --SequentialMatching.overlap=3 `

New-Item -ItemType Directory -Path "$DATASET_PATH\sparse_masked_new_m1" -Force

colmap mapper `
    --database_path $DATASET_PATH\database_masked_new_m1.db `
    --image_path $DATASET_PATH\images `
    --output_path $DATASET_PATH\sparse_masked_new_m1

colmap bundle_adjuster `
    --input_path $DATASET_PATH\sparse_masked_new_m1\0 `
    --output_path $DATASET_PATH\sparse_masked_new_m1\0 `
    --BundleAdjustment.refine_principal_point 1
