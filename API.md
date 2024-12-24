# OpenedAI Speech API Endpoints

## `/v1/audio/speech` - Generate Speech

### Endpoint Description
Generates speech from input text using text-to-speech (TTS) technology.

### Request Parameters
- `model` (string, optional): 
  - Supported values: "tts-1", "tts-1-hd"
  - Default: "tts-1"

- `input` (string, required): 
  - The text to convert to speech
  - Must not be empty after preprocessing

- `voice` (string, optional):
  - Supported voices: "alloy", "echo", "fable", "onyx", "nova", "shimmer"
  - Default: "alloy"

- `response_format` (string, optional):
  - Supported formats: "mp3", "opus", "aac", "flac", "wav", "pcm"
  - Default: "mp3"

- `speed` (float, optional):
  - Range: 0.25 - 4.0
  - Default: 1.0

### Response
- Streaming audio response in the specified format
- Content-Type varies based on response format:
  - MP3: "audio/mpeg"
  - Opus: "audio/ogg;codec=opus"
  - AAC: "audio/aac"
  - FLAC: "audio/flac"
  - WAV: "audio/wav"
  - PCM: "audio/raw"

### Example Request
```json
{
  "model": "tts-1",
  "input": "Hello, this is a test of text-to-speech.",
  "voice": "nova",
  "response_format": "mp3",
  "speed": 1.0
}
```

### Curl Test Sample
```bash
# Basic text-to-speech generation
curl http://localhost:1434/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tts-1",
    "input": "Hello, world!",
    "voice": "nova",
    "response_format": "mp3"
  }' \
  --output output.mp3

# Advanced usage with custom speed and different voice
curl http://localhost:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tts-1-hd",
    "input": "This is a slower, high-definition speech sample.",
    "voice": "shimmer",
    "response_format": "wav",
    "speed": 0.75
  }' \
  --output output.wav
```

### Notes
- Input text goes through preprocessing before speech generation
- Model supports multiple languages
- Speed parameter allows adjusting speech rate

## Service Endpoints

### `/` - Root Endpoint
- **Methods**: GET, HEAD, OPTIONS
- **Description**: Service health check
- **Response**:
  - 200 status code if models are available
  - 503 status code if no models are loaded

### Curl Test Sample
```bash
# Check root endpoint
curl -I http://localhost:8000/

# Verbose root endpoint check
curl -v http://localhost:8000/
```

### `/health` - Service Health
- **Method**: GET
- **Description**: Returns current service status
- **Response Example**:
  ```json
  {
    "status": "ok" // or "unk"
  }
  ```

### Curl Test Sample
```bash
# Check service health
curl http://localhost:8000/health
```

### `/v1/models` - List Available Models
- **Method**: GET
- **Description**: Returns a list of available models
- **Response Example**:
  ```json
  {
    "object": "list",
    "data": [
      {
        "id": "tts-1",
        "object": "model",
        "created": 0,
        "owned_by": "user"
      }
    ]
  }
  ```

### Curl Test Sample
```bash
# List available models
curl http://localhost:8000/v1/models
```

### `/v1/models/{model}` - Model Information
- **Method**: GET
- **Description**: Returns information about a specific model
- **Response Example**:
  ```json
  {
    "id": "tts-1",
    "object": "model",
    "created": 0,
    "owned_by": "user"
  }
  ```

### Curl Test Sample
```bash
# Get information for a specific model
curl http://localhost:8000/v1/models/tts-1
```

### `/v1/billing/usage` and `/v1/dashboard/billing/usage` - Billing Usage
- **Method**: GET
- **Description**: Returns total API usage
- **Response Example**:
  ```json
  {
    "total_usage": 0
  }
  ```

### Curl Test Sample
```bash
# Check billing usage
curl http://localhost:8000/v1/billing/usage
curl http://localhost:8000/v1/dashboard/billing/usage
```

## Additional Notes
- Replace `http://localhost:8000` with your actual server address
- Ensure the server is running before executing these curl commands
- Some endpoints may require authentication in production environments

## Bonus Tip: Playing Generated Audio in WSL

### Option 1: Using mpv (Recommended)
```bash
# Install mpv if not already installed
sudo apt-get update
sudo apt-get install mpv

# Play the MP3 file
mpv output.mp3
```

Option 2: Using FFmpeg's ffplay
```
# Install FFmpeg if not already installed
sudo apt-get update
sudo apt-get install ffmpeg

# Play the MP3 file
ffplay -nodisp -autoexit output.mp3
```

## Option 3: Using aplay (for WAV files)
```
# Install alsa-utils if not already installed
sudo apt-get update
sudo apt-get install alsa-utils

# Play the WAV file
aplay output.wav
```

