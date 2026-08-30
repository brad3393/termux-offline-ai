#!/bin/bash
# Quick start guide for Termux AI Assistant
# Run this after setup.sh to test everything

echo "Termux AI Assistant - Quick Start Test"
echo "======================================="
echo ""

# Check Ollama installation
echo "[1/4] Checking Ollama installation..."
if command -v ollama &> /dev/null; then
    echo "✓ Ollama found at: $(which ollama)"
    ollama version
else
    echo "✗ Ollama not found. Run setup.sh first."
    exit 1
fi

echo ""

# Check model files
echo "[2/4] Checking model files..."
if [ -d "$HOME/ai-assistant/models" ]; then
    MODEL_COUNT=$(ls $HOME/ai-assistant/models/*.gguf 2>/dev/null | wc -l)
    if [ $MODEL_COUNT -gt 0 ]; then
        echo "✓ Found $MODEL_COUNT model file(s)"
        ls -lh $HOME/ai-assistant/models/*.gguf
    else
        echo "⚠ No GGUF models found in $HOME/ai-assistant/models/"
        echo "  Run: bash model-download.sh $HOME/ai-assistant/models"
    fi
else
    echo "✗ Model directory not found"
fi

echo ""

# Check Python dependencies
echo "[3/4] Checking Python dependencies..."
if python3 -c "import requests" 2>/dev/null; then
    echo "✓ Python requests library installed"
else
    echo "✗ Python requests library missing"
    echo "  Installing: pip3 install requests"
    pip3 install requests
fi

echo ""

# Check Micro editor
echo "[4/4] Checking Micro editor..."
if command -v micro &> /dev/null; then
    echo "✓ Micro editor installed at: $(which micro)"
else
    echo "✗ Micro editor not found. Installing..."
    apt install -y micro
fi

echo ""
echo "========================================"
echo "✓ Quick Start Test Complete!"
echo "========================================"
echo ""
echo "Next: Start Ollama and query the AI"
echo ""
echo "Terminal 1 - Start Ollama server:"
echo "  $ cd $HOME/ai-assistant/scripts"
echo "  $ ./start-ollama.sh"
echo ""
echo "Terminal 2 - Query the AI:"
echo "  $ python3 $HOME/ai-assistant/scripts/ai_interface.py"
echo ""
echo "Full documentation:"
echo "  $ cat $HOME/ai-assistant/README.md"
echo ""
