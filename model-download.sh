#!/bin/bash
# Standalone GGUF model downloader for various AI models
# Supports: Qwen2.5-Coder, Mistral, Llama2, and others

set -e

MODELS_DIR="${1:-.}"
mkdir -p "$MODELS_DIR"

echo "GGUF Model Download Tool for Termux"
echo "====================================="
echo ""
echo "Available Models:"
echo "1. Qwen2.5-Coder-1.5B (Recommended - Fast, Coding)"
echo "2. Qwen2.5-Coder-3B (More Powerful)"
echo "3. Mistral-7B-Instruct-v0.2 (General Purpose)"
echo "4. Custom URL"
echo ""
read -p "Select model (1-4): " choice

case $choice in
    1)
        MODEL_NAME="qwen2.5-coder-1.5b-instruct-q4_k_m"
        MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-Coder-1.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-1.5b-instruct-q4_k_m.gguf"
        ;;
    2)
        MODEL_NAME="qwen2.5-coder-3b-instruct-q4_k_m"
        MODEL_URL="https://huggingface.co/Qwen/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/qwen2.5-coder-3b-instruct-q4_k_m.gguf"
        ;;
    3)
        MODEL_NAME="mistral-7b-instruct-v0.2-q4_k_m"
        MODEL_URL="https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf"
        ;;
    4)
        read -p "Enter model URL: " MODEL_URL
        read -p "Enter model name: " MODEL_NAME
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Downloading: $MODEL_NAME"
echo "URL: $MODEL_URL"
echo "Destination: $MODELS_DIR/$MODEL_NAME.gguf"
echo ""
echo "Note: Large models (1-7GB) may take 10-60 minutes on mobile networks."
read -p "Continue? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -L --progress-bar --max-time 7200 \
        "$MODEL_URL" \
        -o "$MODELS_DIR/$MODEL_NAME.gguf"
    
    if [ -f "$MODELS_DIR/$MODEL_NAME.gguf" ]; then
        SIZE=$(du -h "$MODELS_DIR/$MODEL_NAME.gguf" | cut -f1)
        echo ""
        echo "✓ Downloaded successfully!"
        echo "File size: $SIZE"
        echo "Location: $MODELS_DIR/$MODEL_NAME.gguf"
    else
        echo "Download failed"
        exit 1
    fi
else
    echo "Cancelled"
fi
