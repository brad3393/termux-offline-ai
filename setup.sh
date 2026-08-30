#!/bin/bash
# Termux 100% Offline AI Assistant Setup Script
# Installs Ollama, AI Models (GGUF), and Terminal Editor for Android ARM64
# Author: Copilot Configuration
# Date: 2026-08-30

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Termux 100% Offline AI Setup${NC}"
echo -e "${BLUE}Android ARM64 | Ollama | GGUF Models${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if running on Termux
if [ ! -d "$PREFIX" ]; then
    echo -e "${RED}Error: This script must run on Termux${NC}"
    exit 1
fi

# Update package manager
echo -e "${YELLOW}[1/5] Updating Termux packages...${NC}"
apt update && apt upgrade -y

# Install dependencies
echo -e "${YELLOW}[2/5] Installing dependencies...${NC}"
apt install -y \
    curl wget git git-lfs \
    clang make cmake \
    golang python3 python3-pip \
    libssl-dev libffi-dev \
    pkg-config \
    micro

# Create working directory
echo -e "${YELLOW}[3/5] Setting up directories...${NC}"
mkdir -p $HOME/.local/ollama/models
mkdir -p $HOME/ai-assistant/scripts
mkdir -p $HOME/ai-assistant/models

# Install Ollama for Termux
echo -e "${YELLOW}[4/5] Installing Ollama for Termux (ARM64)...${NC}"
cd $HOME

# Option 1: From prebuilt release (faster)
echo "Downloading Ollama prebuilt binary..."
RELEASE_URL="https://github.com/DioNanos/ollama-termux/releases/download"
LATEST_RELEASE=$(curl -s https://api.github.com/repos/DioNanos/ollama-termux/releases/latest | grep tag_name | cut -d'"' -f4)

if [ -z "$LATEST_RELEASE" ]; then
    echo -e "${YELLOW}Warning: Could not fetch latest Ollama release. Building from source...${NC}"
    # Option 2: Build from source
    git clone https://github.com/DioNanos/ollama-termux.git
    cd ollama-termux
    go build -o ollama ./cmd/ollama
    mv ollama $PREFIX/bin/
else
    OLLAMA_BINARY="ollama-android-arm64"
    wget -q "${RELEASE_URL}/${LATEST_RELEASE}/${OLLAMA_BINARY}" -O $PREFIX/bin/ollama
    chmod +x $PREFIX/bin/ollama
fi

echo -e "${GREEN}✓ Ollama installed${NC}"

# Download GGUF Model (Qwen2.5-Coder-1.5B lightweight)
echo -e "${YELLOW}[5/5] Downloading AI Model (Qwen2.5-Coder-1.5B GGUF)...${NC}"
echo "Setting up Git LFS for model download..."
git lfs install

cd $HOME/ai-assistant/models

# Try downloading from Hugging Face mirror
echo "Fetching Qwen2.5-Coder-1.5B-Instruct GGUF model..."
MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main"
MODEL_FILE="qwen2.5-coder-1.5b-instruct-q4_k_m.gguf"

# Use curl with retry logic for large file download
if ! curl -L --max-time 3600 --retry 3 \
    "${MODEL_URL}/${MODEL_FILE}" \
    -o "$MODEL_FILE" 2>/dev/null; then
    echo -e "${YELLOW}Model download in progress. This may take 10-30 minutes on mobile networks.${NC}"
    # Alternative: Direct GitHub release or mirror
    echo "Retrying with alternative mirror..."
    curl -L --max-time 3600 \
        "https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf" \
        -o "$MODEL_FILE"
fi

if [ -f "$MODEL_FILE" ]; then
    echo -e "${GREEN}✓ Model downloaded: $MODEL_FILE${NC}"
else
    echo -e "${RED}Model download failed. You can manually add GGUF files to: $HOME/ai-assistant/models${NC}"
fi

# Create Ollama configuration
echo -e "${YELLOW}Configuring Ollama...${NC}"
mkdir -p $HOME/.ollama

cat > $HOME/.ollama/config.env << 'EOF'
# Ollama Configuration for Termux
OLLAMA_MODELS=$HOME/.local/ollama/models
OLLAMA_HOST=127.0.0.1:11434
OLLAMA_NUM_PARALLEL=1
OLLAMA_NUM_THREAD=$(nproc)
OLLAMA_MEMORY_FRACTION=0.75
EOF

# Register model with Ollama
echo -e "${YELLOW}Registering model with Ollama...${NC}"

cat > $HOME/ai-assistant/scripts/ollama_modelfile << 'EOF'
FROM $HOME/ai-assistant/models/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf

TEMPLATURE 0.7
TOP_P 0.9
TOP_K 40

SYSTEM You are a helpful AI coding assistant running locally on Android. Respond concisely and accurately.
EOF

# Create startup script
echo -e "${YELLOW}Creating startup script...${NC}"

cat > $HOME/ai-assistant/scripts/start-ollama.sh << 'EOF'
#!/bin/bash
# Start Ollama server locally

source $HOME/.ollama/config.env

echo "Starting Ollama server..."
echo "Model location: $OLLAMA_MODELS"
echo "Host: $OLLAMA_HOST"
echo "Threads: $OLLAMA_NUM_THREAD"

# Start Ollama in background
ollama serve &
OLLAMA_PID=$!

echo "Ollama started (PID: $OLLAMA_PID)"
echo "Waiting for server to be ready..."
sleep 3

# Load model (optional)
echo "Loading Qwen2.5-Coder model..."
ollama run qwen2.5-coder:1.5b

EOF

chmod +x $HOME/ai-assistant/scripts/start-ollama.sh

# Create Python AI interface
echo -e "${YELLOW}Creating Python AI interface...${NC}"

cat > $HOME/ai-assistant/scripts/ai_interface.py << 'EOF'
#!/usr/bin/env python3
"""
Local AI Assistant Interface for Termux
Communicates with Ollama running on localhost:11434
"""

import requests
import json
import sys

OLLAMA_HOST = "http://127.0.0.1:11434"
MODEL = "qwen2.5-coder:1.5b"

def query_ai(prompt):
    """
    Send a prompt to the local AI model
    """
    url = f"{OLLAMA_HOST}/api/generate"
    
    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": True,
        "options": {
            "temperature": 0.7,
            "top_p": 0.9,
            "top_k": 40,
            "num_predict": 512
        }
    }
    
    try:
        response = requests.post(url, json=payload, timeout=300)
        response.raise_for_status()
        
        # Stream response
        for line in response.iter_lines():
            if line:
                data = json.loads(line)
                if 'response' in data:
                    print(data['response'], end='', flush=True)
        print()  # Newline at end
        
    except requests.exceptions.ConnectionError:
        print("Error: Cannot connect to Ollama server.")
        print(f"Make sure Ollama is running: {OLLAMA_HOST}")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        prompt = " ".join(sys.argv[1:])
    else:
        print(f"Local AI Assistant (Model: {MODEL})")
        print("Type your question (Ctrl+C to exit):\n")
        prompt = input("> ")
    
    query_ai(prompt)
EOF

chmod +x $HOME/ai-assistant/scripts/ai_interface.py

# Install Python requirements
echo -e "${YELLOW}Installing Python dependencies...${NC}"
pip3 install requests

# Create comprehensive README
echo -e "${YELLOW}Creating documentation...${NC}"

cat > $HOME/ai-assistant/README.md << 'EOF'
# Termux 100% Offline AI Assistant

Complete local AI setup for Android running on Ollama + GGUF models.

## Components

1. **Ollama** - Local LLM inference engine optimized for ARM64
2. **Qwen2.5-Coder-1.5B** - Lightweight coding-focused AI model (GGUF format)
3. **Micro** - Terminal text editor for script editing
4. **Python Interface** - CLI tool to query the local AI

## Quick Start

### 1. Start Ollama Server

```bash
./scripts/start-ollama.sh
```

This starts Ollama and loads the model. Server runs on `localhost:11434`.

### 2. Query AI from Another Terminal

```bash
# Simple query
python3 ./scripts/ai_interface.py "How do I read files in Python?"

# Interactive mode
python3 ./scripts/ai_interface.py
```

### 3. Edit Files with Micro

```bash
micro scripts/my_script.py
```

## Directory Structure

```
~/.local/ollama/models/          # Ollama model cache
~/ai-assistant/
  ├── models/                    # GGUF model files
  ├── scripts/
  │   ├── start-ollama.sh        # Start Ollama server
  │   ├── ai_interface.py        # Python AI CLI
  │   └── ollama_modelfile       # Model configuration
  └── README.md
```

## Model Information

- **Model**: Qwen2.5-Coder-1.5B-Instruct
- **Format**: GGUF (quantized q4_k_m)
- **Size**: ~1.2GB
- **Performance**: Optimized for ARM64 devices
- **Specialty**: Coding assistance and technical questions

## Troubleshooting

### Ollama won't start
- Ensure you have at least 2GB free storage
- Check if port 11434 is available: `netstat -tuln | grep 11434`
- Verify Go installation: `go version`

### Model download stuck
- Mobile networks may timeout on large downloads
- Resume manually: download GGUF from Hugging Face and place in `~/ai-assistant/models/`
- Use WiFi for faster download

### Python connection error
- Verify Ollama is running: `curl http://127.0.0.1:11434/api/tags`
- Check firewall/SELinux settings
- Ensure localhost is accessible

## Advanced Configuration

Edit `~/.ollama/config.env` to adjust:
- Thread count
- Memory usage
- Model paths
- Host/port settings

## Available Commands

```bash
# Start Ollama server
ollama serve

# List available models
ollama list

# Direct model interaction (if model is loaded)
ollama run qwen2.5-coder:1.5b "Your prompt here"

# Check Ollama status
curl http://127.0.0.1:11434/api/tags
```

## Performance Tips

1. Keep only one model loaded at a time
2. Close other apps to maximize RAM
3. Use q4_k_m quantization (better speed/quality balance)
4. Set `OLLAMA_NUM_THREAD` to your CPU core count
5. Run on AC power when possible

## License & Attribution

- **Ollama**: Apache 2.0 - https://github.com/ollama/ollama
- **Ollama-Termux**: MIT - https://github.com/DioNanos/ollama-termux
- **Qwen Model**: Alibaba Qwen Team
- **Micro Editor**: MIT - https://github.com/micro-editor/micro

## References

- Ollama Repository: https://github.com/DioNanos/ollama-termux
- Qwen Models: https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF
- Micro Editor: https://github.com/micro-editor/micro
- Termux Wiki: https://wiki.termux.com/

EOF

# Final summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Next Steps:${NC}"
echo "1. Start Ollama server:"
echo -e "   ${YELLOW}cd $HOME/ai-assistant/scripts && ./start-ollama.sh${NC}"
echo ""
echo "2. In another terminal, query the AI:"
echo -e "   ${YELLOW}python3 $HOME/ai-assistant/scripts/ai_interface.py\"Your question\"${NC}"
echo ""
echo "3. Edit Python skill files:"
echo -e "   ${YELLOW}micro $HOME/ai-assistant/scripts/ai_interface.py${NC}"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo -e "   ${YELLOW}$HOME/ai-assistant/README.md${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo -e "   ${YELLOW}$HOME/.ollama/config.env${NC}"
echo ""
echo -e "${GREEN}100% Offline - No cloud dependencies!${NC}\n"
