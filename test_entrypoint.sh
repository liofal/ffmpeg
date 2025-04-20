#!/bin/sh

# Exit on error
set -e

echo "--- Starting Entrypoint Test ---"

# Override WORKDIR for test environment within the container
export WORKDIR="/test_run"
export SLEEPTIME=5 # Short sleep time for testing

# Create test directory
mkdir -p "$WORKDIR"
echo "Test directory created: $WORKDIR"

# Create test files
echo "Creating test files..."
# Use ffmpeg to create a small valid TS file quickly
ffmpeg -nostdin -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -f lavfi -i testsrc=duration=1:size=320x240:rate=15 -c:v libx264 -preset ultrafast -tune zerolatency -c:a aac -shortest -f mpegts "$WORKDIR/good.ts" > /dev/null 2>&1
echo "Created good.ts"
# Create an empty file to simulate failure
touch "$WORKDIR/bad.ts"
echo "Created bad.ts"

# List initial files
echo "Initial files in $WORKDIR:"
ls -l "$WORKDIR"

# Run the actual entrypoint script in the background
echo "Running entrypoint.sh in background..."
/entrypoint.sh &
ENTRYPOINT_PID=$!

# Allow time for the entrypoint to process files (adjust if needed)
echo "Waiting for entrypoint.sh to process files (approx ${SLEEPTIME}s + processing time)..."
sleep 10 # Give it a bit longer than SLEEPTIME to ensure one loop runs

# Stop the entrypoint script
echo "Stopping entrypoint.sh (PID: $ENTRYPOINT_PID)..."
kill $ENTRYPOINT_PID
# Wait briefly to ensure it exits, ignore error if already exited
wait $ENTRYPOINT_PID || true
echo "Entrypoint stopped."

# --- Verification ---
echo "Verifying results in $WORKDIR:"
ls -l "$WORKDIR"

# Check 1: Good file converted, original removed
if [ -f "$WORKDIR/good.mp4" ] && [ ! -f "$WORKDIR/good.ts" ]; then
  echo "✅ SUCCESS: good.ts converted to good.mp4 and original removed."
else
  echo "❌ FAILURE: good.ts was not processed correctly."
  exit 1
fi

# Check 2: Bad file failed and was renamed
if [ -f "$WORKDIR/bad.ts.failed" ] && [ ! -f "$WORKDIR/bad.ts" ]; then
  echo "✅ SUCCESS: bad.ts failed conversion and was renamed to bad.ts.failed."
else
  echo "❌ FAILURE: bad.ts was not handled correctly after failure."
  exit 1
fi

# Check 3: Ensure no unexpected mp4 for the bad file
if [ -f "$WORKDIR/bad.mp4" ]; then
  echo "❌ FAILURE: bad.mp4 was unexpectedly created."
  exit 1
fi

echo "--- Entrypoint Test Completed Successfully ---"
exit 0
