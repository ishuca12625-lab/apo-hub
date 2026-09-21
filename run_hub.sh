#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock

# 저장소 경로 자동 탐색
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LLAMA_DIR="$HOME/llama.cpp"
MODEL_DIR="$HOME/models"

HOST="127.0.0.1"
NGL=0
THINKING="false"

# 인자 처리 (--lan, --gpu, --think)
for arg in "$@"; do
  case "$arg" in
    --lan|-l)
      HOST="0.0.0.0"
      ;;
    --gpu)
      NGL=99
      ;;
    --think|-th)
      THINKING="true"
      ;;
  esac
done

echo "=========================================================="
if [ "$HOST" = "0.0.0.0" ]; then
  echo " [네트워크] LAN 공유 모드 (Host: 0.0.0.0)"
  echo "   - 스마트폰 로컬 주소: http://127.0.0.1:8080"
  DEVICE_IP=$(ip -4 addr show wlan0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || true)
  if [ -n "$DEVICE_IP" ]; then
    echo "   - 외부 기기 접속 주소: http://$DEVICE_IP:8080"
  else
    echo "   - 외부 기기 접속 주소: http://<스마트폰IP>:8080"
  fi
else
  echo " [네트워크] 안전 로컬 모드 (Host: 127.0.0.1)"
  echo "   - 접속 주소: http://127.0.0.1:8080"
  echo "   - ※ Wi-Fi 공유 시: ~/run_hub.sh --lan"
fi

if [ "$NGL" -eq 0 ]; then
  echo " [가속 엔진] Snapdragon 8 Gen 3 CPU 모드 (Cortex-X4 6스레드 최적화)"
else
  echo " [가속 엔진] Adreno 750 Vulkan GPU 모드 (-ngl 99)"
fi

if [ "$THINKING" = "true" ]; then
  echo " [사고 모드] ON (심층 추론 활성화 - 수학/코딩/논리)"
else
  echo " [사고 모드] OFF (초고속 즉답 모드 - 일상 대화/비전)"
  echo "   - ※ 심층 추론 활성화 시: ~/run_hub.sh --think"
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
  --jinja \
  --chat-template-kwargs "{\"enable_thinking\":$THINKING}"
