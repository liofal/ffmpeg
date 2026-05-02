#!/bin/sh

# Exit on unexpected script errors, but handle ffmpeg conversion failures explicitly.
set -eu

# Set default values if environment variables are not provided
: "${WORKDIR:=/app/downloads}"  # Define the working directory
: "${SLEEPTIME:=600}"  # Define the SLEEPTIME in seconds
: "${RUN_ONCE:=false}"  # Set to true for one-shot execution/tests

mark_failed() {
    ts_file="$1"
    failed_file="${ts_file}.failed"

    if [ -e "${failed_file}" ]; then
        failed_file="${ts_file}.failed.$(date +%Y%m%d%H%M%S)"
    fi

    mv "${ts_file}" "${failed_file}"
    echo "Marked failed conversion as '${failed_file}'."
}

convert_ts_to_mp4() {
    echo "Starting conversion of .ts files to .mp4 in ${WORKDIR}..."

    mkdir -p "${WORKDIR}"

    # Find all .ts files in the WORKDIR
    find "${WORKDIR}" -type f -name "*.ts" | while read -r ts_file; do
        # Define the output .mp4 file path
        mp4_file="${ts_file%.ts}.mp4"
        part_file="${mp4_file}.part"

        echo "Converting '${ts_file}' to '${mp4_file}'..."

        rm -f "${part_file}"

        # Perform the conversion using ffmpeg. Do not let failures exit the
        # entrypoint before the source file and partial output are handled.
        if ffmpeg -y -i "${ts_file}" -c copy -f mp4 "${part_file}" && mv "${part_file}" "${mp4_file}"; then
            echo "Successfully converted '${ts_file}' to '${mp4_file}'."
            rm "${ts_file}"
        else
            echo "Failed to convert '${ts_file}'."
            rm -f "${part_file}"
            mark_failed "${ts_file}"
        fi
    done

    echo "Conversion process completed."
}

while true; do
    convert_ts_to_mp4

    if [ "${RUN_ONCE}" = "true" ]; then
        echo "RUN_ONCE=true; exiting after one conversion pass."
        exit 0
    fi

    echo "All tasks completed successfully. Sleeping for ${SLEEPTIME} seconds..."
    sleep "${SLEEPTIME}"
done
