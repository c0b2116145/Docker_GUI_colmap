#!/bin/bash

# 使用方法チェック
if [ $# -lt 1 ]; then
  echo "Usage: $0 <DATASET_PATH> [version]"
  exit 1
fi

DATASET_PATH="$1"
version="${2:-}"


# exhaustive_matcher
colmap exhaustive_matcher \
    --database_path "$DATASET_PATH/database${version}.db" \
    --SiftMatching.use_gpu 1
    # --SiftMatching.max_ratio 1.1 \

# sparse出力ディレクトリ作成
mkdir -p "$DATASET_PATH/sparse${version}"
chmod 777 "$DATASET_PATH/sparse${version}"

# mapper
#--Mapper.init_min_tri_angle 4はLLFFデータセットのfernシーンのようにカメラのの回転があまりないものだとやるといいかも
colmap mapper \
    --database_path "$DATASET_PATH/database${version}.db" \
    --image_path "$DATASET_PATH/images_8" \
    --output_path "$DATASET_PATH/sparse${version}" \
    --Mapper.init_min_tri_angle 4 \
    --Mapper.multiple_models 0
    # --Mapper.num_threads 16 \
    # --Mapper.extract_colors 0