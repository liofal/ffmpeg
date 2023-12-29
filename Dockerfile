# Use Ubuntu 22.04 LTS as the base image
FROM ubuntu:latest

# Set non-interactive installation mode
ENV DEBIAN_FRONTEND=noninteractive

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

# Set the working directory to /work
WORKDIR /work

# Optionally define a volume for data
VOLUME ["/work"]

# The entrypoint can be set to ffmpeg if this container will only be used for FFmpeg commands
ENTRYPOINT ["ffmpeg"]