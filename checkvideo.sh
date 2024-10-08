#!/bin/bash

# Video file path
video_file="$1"

# Check if video file was provided
if [ -z "$video_file" ]; then
    echo "Usage: $0 <video_file>"
    exit 1
fi

# Get the audio channel information
channels=$(ffmpeg -i "$video_file" -hide_banner 2>&1 | grep "Audio:" | grep -oP '(?<=, ).*?(?=\,|$)' | grep -oP '\d\.\d')

# Check for 7.1 channel audio
if echo "$channels" | grep -q "7.1"; then
    echo "7.1 surround sound detected. Converting to stereo AAC..."
    
    # Convert to stereo AAC
    ffmpeg -i "$video_file" -map 0:v:0 -c:v copy -map 0:a:0 -ac 2 -c:a aac -q:a 2 "${video_file%.mkv}_stereo_AAC.mkv"

    echo "Conversion complete. File saved as ${video_file%.mkv}_stereo_AAC.mkv"
else
    echo "The video does not have a 7.1 surround sound track."
fi
