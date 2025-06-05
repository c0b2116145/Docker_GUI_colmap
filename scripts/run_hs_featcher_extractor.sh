#!/bin/bash

# 引数チェック
if [ $# -lt 1 ]; then
  echo "Usage: $0 <DATASET_PATH>"
  exit 1
fi

DATASET_PATH="$1"

# database_hs ディレクトリを作成
database_dir="$DATASET_PATH/database_hs"
mkdir -p "$database_dir"

# 400〜700まで10刻みで処理
for j in $(seq 400 10 700); do
  hs="$j"
  path_hs="$DATASET_PATH/images/image$hs"

  colmap feature_extractor \
      --database_path "$database_dir/database_$hs.db" \
      --image_path "$path_hs" \
      --ImageReader.single_camera 1 \
      --ImageReader.camera_model PINHOLE \
      --SiftExtraction.use_gpu 1
done
