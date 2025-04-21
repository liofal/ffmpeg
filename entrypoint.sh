#!/bin/sh

# Set default values if environment variables are not provided
WORKDIR="${WORKDIR:-/app/downloads}" # Match volume mount point
SLEEPTIME="${SLEEPTIME:-600}"
TARGET_FORMAT="mp4" # Assuming mp4 based on current script

echo "Starting conversion watchdog in $WORKDIR..."
echo "Checking every $SLEEPTIME seconds."

while true; do
  echo "Scanning for .ts files..."
  # Use -maxdepth 1 to avoid scanning subdirectories if not intended
  find "${WORKDIR}" -maxdepth 1 -type f -name "*.ts" | while IFS= read -r ts_file; do
    # Define output and failed file paths
    base_name=$(basename "$ts_file" .ts)
    mp4_file="${WORKDIR}/${base_name}.${TARGET_FORMAT}"
    failed_file="${ts_file}.failed"

    # Skip if output or failed file already exists
    if [ -f "$mp4_file" ]; then
      echo "Skipping '${ts_file}': Output file '${mp4_file}' already exists."
      # Optionally remove the source .ts file if output exists
      # echo "Removing source file '${ts_file}' as output exists."
      # rm "$ts_file"
      continue
    fi
    if [ -f "$failed_file" ]; then
      echo "Skipping '${ts_file}': Failed file '${failed_file}' already exists."
      continue
    fi

    echo "Attempting to convert '${ts_file}' to '${mp4_file}'..."

    # Perform the conversion using ffmpeg - using '-c copy' as in the original
    # The '-y' flag might not be needed if we check for existing files first
    ffmpeg -nostdin -i "${ts_file}" -c copy "${mp4_file}"

    exit_code=$?
    if [ $exit_code -eq 0 ]; then
      echo "Successfully converted '${ts_file}' to '${mp4_file}'."
      echo "Removing original file: ${ts_file}"
      rm "${ts_file}"
    else
      echo "ERROR: Conversion failed for '${ts_file}' (exit code: $exit_code)."
      # Remove potentially incomplete output file
      rm -f "$mp4_file" 
      echo "Renaming to '${failed_file}' to prevent retries."
      mv "${ts_file}" "${failed_file}"
      # Optionally add notification logic here
    fi
  done # End of find loop

  echo "Scan complete. Sleeping for $SLEEPTIME seconds..."
  sleep "$SLEEPTIME"
done # End of while true loop
