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

### Build and Run the Docker Container

Use Docker Compose to build and run the container:

```sh
docker-compose up --build
```

This will build the Docker image and start the container. The service will automatically scan for `.ts` files in the specified `WORKDIR`. It attempts to convert them to `.mp4` format using `ffmpeg -c copy`. 
- Successful conversions result in the original `.ts` file being deleted.
- If a conversion fails (due to errors like invalid data or resource limits), the original `.ts` file will be renamed to `.ts.failed` to prevent repeated failed attempts on the same file.

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

## Testing

This project includes an automated test script (`test_entrypoint.sh`) and a dedicated Docker Compose file (`docker-compose.test.yml`) to verify the entrypoint script's behavior.

To run the tests:

1.  Ensure Docker is running.
2.  Execute the following command from the project root:

    ```sh
    docker compose -f docker-compose.test.yml up --build --abort-on-container-exit
    ```

The test script will:
- Create a temporary test directory inside the container.
- Generate a small valid `.ts` file and an empty `.ts` file (to simulate failure).
- Run the main `entrypoint.sh` script in the background for a short period.
- Verify that the valid file was converted to `.mp4` and the original removed.
- Verify that the invalid file failed conversion and was renamed to `.ts.failed`.
- Exit with code 0 on success or 1 on failure.

## Important Note on Project Scope

This project was previously named `ffmpeg6` and focused specifically on FFmpeg version 6. It has now been renamed to `ffmpeg` to reflect a broader scope that may include features or compatibility changes beyond version 6. Please be aware that future updates might introduce changes based on newer FFmpeg versions or other related tools.

## License

This project is licensed under the MIT License.
