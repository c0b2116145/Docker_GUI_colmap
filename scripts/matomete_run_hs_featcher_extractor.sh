#!/bin/bash

set -euo pipefail

SCRIPT_PATH="./run_hs_featcher_extractor.sh"

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
DATASET_PATHS=(
  "/datasets/nerf_llff_data_HSI/flower"
  "/datasets/nerf_llff_data_HSI/fortress"
  "/datasets/nerf_llff_data_HSI/horns"
  "/datasets/nerf_llff_data_HSI/leaves"
  "/datasets/nerf_llff_data_HSI/orchids"
  "/datasets/nerf_llff_data_HSI/room"
  "/datasets/nerf_llff_data_HSI/trex"
)

# DATASET_PATHS=(
#   "/datasets/NVS_Dataset/Static/MipNeRF360_HSI/flowers"
#   "/datasets/NVS_Dataset/Static/tandt_db_HSI/db/drjohnson"
#   "/datasets/NVS_Dataset/Static/tandt_db_HSI/db/playroom"
#   "/datasets/NVS_Dataset/Static/tandt_db_HSI/tandt/train"
#   "/datasets/NVS_Dataset/Static/tandt_db_HSI/tandt/truck"
# )

for path in "${DATASET_PATHS[@]}"; do
  wait_for_gpu

  echo ">>> Processing: $path"
  bash "$SCRIPT_PATH" "$path"
  echo ">>> Done: $path"
  echo
done

echo "🏁 All datasets processed successfully."
