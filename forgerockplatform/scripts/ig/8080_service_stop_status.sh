PORT=8080
TIMEOUT=120  # Maximum wait time in seconds
INTERVAL=2  # Check interval in seconds
ELAPSED=0

echo "Waiting for service on port $PORT to stop..."

# Check if port is still in use
while [[ $ELAPSED -lt $TIMEOUT ]]; do
    if ! lsof -i :$PORT > /dev/null 2>&1; then
        echo "Service on port $PORT has stopped successfully."
        exit 0
    fi
    
    echo "Service still running (waited $ELAPSED seconds)..."
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done
echo "Timeout reached - service on port $PORT did not stop within $TIMEOUT seconds."
exit 1