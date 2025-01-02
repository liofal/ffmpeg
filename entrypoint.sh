#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Set default values if environment variables are not provided
: "${WORKDIR:=/app/downloads}"  # Define the working directory
: "${SLEEPTIME:=600}"  # Define the SLEEPTIME in seconds

convert_ts_to_mp4() {
    echo "Starting conversion of .ts files to .mp4 in ${WORKDIR}..."

    # Find all .ts files in the WORKDIR
    find "${WORKDIR}" -type f -name "*.ts" | while read -r ts_file; do
        # Define the output .mp4 file path
        mp4_file="${ts_file%.ts}.mp4"

        echo "Converting '${ts_file}' to '${mp4_file}'..."

        # Perform the conversion using ffmpeg
        ffmpeg -i "${ts_file}" -c copy "${mp4_file}" -y

        if [ $? -eq 0 ]; then
            echo "Successfully converted '${ts_file}' to '${mp4_file}'."
            rm "${ts_file}"
        else
            echo "Failed to convert '${ts_file}'."
        fi
    done

    echo "Conversion process completed."
}

# Convert .ts files to .mp4 after downloading
convert_ts_to_mp4

echo "All tasks completed successfully. Sleeping for $SLEEPTIME seconds..."
sleep $SLEEPTIME