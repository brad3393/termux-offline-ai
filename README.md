# Termux 100% Offline AI Assistant

**Complete local AI infrastructure for Android** - No cloud, no internet required after setup.

![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Android%20ARM64-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

This repository provides a complete, production-ready setup to run an AI assistant **entirely offline** on Android via Termux. Everything runs locally:

- **Ollama** - LLM inference engine (optimized ARM64 build)
- **Qwen2.5-Coder** - Lightweight AI model (~1.5B parameters, q4_k_m quantization)
- **Python CLI Interface** - Query the AI from terminal
- **Micro Editor** - Edit and create scripts directly in Termux

## Key Features

✅ **100% Offline** - No cloud API calls, no internet dependency  
✅ **Local Inference** - Run inference on your device CPU  
✅ **Production Optimized** - Based on DioNanos/ollama-termux (EOL)  
✅ **ARM64 Native** - Fully optimized for Android processors  
✅ **Lightweight Models** - 1.5-3B parameter models for mobile  
✅ **Easy Setup** - Single bash script installs everything  
✅ **Python API** - Build custom AI tools and scripts  
✅ **No Dependencies** - All components bundled for offline use  

## Quick Start (5 Minutes)

### Prerequisites

- Termux installed on Android device
- 4GB+ free storage (for Ollama + model)
- 2GB+ RAM (1.5GB for model, 0.5GB buffer)
- ARM64 processor (99% of Android devices)

### Installation

```bash
# Clone or download this repository
git clone https://github.com/brad3393/termux-offline-ai.git
cd termux-offline-ai

# Run the complete setup (requires ~10-30 minutes)
bash setup.sh

# Verify everything works
bash quick-start.sh
```

### Usage

**Terminal 1 - Start Ollama Server:**
```bash
cd $HOME/ai-assistant/scripts
./start-ollama.sh
```

**Terminal 2 - Query the AI:**
```bash
# Single query
python3 $HOME/ai-assistant/scripts/ai_interface.py "How do I write a Python function?"

# Interactive mode
python3 $HOME/ai-assistant/scripts/ai_interface.py
```

**Edit Python Skills:**
```bash
micro $HOME/ai-assistant/scripts/ai_interface.py
```

## Architecture

```
Android Device (Termux)
├── Ollama Server (Port 11434)
│   ├── GGUF Model: Qwen2.5-Coder-1.5B
│   └── Local Inference Engine
├── Python CLI Interface
│   ├── ai_interface.py (Query tool)
│   └── Custom skill scripts
└── Micro Editor (Script development)
```

## Directory Structure

```
.
├── setup.sh                    # Main installation script
├── ollama-install.sh           # Alternative Ollama installer
├── model-download.sh           # Download additional GGUF models
├── quick-start.sh              # Verification script
├── README.md                   # This file
└── LICENSE

~/.local/ollama/
└── models/                     # Ollama model cache

~/ai-assistant/
├── models/
│   └── qwen2.5-coder-1.5b-instruct-q4_k_m.gguf
├── scripts/
│   ├── start-ollama.sh         # Start server
│   ├── ai_interface.py         # Python CLI
│   └── ollama_modelfile        # Model config
├── README.md
└── .env                        # Configuration
```

## Components

### Ollama (Inference Engine)
- **Repository**: [DioNanos/ollama-termux](https://github.com/DioNanos/ollama-termux)
- **Language**: Go
- **License**: MIT
- **Purpose**: Local LLM inference without cloud
- **Status**: Archived (maintained by community)

### Qwen2.5-Coder Model
- **Repository**: [Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF](https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF)
- **Size**: ~1.2GB (q4_k_m quantization)
- **Specialty**: Coding assistance, technical questions
- **Context**: 32k tokens
- **License**: Alibaba License

### Micro Editor
- **Repository**: [micro-editor/micro](https://github.com/micro-editor/micro)
- **Language**: Go
- **License**: MIT
- **Purpose**: Terminal text editor for script development

## Configuration

Edit `~/.ollama/config.env` to customize:

```bash
# Model storage location
OLLAMA_MODELS=$HOME/.local/ollama/models

# Server host:port
OLLAMA_HOST=127.0.0.1:11434

# Parallel requests (keep 1 for mobile)
OLLAMA_NUM_PARALLEL=1

# CPU threads (auto-detected, adjust if needed)
OLLAMA_NUM_THREAD=4

# Memory fraction (0.0-1.0, lower = more stable)
OLLAMA_MEMORY_FRACTION=0.75
```

## Python API

### Basic Query

```python
import requests
import json

def query_ai(prompt, model="qwen2.5-coder:1.5b"):
    url = "http://127.0.0.1:11434/api/generate"
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0.7}
    }
    response = requests.post(url, json=payload, timeout=300)
    return response.json()["response"]

# Use it
result = query_ai("What is a list comprehension in Python?")
print(result)
```

### Streaming Response

```python
response = requests.post(url, json=payload, stream=True, timeout=300)
for line in response.iter_lines():
    if line:
        data = json.loads(line)
        print(data['response'], end='', flush=True)
```

## Troubleshooting

### Ollama won't start

**Problem**: `command not found: ollama`

**Solutions**:
1. Run `setup.sh` again
2. Check PATH: `echo $PREFIX/bin`
3. Reinstall: `bash ollama-install.sh`

### Model download timeout

**Problem**: Download stuck on slow networks

**Solutions**:
1. Use WiFi instead of mobile data
2. Download manually from [Hugging Face](https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF)
3. Place .gguf file in: `$HOME/ai-assistant/models/`
4. Resume with: `curl -C - [url] -o file.gguf`

### Python connection error

**Problem**: `Connection refused` when querying AI

**Solutions**:
1. Start Ollama: `./scripts/start-ollama.sh` (in another terminal)
2. Check status: `curl http://127.0.0.1:11434/api/tags`
3. Ensure localhost is accessible
4. Check if port 11434 is in use: `lsof -i :11434`

### Out of memory errors

**Problem**: `OOM killer` when running inference

**Solutions**:
1. Use smaller model: `qwen2.5-coder-1.5b` (not 3b)
2. Reduce `OLLAMA_MEMORY_FRACTION` in config.env
3. Close other apps
4. Increase swap space (if available)
5. Use a quantized model (q4_k_m, q5_k_m)

### Slow inference

**Problem**: Responses take too long

**Causes & Solutions**:
- Limited CPU: Reduce `num_predict` in inference
- Limited RAM: Close background apps, use smaller model
- Storage on microSD: Move to internal storage if possible
- USB storage: Use built-in storage, not external

## Performance Benchmarks

On typical Android device (Snapdragon 888, 8GB RAM):

| Model | Size | Load Time | Tokens/Sec | RAM Usage |
|-------|------|-----------|------------|----------|
| Qwen2.5-Coder-1.5B q4 | 1.2GB | 3-5s | 2-4 t/s | 1.8GB |
| Qwen2.5-Coder-3B q4 | 2.4GB | 5-8s | 1-2 t/s | 3.2GB |
| Mistral-7B q4 | 4.3GB | 8-12s | 0.5-1 t/s | 5.5GB |

*(Results vary by device CPU, memory, and storage speed)*

## Advanced Usage

### Build Custom Ollama Modelfile

```bash
cat > Modelfile << 'EOF'
FROM /path/to/model.gguf

TEMPERATURE 0.5
TOP_P 0.95
TOP_K 50
NUM_PREDICT 512

SYSTEM You are a Python expert assistant.
EOF

ollama create my-python-expert -f Modelfile
ollama run my-python-expert
```

### Add Multiple Models

```bash
# Download different models
bash model-download.sh $HOME/ai-assistant/models

# Each model registered separately in Ollama
ollama run qwen2.5-coder:1.5b
ollama run mistral:7b
```

### Automated Tasks

```bash
#!/bin/bash
# daily_analysis.sh - Run daily AI analysis

PROMPT="Analyze my development productivity today"
RESULT=$(python3 $HOME/ai-assistant/scripts/ai_interface.py "$PROMPT")

echo "$RESULT" >> $HOME/ai-assistant/daily_logs.txt
echo "Analysis logged at $(date)"
```

## API Reference

### Ollama API Endpoints

**Generate (streaming)**
```
POST /api/generate
{
  "model": "qwen2.5-coder:1.5b",
  "prompt": "your prompt",
  "stream": true,
  "options": {
    "temperature": 0.7,
    "top_p": 0.9,
    "top_k": 40
  }
}
```

**List Models**
```
GET /api/tags
```

**Pull Model**
```
POST /api/pull
{"name": "model-name"}
```

**Full API**: https://github.com/ollama/ollama/blob/main/docs/api.md

## Security Considerations

✅ **All processing is local** - No data leaves your device  
✅ **No internet required** - Complete offline operation  
✅ **No authentication** - Server binds to localhost only  
✅ **Open source** - All components are auditable  

**Network Access**: By default, only localhost (127.0.0.1) can access Ollama.  
To allow network access, modify `OLLAMA_HOST` in config.env to `0.0.0.0:11434` (not recommended for security).

## Limitations

- Mobile inference is slower than desktop (1-4 tokens/sec vs 10-100 t/s)
- Large models (7B+) require high-end devices with abundant RAM
- Long conversations may cause memory issues on lower-end devices
- Ollama repository is archived; community maintenance only
- Model quantization reduces quality vs full precision

## Future Improvements

- [ ] Web UI interface for Ollama
- [ ] Function calling / tool use support
- [ ] Local document retrieval (RAG)
- [ ] Voice input/output
- [ ] Multi-model orchestration
- [ ] Persistent memory/chat history

## Contributing

Contributions welcome! Areas:

- Alternative model setups
- Performance optimizations
- UI improvements
- Documentation enhancements
- Bug reports and fixes

## License

MIT License - See LICENSE file

## References

### Key Repositories
- [DioNanos/ollama-termux](https://github.com/DioNanos/ollama-termux) - Ollama for Android
- [ollama/ollama](https://github.com/ollama/ollama) - Original Ollama project
- [Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF](https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF) - Model weights
- [micro-editor/micro](https://github.com/micro-editor/micro) - Text editor

### Documentation
- [Termux Wiki](https://wiki.termux.com/)
- [Ollama Documentation](https://github.com/ollama/ollama#readme)
- [GGUF Format](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)
- [Android ARM64 Architecture](https://developer.android.com/ndk/guides/arch-abi)

### Community
- [Termux GitHub Discussions](https://github.com/termux/termux-app/discussions)
- [Ollama GitHub Issues](https://github.com/ollama/ollama/issues)
- [Qwen GitHub Discussions](https://github.com/QwenLM/Qwen/discussions)

## Support

For issues and questions:

1. Check [Troubleshooting](#troubleshooting) section
2. Review existing GitHub issues
3. Create a new issue with:
   - Device model and Android version
   - Output of `uname -a` in Termux
   - Error messages and logs
   - Steps to reproduce

## Disclaimer

This project is provided as-is for educational and personal use. The author is not responsible for:
- Data loss or corruption
- Device damage or battery drain
- Performance issues or system crashes
- Compatibility with specific devices

Use at your own risk. Test on a spare device first if possible.

---

**Made with ❤️ for offline AI enthusiasts**

Last updated: 2026-08-30  
Version: 1.0.0
