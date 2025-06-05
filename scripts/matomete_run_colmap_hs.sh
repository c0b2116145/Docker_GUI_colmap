#!/bin/bash

set -euo pipefail

SCRIPT_PATH="./run_colmap_hs.sh"

# GPU使用量のしきい値（MiB）
GPU_FREE_THRESHOLD=1000  # 例：1000 MiB 未満になったら次へ進む
GPU_INDEX=0              # 使用するGPU番号（必要に応じて変更）

wait_for_gpu() {
  echo "🕒 Waiting for GPU $GPU_INDEX to become available..."
  while true; do
    # 現在の使用メモリを取得
    used=$(nvidia-smi --id=$GPU_INDEX --query-gpu=memory.used --format=csv,noheader,nounits | tr -d ' ')
    echo "   GPU $GPU_INDEX memory used: ${used} MiB"

    if [ "$used" -lt "$GPU_FREE_THRESHOLD" ]; then
      echo "✅ GPU $GPU_INDEX is free enough. Proceeding."
      break
    fi

    sleep 3
  done
}

# 対象データセット一覧
# DATASET_PATHS=(
#   "/datasets/nerf_llff_data_HSI/fern"
#   "/datasets/nerf_llff_data_HSI/flower"
#   "/datasets/nerf_llff_data_HSI/fortress"
#   "/datasets/nerf_llff_data_HSI/horns"
#   "/datasets/nerf_llff_data_HSI/leaves"
#   "/datasets/nerf_llff_data_HSI/orchids"
#   "/datasets/nerf_llff_data_HSI/room"
#   "/datasets/nerf_llff_data_HSI/trex"
# )

# VARSION_LIST=("_cuda" "_group" "_group_msi")

DATASET_PATHS=(
  "/datasets/NVS_Dataset/Static/MipNeRF360_HSI/flowers"
  "/datasets/NVS_Dataset/Static/MipNeRF360_HSI/treehill"
  "/datasets/NVS_Dataset/Static/tandt_db_HSI/db/drjohnson"
  "/datasets/NVS_Dataset/Static/tandt_db_HSI/db/playroom"
  "/datasets/NVS_Dataset/Static/tandt_db_HSI/tandt/train"
  "/datasets/NVS_Dataset/Static/tandt_db_HSI/tandt/truck"
)

VARSION_LIST=("_group" "_group_msi")

for path in "${DATASET_PATHS[@]}"; do

  # _HSIを除いたパスを生成
  clean_path="${path/_HSI/}"
  images8_src="${clean_path}/images_8"
  images8_link="${path}/images_8"

  # 🔍 チェック: リンク先の images_8 が存在するか
  if [ ! -d "$images8_src" ]; then
    echo "⚠️  Warning: Source directory not found: $images8_src"
    continue  # このデータセットはスキップ
  fi

  # 🔍 チェック: リンクがすでに存在しているか
  if [ -L "$images8_link" ]; then
    echo "✅ Symlink already exists: $images8_link"
  elif [ -e "$images8_link" ]; then
    echo "❌ Error: $images8_link exists but is not a symlink. Skipping."
    continue
  else
    echo "🔗 Creating symlink: $images8_src -> $images8_link"
    ln -s "$images8_src" "$images8_link"
  fi
  for version in "${VARSION_LIST[@]}"; do
    wait_for_gpu

    echo ">>> Processing: path=$path version=$version"
    bash "$SCRIPT_PATH" "$path" "$version"
    echo ">>> Done: $path"
    echo
  done
  # 🔻 内側の for が終わったあと、シンボリックリンクを削除
  if [ -L "$images8_link" ]; then
    echo "🧹 Removing symlink: $images8_link"
    unlink "$images8_link"
  fi
done

echo "🏁 All datasets processed successfully."