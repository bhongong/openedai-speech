#!/bin/bash

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "fzf is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y fzf
fi

URL=${1:-http://localhost:1434/v1/audio/speech}
SAMPLES_DIR="voice_samples"
mkdir -p "$SAMPLES_DIR"

# Function to generate voice samples with custom input
generate_samples() {
    local input_text="${1:-The quick brown fox jumped over the lazy dog.}"
    
    # Clear existing samples
    rm -f "$SAMPLES_DIR"/*.mp3

    for voice in alloy echo fable onyx nova shimmer; do
        # tts-1 model sample
        curl -s "$URL" -H "Content-Type: application/json" -d "{
            \"model\": \"tts-1\",
            \"input\": \"$input_text This voice is called $voice.\",
            \"voice\": \"$voice\",
            \"speed\": 1.0,
            \"response_format\": \"mp3\"
        }" > "$SAMPLES_DIR/${voice}_tts1.mp3"

        # tts-1-hd model sample
        curl -s "$URL" -H "Content-Type: application/json" -d "{
            \"model\": \"tts-1-hd\",
            \"input\": \"$input_text This is the high-definition version of $voice.\",
            \"voice\": \"$voice\",
            \"speed\": 1.0,
            \"response_format\": \"mp3\"
        }" > "$SAMPLES_DIR/${voice}_tts1hd.mp3"
    done
}

# Function to play audio file
play_audio() {
    local file="$1"
    mpv --really-quiet "$file"
}

# Interactive menu function
interactive_menu() {
    # Regenerate samples if directory is empty
    if [ ! "$(ls -A "$SAMPLES_DIR")" ]; then
        generate_samples
    fi

    while true; do
        # Use fzf to create an interactive menu with custom sorting
        selected=$(find "$SAMPLES_DIR" -name "*.mp3" | sort -t'_' -k1,1 -k2,2r | fzf \
            --preview='echo "File: $(basename {})"; du -h {}' \
            --preview-window=right:40% \
            --prompt="Select a voice sample to play (ESC to exit): " \
            --layout=reverse \
            --height=50%)

        # Check if a file was selected
        if [ -z "$selected" ]; then
            break
        fi

        # Play the selected audio file
        play_audio "$selected"
    done
}

# Custom input function
custom_input_menu() {
    clear
    echo "Custom Voice Sample Generator"
    echo "---------------------------"
    
    # Prompt for custom input
    read -p "Enter the text you want to generate voice samples for: " custom_text
    
    # Validate input
    if [ -z "$custom_text" ]; then
        echo "No text entered. Using default."
        custom_text="The quick brown fox jumped over the lazy dog."
    fi
    
    # Generate samples with custom text
    generate_samples "$custom_text"
    
    # Immediately go to interactive menu
    interactive_menu
}

# Main script
while true; do
    clear
    echo "Voice Sample Interactive Player"
    echo "------------------------------"
    echo "1. Generate Default Samples"
    echo "2. Play Existing Samples"
    echo "3. Generate Custom Text Samples"
    echo "4. Exit"

    read -p "Choose an option (1-4): " choice

    case $choice in
        1)
            generate_samples
            echo "Default samples generated in $SAMPLES_DIR directory"
            interactive_menu
            ;;
        2)
            interactive_menu
            ;;
        3)
            custom_input_menu
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid option"
            sleep 2
            ;;
    esac
done
