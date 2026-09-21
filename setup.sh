#!/data/data/com.termux/files/usr/bin/bash
set -e

echo ">>> 1. Termux 환경 및 의존성 패키지 확인 중..."
termux-wake-lock

# 필수 실행 바이너리 및 핵심 헤더 존재 여부 확인
REQUIRED_BINS="git cmake clang ninja python glslc curl vulkaninfo"
MISSING_DEPS=0

for bin in $REQUIRED_BINS; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    MISSING_DEPS=1
    break
  fi
done

if [ ! -f "$PREFIX/include/vulkan/vulkan.h" ] || [ ! -f "$PREFIX/include/spirv/unified1/spirv.h" ]; then
  MISSING_DEPS=1
fi

if [ "$MISSING_DEPS" -eq 0 ] && [ "$1" != "--update-pkgs" ]; then
  echo "✔ 필수 패키지와 헤더가 이미 설치되어 있어 1단계를 건너뜁니다."
else
  echo ">>> 필요한 패키지를 설치 및 업데이트합니다..."
  pkg update -y
  pkg install -y git cmake clang ninja python vulkan-loader-android vulkan-headers vulkan-tools glslang spirv-headers spirv-tools shaderc curl
fi

echo ">>> 2. llama.cpp 확인 및 Adreno 750 (Vulkan) 최적화 빌드..."
cd "$HOME"
if [ ! -d "llama.cpp" ]; then
  git clone https://github.com/ggml-org/llama.cpp.git
fi
cd llama.cpp

# 이미 빌드되어 있고 --rebuild 옵션이 없으면 빌드 건너뛰기
if [ -f "build/bin/llama-server" ] && [ "$1" != "--rebuild" ]; then
  echo "✔ llama-server가 이미 빌드되어 있어 2단계를 건너뜁니다."
  echo "  (강제 재빌드를 원할 경우: ./setup.sh --rebuild)"
else
  echo ">>> llama.cpp 빌드를 시작합니다 (Vulkan 가속)..."
  rm -rf build

  # Android 시스템 Vulkan 라이브러리 및 헤더 경로 지정
  VULKAN_LIB=""
  if [ -f "/system/lib64/libvulkan.so" ]; then
    VULKAN_LIB="/system/lib64/libvulkan.so"
  elif [ -f "$PREFIX/lib/libvulkan.so" ]; then
    VULKAN_LIB="$PREFIX/lib/libvulkan.so"
  elif [ -f "/system/lib/libvulkan.so" ]; then
    VULKAN_LIB="/system/lib/libvulkan.so"
  fi

  CMAKE_FLAGS="-B build -DGGML_VULKAN=ON -DCMAKE_BUILD_TYPE=Release -DVulkan_INCLUDE_DIR=$PREFIX/include"
  if [ -n "$VULKAN_LIB" ]; then
    CMAKE_FLAGS="$CMAKE_FLAGS -DVulkan_LIBRARY=$VULKAN_LIB"
  fi

  cmake $CMAKE_FLAGS
  cmake --build build --target llama-server -j8
fi

echo ">>> 3. Gemma 4 E4B 멀티모달 모델 확인 및 다운로드 (이어받기 지원)..."
mkdir -p "$HOME/models" && cd "$HOME/models"

MODEL_FILE="gemma-4-E4B-it-Q4_K_M.gguf"
MMPROJ_FILE="mmproj-BF16.gguf"

# 1GB 이상 파일이 이미 온전히 다운로드된 경우 스킵
if [ -f "$MODEL_FILE" ] && [ $(wc -c < "$MODEL_FILE") -gt 1000000000 ]; then
  echo "✔ $MODEL_FILE 모델이 이미 준비되어 있습니다."
else
  echo ">>> $MODEL_FILE 다운로드 중 (이어받기 활성화)..."
  curl -L -C - -O "https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/$MODEL_FILE"
fi

if [ -f "$MMPROJ_FILE" ] && [ $(wc -c < "$MMPROJ_FILE") -gt 100000000 ]; then
  echo "✔ $MMPROJ_FILE 프로젝터가 이미 준비되어 있습니다."
else
  echo ">>> $MMPROJ_FILE 다운로드 중 (이어받기 활성화)..."
  curl -L -C - -O "https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF/resolve/main/$MMPROJ_FILE"
fi

echo ">>> 4. 실행 권한 설정 및 심볼릭 링크 생성..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$SCRIPT_DIR/run_hub.sh"
ln -sf "$SCRIPT_DIR/run_hub.sh" "$HOME/run_hub.sh"

echo ""
echo "=========================================================="
echo " 설정 완료! 아래 명령어로 즉시 실행할 수 있습니다:"
echo "   ~/run_hub.sh          # 로컬 전용 (안전 모드, 127.0.0.1)"
echo "   ~/run_hub.sh --lan    # Wi-Fi 공유 (PC/태블릿 접속용, 0.0.0.0)"
echo "=========================================================="
