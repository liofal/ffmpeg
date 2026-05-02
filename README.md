# FFmpeg Conversion Service

This project provides a Dockerized service to convert `.ts` video files to `.mp4` format using FFmpeg. The conversion process is automated and runs periodically based on the specified sleep time.

## Prerequisites

- Docker
- Docker Compose

## Getting Started

### Clone the Repository

```sh
git clone https://github.com/liofal/ffmpeg.git
cd ffmpeg
```

### Configuration

Create a `.env` file in the project root directory with the following content:

```properties
SLEEPTIME=600
WORKDIR=/app/downloads
```

- `SLEEPTIME`: Time in seconds to wait before the next conversion cycle.
- `WORKDIR`: Directory where the `.ts` files are located and where the converted `.mp4` files will be saved.

### Failure handling

The converter writes to a temporary `.mp4.part` file first. When conversion succeeds, the temporary file is moved to `.mp4` and the source `.ts` file is removed.

If FFmpeg fails, the converter removes partial `.mp4` output and renames the source file from `video.ts` to `video.ts.failed`. This prevents restart policies from retrying the same failing file indefinitely.

Large `.ts` files can require more than 256M of memory even when using `-c copy` remuxing. For large recordings, configure the container with at least 512M of memory or remove the memory limit.

### Build and Run the Docker Container

Use Docker Compose to build and run the container:

```sh
docker-compose up --build
```

This will build the Docker image and start the container. The service will automatically convert any `.ts` files in the specified `WORKDIR` to `.mp4` format.

### Volumes

The `docker-compose.yml` file is configured to mount a local directory to the container's working directory. Update the `volumes` section as needed:

```yaml
volumes:
  - /path/to/local/downloads:/app/downloads
```

### Environment Variables

You can specify environment variables in the `.env` file or directly in the `docker-compose.yml` file.

### Stopping the Service

To stop the service, use:

```sh
docker-compose down
```

## Important Note on Project Scope

This project was previously named `ffmpeg6` and focused specifically on FFmpeg version 6. It has now been renamed to `ffmpeg` to reflect a broader scope that may include features or compatibility changes beyond version 6. Please be aware that future updates might introduce changes based on newer FFmpeg versions or other related tools.

## License

This project is licensed under the MIT License.
