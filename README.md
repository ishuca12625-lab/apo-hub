# 🌐 Apocalypse Hub (아포칼립스 허브)

> **Gemma 4 E4B 멀티모달 로컬 LLM 허브 (Termux / Android S24 Ultra 최적화)**
> 
> 기기를 초기화하거나 다른 안드로이드 단말기로 옮길 때도 명령어 한 줄로 5분 만에 모든 환경을 복구할 수 있는 원클릭 셋업 환경입니다.

---

## 🚀 빠른 시작 (원클릭 설치)

안드로이드 단말기의 **Termux** 앱에서 아래 명령어를 복사하여 붙여넣으면 설치부터 최적화 빌드, 모델 다운로드까지 한 번에 완료됩니다:

```bash
pkg update -y && pkg install -y git && git clone https://github.com/ishuca12625-lab/apo-hub.git && cd apo-hub && chmod +x setup.sh && ./setup.sh
```

---

## 📂 저장소 구조

```plaintext
apocalypse-hub/
├── setup.sh       # 패키지 설치, llama.cpp Vulkan 컴파일, 모델 다운로드 자동화 (중단 시 이어받기/스킵 지원)
├── run_hub.sh     # S24 Ultra 최적화 웹 서버 구동 스크립트 (안전 로컬 / LAN 공유 모드 지원)
└── README.md      # 사용 안내 문서
```

---

## ⚙️ 주요 특징

### 1. 중단 후 재실행 시 스마트 스킵 (이어받기 지원)
- **Vulkan 빌드 보존**: 3번 모델 다운로드 중 네트워크가 끊겨 `./setup.sh`를 다시 실행하더라도 이미 빌드된 `llama-server`는 건너뜁니다 (빌드를 처음부터 다시 하지 않음).
  - 강제로 재빌드하고 싶을 때만 `./setup.sh --rebuild` 옵션을 사용합니다.
- **대용량 모델 이어받기**: 모델 다운로드가 중단되었을 경우 다운로드되던 위치부터 자동으로 이어받습니다.

### 2. 안전한 접속 모드 (보안 강화)
기본적으로 공공장소/외부망 보안을 위해 **로컬 전용(`127.0.0.1`)**으로 구동되며, 필요할 때만 인자를 주어 동일 Wi-Fi에 공유할 수 있습니다:

- **안전 로컬 모드 (기본값)**:
  ```bash
  ~/run_hub.sh
  ```
  스마트폰 브라우저에서 `http://127.0.0.1:8080` 접속 (외부 노출 완전 차단)

- **LAN 공유 모드 (PC / 태블릿과 공유 시)**:
  ```bash
  ~/run_hub.sh --lan
  ```
  동일 Wi-Fi 내 다른 기기에서 `http://<스마트폰-IP>:8080`으로 접속 가능 (구동 시 스크립트가 기기 IP 자동 안내)

---

## 💡 성능 최적화 옵션 (S24 Ultra / Adreno 750)
- **Vulkan 가속**: Adreno 750 GPU를 100% 활용하는 하드웨어 가속 (`-ngl 99`)
- **최적 스레드**: 빅/미들 코어 집중 할당 (`-t 6`)
- **컨텍스트 길이**: 8,192 토큰 (`-c 8192`)
- **Gemma 4 Thinking 모드**: 사고 엔진 활성화 (`--chat-template-kwargs '{"enable_thinking":true}'`)
- **절전 방지**: 백그라운드 절전 모드로 인한 프로세스 킬 방지 (`termux-wake-lock`)
