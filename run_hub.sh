#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock

# 저장소 경로 자동 탐색
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_DIR="$HOME/llama.cpp"
MODEL_DIR="$HOME/models"

HOST="127.0.0.1"
NGL=0

# 인자 처리 (--lan, --gpu)
for arg in "$@"; do
  case "$arg" in
    --lan|-l)
      HOST="0.0.0.0"
      ;;
    --gpu)
      NGL=99
      ;;
  esac
done

echo "=========================================================="
if [ "$HOST" = "0.0.0.0" ]; then
  echo " [LAN 공유 모드] 동일 Wi-Fi 기기에서 접속 가능합니다."
  echo " 스마트폰 로컬 주소: http://127.0.0.1:8080"
  DEVICE_IP=$(ip -4 addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || true)
  if [ -n "$DEVICE_IP" ]; then
    echo " 외부 기기 접속 주소: http://$DEVICE_IP:8080"
  else
    echo " 외부 기기 접속 주소: http://<스마트폰IP>:8080"
  fi
else
  echo " [안전 로컬 모드] 스마트폰 단말기 전용 (Host: 127.0.0.1)"
  echo " 접속 주소: http://127.0.0.1:8080"
  echo " ※ PC/태블릿과 공유하려면: ~/run_hub.sh --lan"
fi

if [ "$NGL" -eq 0 ]; then
  echo " [가속 엔진] Snapdragon 8 Gen 3 CPU 모드 (Cortex-X4 6스레드)"
  echo " ※ Adreno Vulkan 드라이버 셰이더 에러를 방지하기 위해 CPU 모드로 가동합니다."
else
  echo " [가속 엔진] Adreno 750 Vulkan GPU 오프로드 모드 (-ngl 99)"
fi
echo "=========================================================="

echo "=== 아포칼립스 허브 가동 중 (Gemma 4 E4B) ==="
cd "$LLAMA_DIR"

./build/bin/llama-server \
  -m "$MODEL_DIR/gemma-4-E4B-it-Q4_K_M.gguf" \
  --mmproj "$MODEL_DIR/mmproj-BF16.gguf" \
  --host "$HOST" \
  --port 8080 \
  -c 8192 \
  -ngl "$NGL" \
  -t 6 \
  --chat-template-kwargs '{"enable_thinking":true}'
