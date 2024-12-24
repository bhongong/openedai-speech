#!/bin/bash

[ -f speech.env ] && . speech.env

echo "First startup may download 2GB of speech models. Please wait."

bash download_voices_tts-1.sh
bash download_voices_tts-1-hd.sh $PRELOAD_MODEL

# Use SERVER_PORT from environment, default to 8000 if not set
PORT=${SERVER_PORT:-8000}

# Start the server on the specified port
uvicorn speech:app --host 0.0.0.0 --port $PORT
