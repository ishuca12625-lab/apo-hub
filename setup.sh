#!/data/data/com.termux/files/usr/bin/bash
set -e

echo ">>> 1. Termux 환경 및 의존성 패키지 설치 중..."
termux-wake-lock
pkg update -y && pkg upgrade -y
pkg install -y git cmake clang ninja python vulkan-loader-android curl

echo ">>> 2. llama.cpp 다운로드 및 Adreno 750 (Vulkan) 최적화 빌드 중..."
cd "$HOME"
if [ ! -d "llama.cpp" ]; then
  git clone https://github.com/ggerganov/llama.cpp.git
fi
cd llama.cpp
cmake -B build -DGGML_VULKAN=ON
cmake --build build --target llama-server -j8

echo ">>> 3. Gemma 4 E4B 멀티모달 모델 다운로드 중 (이어받기 지원)..."
mkdir -p "$HOME/models" && cd "$HOME/models"

# 대용량 모델 다운로드 (끊기면 다시 실행 시 이어받기)
curl -L -C - -O https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/gemma-4-E4B-it-Q4_K_M.gguf
curl -L -C - -O https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/mmproj-BF16.gguf

echo ">>> 4. 실행 권한 설정..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$SCRIPT_DIR/run_hub.sh"

# 바로 실행할 수 있도록 홈 디렉터리에 심볼릭 링크 생성
ln -sf "$SCRIPT_DIR/run_hub.sh" "$HOME/run_hub.sh"

echo ""
echo "=========================================================="
echo " 설정 완료! 아래 명령어로 즉시 실행할 수 있습니다:"
echo "   ~/run_hub.sh"
echo " 브라우저 주소: http://127.0.0.1:8080 (또는 http://<스마트폰IP>:8080)"
echo "=========================================================="
