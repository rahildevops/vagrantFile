#!/bin/bash

PORT=9443
TIMEOUT=240  # Maximum wait time in seconds
INTERVAL=2   # Check interval in seconds
ELAPSED=0
SERVICE_NAME="your-service"  # Replace with your service name

echo "Waiting for $SERVICE_NAME to start on port $PORT..."

# Check if port is in use by a listening service
while [[ $ELAPSED -lt $TIMEOUT ]]; do
    # Using lsof to check for listening service on the port
    if lsof -i :$PORT | grep -q LISTEN; then
        # Optional: Verify it's the correct service
        PID=$(lsof -ti :$PORT)
        if [[ -n "$PID" ]]; then
            echo "$SERVICE_NAME is running on port $PORT (PID: $PID)"
            exit 0
        fi
    fi
    
    echo "Service not yet started (waited $ELAPSED seconds)..."
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "Timeout reached - $SERVICE_NAME did not start within $TIMEOUT seconds"
exit 1