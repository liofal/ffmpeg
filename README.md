
# FFmpeg Docker Compose Service

## Introduction
This Docker Compose service utilizes FFmpeg to process video files. The service is built on the `liofal/ffmpeg` image and is designed to work with ONVIF compliant video streams.

## Prerequisites
Before you begin, ensure you have the following installed:
- Docker
- Docker Compose

## Installation
1. Clone the repository to your local machine:
   ```bash
   git clone [your-repo-url]
   cd [your-repo-directory]
   ```

2. Build the Docker image:
   ```bash
   docker-compose build
   ```

## Usage
To use the FFmpeg service, run the following command:
```bash
docker-compose run ffmpeg -i 'input-file.mp4' -c:v copy -c:a aac 'output-file.mp4'
```
Replace `input-file.mp4` and `output-file.mp4` with your source and destination file names, respectively.
