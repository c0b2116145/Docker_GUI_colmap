
# 引数チェック
if [ $# -lt 1 ]; then
  echo "Usage: $0 <IMAGES_PATH>"
  exit 1
fi
# 移動させたいHSIが画像ごとに入っているフォルダを指定
IMAGESPATH="$1"


for j in $(seq 400 10 700); do
  hs="$j"
  dir_path="$IMAGESPATH/image$hs"

  mkdir -p "$dir_path"
  chmod 777 "$dir_path"
  # 指定された画像パターンにマッチするファイルを移動
  find "$IMAGESPATH" -type d -regex ".*/image$hs\$" -prune -o \
       -type f -name "*$hs.*" -print0 | xargs -0 -I{} mv "{}" "$dir_path/"
done