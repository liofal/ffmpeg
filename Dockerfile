# Use Ubuntu 22.04 LTS as the base image
FROM ubuntu:22.04

# Update package lists, install software-properties-common
RUN apt-get update && \
    apt-get install -y software-properties-common

# Add the PPA for FFmpeg
RUN add-apt-repository ppa:ubuntuhandbook1/ffmpeg6 -y

# Update package lists again and install FFmpeg
RUN apt-get update && \
    apt-get install -y ffmpeg

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory to /app
WORKDIR /app

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Configure entrypoint with shell script
ENTRYPOINT ["/entrypoint.sh"]