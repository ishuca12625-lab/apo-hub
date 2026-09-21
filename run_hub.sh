#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock

# 저장소 경로 자동 탐색
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_DIR="$HOME/llama.cpp"
MODEL_DIR="$HOME/models"

echo "=== 아포칼립스 허브 가동 중 (Gemma 4 E4B) ==="
cd "$LLAMA_DIR"

./build/bin/llama-server \
  -m "$MODEL_DIR/gemma-4-E4B-it-Q4_K_M.gguf" \
  --mmproj "$MODEL_DIR/mmproj-BF16.gguf" \
  --host 0.0.0.0 \
  --port 8080 \
  -c 8192 \
  -ngl 99 \
  -t 6 \
  --chat-template-kwargs '{"enable_thinking":true}'
